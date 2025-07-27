import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/application.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/search_objects/application_search_object.dart';
import 'package:itapply_desktop/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_desktop/providers/application_provider.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class JobPostingAnalytics {
  final JobPosting jobPosting;
  final int totalApplications;
  final Map<String, int> statusBreakdown;
  final DateTime? lastApplicationDate;
  final double averageApplicationsPerDay;

  JobPostingAnalytics({
    required this.jobPosting,
    required this.totalApplications,
    required this.statusBreakdown,
    this.lastApplicationDate,
    required this.averageApplicationsPerDay,
  });
}

class EmployerReportsScreen extends StatefulWidget {
  const EmployerReportsScreen({super.key});

  @override
  State<EmployerReportsScreen> createState() => _EmployerReportsScreenState();
}

class _EmployerReportsScreenState extends State<EmployerReportsScreen> {
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0;

  final GlobalKey _topJobsChartKey = GlobalKey();
  final GlobalKey _applicationStatusChartKey = GlobalKey();
  final GlobalKey _applicationTrendsChartKey = GlobalKey();

  List<JobPosting> _allJobPostings = [];
  List<Application> _allApplications = [];
  Map<String, int> _topJobsData = {};
  Map<String, int> _applicationStatusData = {};
  Map<String, int> _applicationTrendsData = {};
  List<JobPostingAnalytics> _jobPostingAnalytics = [];

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final employerId = context.read<AuthProvider>().currentEmployer?.id;
      if (employerId == null) throw Exception("Employer not found.");

      final results = await Future.wait([
        context.read<JobPostingProvider>().get(filter: JobPostingSearchObject(EmployerId: employerId, RetrieveAll: true)),
        context.read<ApplicationProvider>().get(filter: ApplicationSearchObject(EmployerId: employerId, RetrieveAll: true)),
      ]);

      if (mounted) {
        _allJobPostings = results[0].items as List<JobPosting>;
        _allApplications = results[1].items as List<Application>;
        _generateAnalytics();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    }
  }

  void _generateAnalytics() {
    Map<int, int> jobApplicationCounts = {};
    for (var app in _allApplications) {
      jobApplicationCounts[app.jobPostingId] = (jobApplicationCounts[app.jobPostingId] ?? 0) + 1;
    }
    
    var sortedJobs = jobApplicationCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    _topJobsData = {};
    int otherCount = 0;
    for (var i = 0; i < sortedJobs.length; i++) {
      if (i < 5 && _allJobPostings.any((j) => j.id == sortedJobs[i].key)) {
        final job = _allJobPostings.firstWhere((j) => j.id == sortedJobs[i].key);
        _topJobsData[job.title] = sortedJobs[i].value;
      } else {
        otherCount += sortedJobs[i].value;
      }
    }
    if (otherCount > 0) _topJobsData["Other"] = otherCount;

    _applicationStatusData = {};
    for (var app in _allApplications) {
      final statusString = applicationStatusToString(app.status);
      _applicationStatusData[statusString] = (_applicationStatusData[statusString] ?? 0) + 1;
    }

    _applicationTrendsData = {};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM yyyy').format(month);
      _applicationTrendsData[monthKey] = 0;
    }
    
    for (var app in _allApplications) {
      final appMonth = DateFormat('MMM yyyy').format(app.applicationDate);
      if (_applicationTrendsData.containsKey(appMonth)) {
        _applicationTrendsData[appMonth] = _applicationTrendsData[appMonth]! + 1;
      }
    }

    _jobPostingAnalytics = [];
    for (var job in _allJobPostings) {
      final jobApplications = _allApplications.where((app) => app.jobPostingId == job.id).toList();
      final statusBreakdown = <String, int>{};
      
      for (var app in jobApplications) {
        final status = applicationStatusToString(app.status);
        statusBreakdown[status] = (statusBreakdown[status] ?? 0) + 1;
      }
      
      final daysSincePosted = DateTime.now().difference(job.postedDate).inDays;
      final avgApplicationsPerDay = daysSincePosted > 0 ? jobApplications.length / daysSincePosted : 0.0;
      
      _jobPostingAnalytics.add(JobPostingAnalytics(
        jobPosting: job,
        totalApplications: jobApplications.length,
        statusBreakdown: statusBreakdown,
        lastApplicationDate: jobApplications.isNotEmpty ? jobApplications.map((a) => a.applicationDate).reduce((a, b) => a.isAfter(b) ? a : b) : null,
        averageApplicationsPerDay: avgApplicationsPerDay,
      ));
    }
    
    _jobPostingAnalytics.sort((a, b) => b.totalApplications.compareTo(a.totalApplications));
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Company Reports & Analytics",
      selectedRoute: AppRouter.employerReportsRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _buildReportContent(),
    );
  }

  Widget _buildReportContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildTabNavigation(),
        const SizedBox(height: 24),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabNavigation() {
    return Row(
      children: [
        _buildTabButton("Overview & Trends", 0),
        _buildTabButton("Job Posting Details", 1),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedTabIndex = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : AppTheme.textColor,
          elevation: isSelected ? 2 : 0,
        ),
        child: Text(title),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildJobPostingDetailsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTopJobsChart()),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _buildApplicationStatusChart()),
            ],
          ),
          const SizedBox(height: 24),
          _buildApplicationTrendsChart(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Performance Overview",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: (_topJobsData.isEmpty && _applicationStatusData.isEmpty) ? null : _showExportDialog,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text("Generate Report"),
        ),
      ],
    );
  }
  
  Widget _buildTopJobsChart() {
    return RepaintBoundary(
      key: _topJobsChartKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Most Popular Job Postings", style: Theme.of(context).textTheme.titleLarge),
              Text("(by application count)", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: _topJobsData.isEmpty 
                  ? const Center(child: Text("No application data available."))
                  : PieChart(
                    PieChartData(
                      sections: _topJobsData.entries.map((entry) {
                        final index = _topJobsData.keys.toList().indexOf(entry.key);
                        final color = AppTheme.pieColors[index % AppTheme.pieColors.length];
                        return PieChartSectionData(
                          color: color,
                          value: entry.value.toDouble(),
                          title: '${entry.value}',
                          radius: 100,
                          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
              ),
              const SizedBox(height: 24),
              _buildLegend(_topJobsData),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildApplicationStatusChart() {
    return RepaintBoundary(
      key: _applicationStatusChartKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Application Status Breakdown", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: _applicationStatusData.isEmpty
                ? const Center(child: Text("No application data available."))
                : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: _applicationStatusData.entries.map((entry) {
                      final index = _applicationStatusData.keys.toList().indexOf(entry.key);
                      return BarChartGroupData(
                        x: index,
                        barRods: [BarChartRodData(toY: entry.value.toDouble(), color: AppTheme.pieColors[index % AppTheme.pieColors.length], width: 25, borderRadius: BorderRadius.zero)],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final text = _applicationStatusData.keys.toList()[value.toInt()];
                            return SideTitleWidget(
                              meta: meta,
                              space: 4,
                              child: Text(text, style: const TextStyle(fontSize: 10)),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 == 0) {
                              return Text(value.toInt().toString());
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLegend(Map<String, int> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: AppTheme.pieColors[index % AppTheme.pieColors.length]),
            const SizedBox(width: 6),
            Text(entry.key),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCards() {
    final totalApplications = _allApplications.length;
    final totalJobPostings = _allJobPostings.length;
    final activeJobPostings = _allJobPostings.where((job) => job.status == JobPostingStatus.active).length;
    final avgApplicationsPerJob = totalJobPostings > 0 ? (totalApplications / totalJobPostings).toStringAsFixed(1) : '0';
    
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Total Applications', totalApplications.toString(), Icons.assignment, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Active Job Postings', activeJobPostings.toString(), Icons.work, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Total Job Postings', totalJobPostings.toString(), Icons.business_center, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Avg Apps/Job', avgApplicationsPerJob, Icons.trending_up, Colors.purple)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationTrendsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Application Trends (Last 6 Months)", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: _applicationTrendsData.isEmpty
                ? const Center(child: Text("No application data available for trends analysis."))
                : RepaintBoundary(
                    key: _applicationTrendsChartKey,
                    child: BarChart(
                      BarChartData(
                        barGroups: _applicationTrendsData.entries.map((entry) {
                          final index = _applicationTrendsData.keys.toList().indexOf(entry.key);
                          return BarChartGroupData(
                            x: index,
                            barRods: [BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: AppTheme.primaryColor,
                              width: 25,
                              borderRadius: BorderRadius.zero,
                            )],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0) {
                                  return Text(value.toInt().toString());
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < _applicationTrendsData.keys.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _applicationTrendsData.keys.toList()[index],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobPostingDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Individual Job Posting Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_jobPostingAnalytics.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No job posting data available for detailed analysis.'),
              ),
            )
          else
            ..._jobPostingAnalytics.map((analytics) => _buildJobPostingCard(analytics)),
        ],
      ),
    );
  }

  Widget _buildJobPostingCard(JobPostingAnalytics analytics) {
    final job = analytics.jobPosting;
    final daysSincePosted = DateTime.now().difference(job.postedDate).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posted $daysSincePosted days ago',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${analytics.totalApplications} Applications',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildJobMetric('Avg/Day', analytics.averageApplicationsPerDay.toStringAsFixed(1)),
                ),
                Expanded(
                  child: _buildJobMetric('Last Application', 
                    analytics.lastApplicationDate != null 
                      ? DateFormat('MMM dd').format(analytics.lastApplicationDate!) 
                      : 'None'),
                ),
                Expanded(
                  child: _buildJobMetric('Status', jobPostingStatusToString(analytics.jobPosting.status)),
                ),
              ],
            ),
            if (analytics.statusBreakdown.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Application Status Breakdown:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: analytics.statusBreakdown.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}', style: const TextStyle(color: Colors.white)),
                    backgroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: Colors.white),
                    shape: const StadiumBorder(side: BorderSide.none),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJobMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _showExportDialog() async {
    final Map<String, bool> reportOptions = {
      "Summary Cards": true,
      "Top Job Postings Chart": true,
      "Application Status Chart": true,
      "Application Trends Chart": true,
      "Individual Job Posting Details": true,
    };

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text("Generate PDF Report"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: reportOptions.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: reportOptions[key],
                  onChanged: (bool? value) {
                    setDialogState(() {
                      reportOptions[key] = value!;
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generateAndPrintPdf(reportOptions);
                },
                icon: const Icon(Icons.print),
                label: const Text("Print"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generateAndDownloadPdf(reportOptions);
                },
                icon: const Icon(Icons.download),
                label: const Text("Export"),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateAndPrintPdf(Map<String, bool> options) async {
    try {
      final pdf = await _generatePdfDocument(options);
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report sent to printer successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print report: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _generateAndDownloadPdf(Map<String, bool> options) async {
    try {
      final pdf = await _generatePdfDocument(options);
      final companyName = context.read<AuthProvider>().currentEmployer?.companyName ?? "Company";
      final fileName = '${companyName}_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
      
      String? downloadsPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select download location',
        initialDirectory: await _getDownloadsDirectory(),
      );
      
      if (downloadsPath != null) {
        final file = File('$downloadsPath/$fileName');
        await file.writeAsBytes(await pdf.save());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report saved to: $downloadsPath\\$fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Open Folder',
                textColor: Colors.white,
                onPressed: () => _openFileLocation(downloadsPath),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download cancelled by user'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download report: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePdfDocument(Map<String, bool> options) async {
    final pdf = pw.Document();
    final companyName = context.read<AuthProvider>().currentEmployer?.companyName ?? "Company";

    final originalTab = _selectedTabIndex;
    
    for (int i = 0; i < 2; i++) {
      setState(() => _selectedTabIndex = i);
      await Future.delayed(const Duration(milliseconds: 400));
    }
    
    setState(() => _selectedTabIndex = originalTab);
    await Future.delayed(const Duration(milliseconds: 300));

    Future<Uint8List?> captureChart(GlobalKey key) async {
      try {
        final context = key.currentContext;
        if (context == null) return null;
        
        RenderRepaintBoundary boundary = context.findRenderObject() as RenderRepaintBoundary;
        if (boundary.debugNeedsPaint) {
          await Future.delayed(const Duration(milliseconds: 100));
          return captureChart(key);
        }
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      } catch (e) {
        debugPrint('Error capturing chart: $e');
        return null;
      }
    }

    Uint8List? topChartImage;
    Uint8List? statusChartImage;
    Uint8List? trendsChartImage;

    if (options["Top Job Postings Chart"] == true) {
      topChartImage = await captureChart(_topJobsChartKey);
    }
    if (options["Application Status Chart"] == true) {
      statusChartImage = await captureChart(_applicationStatusChartKey);
    }
    if (options["Application Trends Chart"] == true) {
      trendsChartImage = await captureChart(_applicationTrendsChartKey);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildPdfHeader(companyName),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          if (options["Summary Cards"] == true) ...[
            pw.Header(level: 1, text: 'Executive Summary'),
            _buildPdfSummaryCards(),
            pw.SizedBox(height: 30),
          ],
          
          if (topChartImage != null) ...[
            pw.Header(level: 1, text: 'Top Job Postings by Applications'),
            pw.Image(pw.MemoryImage(topChartImage), height: 300),
            pw.SizedBox(height: 20),
          ],
          if (statusChartImage != null) ...[
            pw.Header(level: 1, text: 'Application Status Breakdown'),
            pw.Image(pw.MemoryImage(statusChartImage), height: 300),
            pw.SizedBox(height: 20),
          ],
          if (trendsChartImage != null) ...[
            pw.Header(level: 1, text: 'Application Trends (Last 6 Months)'),
            pw.Image(pw.MemoryImage(trendsChartImage), height: 300),
            pw.SizedBox(height: 20),
          ],
          
          if (options["Individual Job Posting Details"] == true) ...[
            pw.Header(level: 1, text: 'Individual Job Posting Performance'),
            ..._buildPdfJobPostingDetails(),
          ],
        ],
      ),
    );

    return pdf;
  }

  Future<String?> _getDownloadsDirectory() async {
    try {
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          final downloadsDir = Directory('$userProfile\\Downloads');
          if (await downloadsDir.exists()) {
            return downloadsDir.path;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _openFileLocation(String path) {
    if (Platform.isWindows) {
        Process.run('explorer', [path]);
      } else if (Platform.isMacOS) {
        Process.run('open', [path]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [path]);
      }
  }
  
  pw.Widget _buildPdfHeader(String companyName) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Column(
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: 'IT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColor.fromInt(AppTheme.primaryColor.value))),
                pw.TextSpan(text: 'apply', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColor.fromInt(AppTheme.secondaryColor.value))),
              ]
            )
          ), 
          
          pw.Text('$companyName - Performance Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          pw.Text('Generated on: ${DateFormat.yMMMd().format(DateTime.now())}'),
          pw.Divider(thickness: 1.5, color: PdfColors.grey),
        ]
      ),
    );
  }
  
  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
    );
  }

  pw.Widget _buildPdfSummaryCards() {
    final totalApplications = _allApplications.length;
    final totalJobPostings = _allJobPostings.length;
    final activeJobPostings = _allJobPostings.where((job) => job.status == JobPostingStatus.active).length;
    final avgApplicationsPerJob = totalJobPostings > 0 ? (totalApplications / totalJobPostings).toStringAsFixed(1) : '0';
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildPdfSummaryCard('Total Applications', totalApplications.toString()),
              _buildPdfSummaryCard('Active Job Postings', activeJobPostings.toString()),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildPdfSummaryCard('Total Job Postings', totalJobPostings.toString()),
              _buildPdfSummaryCard('Avg Apps/Job', avgApplicationsPerJob),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummaryCard(String title, String value) {
    return pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppTheme.primaryColor.value)),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildPdfJobPostingDetails() {
    if (_jobPostingAnalytics.isEmpty) {
      return [
        pw.Text('No job posting data available for detailed analysis.'),
        pw.SizedBox(height: 20),
      ];
    }
    
    List<pw.Widget> widgets = [];
    
    for (int i = 0; i < _jobPostingAnalytics.length; i++) {
      final analytics = _jobPostingAnalytics[i];
      final job = analytics.jobPosting;
      final daysSincePosted = DateTime.now().difference(job.postedDate).inDays;
      
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          job.title,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Posted $daysSincePosted days ago',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(AppTheme.lightColor.value),
                      border: pw.Border.all(color: PdfColor.fromInt(AppTheme.primaryColor.value)),
                      borderRadius: pw.BorderRadius.circular(16),
                    ),
                    child: pw.Text(
                      '${analytics.totalApplications} Applications',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppTheme.primaryColor.value)),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfJobMetric('Avg/Day', analytics.averageApplicationsPerDay.toStringAsFixed(1)),
                  _buildPdfJobMetric('Last Application', 
                    analytics.lastApplicationDate != null 
                      ? DateFormat('MMM dd').format(analytics.lastApplicationDate!) 
                      : 'None'),
                  _buildPdfJobMetric('Status', jobPostingStatusToString(job.status)),
                ],
              ),
              
              if (analytics.statusBreakdown.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  'Application Status Breakdown:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: analytics.statusBreakdown.entries.map((entry) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(AppTheme.primaryColor.value),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        '${entry.key}: ${entry.value}',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    return widgets;
  }

  pw.Widget _buildPdfJobMetric(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}