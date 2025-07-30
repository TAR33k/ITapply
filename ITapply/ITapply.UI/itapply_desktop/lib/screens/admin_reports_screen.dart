import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/application.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting_skill.dart';
import 'package:itapply_desktop/models/search_objects/application_search_object.dart';
import 'package:itapply_desktop/models/search_objects/employer_search_object.dart';
import 'package:itapply_desktop/models/search_objects/job_posting_skill_search_object.dart';
import 'package:itapply_desktop/models/search_objects/user_search_object.dart';
import 'package:itapply_desktop/models/user.dart';
import 'package:itapply_desktop/providers/application_provider.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/job_posting_skill_provider.dart';
import 'package:itapply_desktop/providers/user_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _isLoading = true;
  String? _error;

  final GlobalKey _userGrowthChartKey = GlobalKey();
  final GlobalKey _topEmployersChartKey = GlobalKey();
  final GlobalKey _topSkillsChartKey = GlobalKey();
  final GlobalKey _applicationTrendsChartKey = GlobalKey();

  List<User> _allUsers = [];
  List<Employer> _allEmployers = [];
  List<Application> _allApplications = [];
  List<JobPostingSkill> _allJobSkills = [];
  
  Map<String, int> _userGrowthData = {};
  Map<String, int> _topEmployersData = {};
  Map<String, int> _topSkillsData = {};
  Map<String, int> _applicationTrendsData = {};

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final results = await Future.wait([
        context.read<UserProvider>().get(filter: UserSearchObject(RetrieveAll: true)),
        context.read<EmployerProvider>().get(filter: EmployerSearchObject(RetrieveAll: true, verificationStatus: VerificationStatus.approved)),
        context.read<ApplicationProvider>().get(filter: ApplicationSearchObject(RetrieveAll: true)),
        context.read<JobPostingSkillProvider>().get(filter: JobPostingSkillSearchObject(RetrieveAll: true)),
      ]);

      if (mounted) {
        _allUsers = results[0].items as List<User>;
        _allEmployers = results[1].items as List<Employer>;
        _allApplications = results[2].items as List<Application>;
        _allJobSkills = results[3].items as List<JobPostingSkill>;
        _generateAnalytics();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    }
  }

  void _generateAnalytics() {
    _userGrowthData = {};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('MMM yyyy').format(month);
        _userGrowthData[monthKey] = 0;
    }
    for(var user in _allUsers) {
        final regMonth = DateFormat('MMM yyyy').format(user.registrationDate);
        if (_userGrowthData.containsKey(regMonth)) {
            _userGrowthData[regMonth] = _userGrowthData[regMonth]! + 1;
        }
    }
    
    Map<String, int> employerAppCounts = {};
    for (var app in _allApplications) {
      if (app.companyName != null) {
        employerAppCounts[app.companyName!] = (employerAppCounts[app.companyName!] ?? 0) + 1;
      }
    }
    var sortedEmployers = employerAppCounts.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    _topEmployersData = {};
    for (var i = 0; i < sortedEmployers.length && i < 5; i++) {
        _topEmployersData[sortedEmployers[i].key] = sortedEmployers[i].value;
    }

    Map<String, int> skillCounts = {};
    for (var jobSkill in _allJobSkills) {
        if (jobSkill.skillName != null) {
            skillCounts[jobSkill.skillName!] = (skillCounts[jobSkill.skillName!] ?? 0) + 1;
        }
    }
    var sortedSkills = skillCounts.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    _topSkillsData = { for (var i = 0; i < sortedSkills.length && i < 10; i++) sortedSkills[i].key : sortedSkills[i].value };

    _applicationTrendsData = {};
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
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Platform Reports & Analytics",
      selectedRoute: AppRouter.adminReportsRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _buildReportContent(),
    );
  }

  Widget _buildReportContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildUserGrowthChart(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTopEmployersChart()),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _buildTopSkillsChart()),
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
          "Platform Analytics",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: _showExportDialog,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text("Generate Report"),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final totalUsers = _allUsers.length;
    final totalEmployers = _allEmployers.length;
    final totalApplications = _allApplications.length;
    final totalSkills = _allJobSkills.map((e) => e.skillId).toSet().length;

    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Total Users', totalUsers.toString(), Icons.people, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Total Employers', totalEmployers.toString(), Icons.business, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Total Applications', totalApplications.toString(), Icons.assignment, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Unique Skills', totalSkills.toString(), Icons.lightbulb, Colors.purple)),
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
                Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserGrowthChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("User Registrations (Last 6 Months)", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: RepaintBoundary(
                key: _userGrowthChartKey,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1, getTitlesWidget: (value, meta) => Text(value.toInt().toString()))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, 
                        reservedSize: 40, 
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final keys = _userGrowthData.keys.toList();
                          if (index >= 0 && index < keys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0), 
                              child: Text(
                                keys[index], 
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              )
                            );
                          }
                          return const SizedBox.shrink();
                        }
                      )),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _userGrowthData.entries.map((entry) {
                          final index = _userGrowthData.keys.toList().indexOf(entry.key);
                          return FlSpot(index.toDouble(), entry.value.toDouble());
                        }).toList(),
                        color: AppTheme.primaryColor,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.3)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopEmployersChart() {
    return RepaintBoundary(
      key: _topEmployersChartKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Top Employers", style: Theme.of(context).textTheme.titleLarge),
              Text("(by application count)", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: _topEmployersData.isEmpty 
                  ? const Center(child: Text("No data available."))
                  : PieChart(
                    PieChartData(
                      sections: _topEmployersData.entries.map((entry) {
                        final index = _topEmployersData.keys.toList().indexOf(entry.key);
                        return PieChartSectionData(
                          color: AppTheme.pieColors[index % AppTheme.pieColors.length],
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
              _buildLegend(_topEmployersData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSkillsChart() {
    return RepaintBoundary(
      key: _topSkillsChartKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Top 10 Required Skills", style: Theme.of(context).textTheme.titleLarge),
              Text("(in job postings)", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: _topSkillsData.isEmpty
                ? const Center(child: Text("No data available."))
                : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: _topSkillsData.entries.map((entry) {
                       final index = _topSkillsData.keys.toList().indexOf(entry.key);
                       return BarChartGroupData(
                         x: index,
                         barRods: [BarChartRodData(toY: entry.value.toDouble(), color: AppTheme.pieColors[index % AppTheme.pieColors.length], width: 18, borderRadius: BorderRadius.zero)],
                       );
                    }).toList(),
                    titlesData: FlTitlesData(
                       bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                           return SideTitleWidget(meta: meta, space: 4, child: Text(_topSkillsData.keys.toList()[value.toInt()], style: const TextStyle(fontSize: 10)));
                       }, reservedSize: 30)),
                       leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1, getTitlesWidget: (value, meta) => Text(value.toInt().toString()))),
                       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    )
                  ),
                ),
              ),
            ],
          ),
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
            Text("Application Volume (Last 6 Months)", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: RepaintBoundary(
                key: _applicationTrendsChartKey,
                child: BarChart(
                  BarChartData(
                    barGroups: _applicationTrendsData.entries.map((entry) {
                      final index = _applicationTrendsData.keys.toList().indexOf(entry.key);
                      return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: entry.value.toDouble(), color: AppTheme.primaryColor, width: 25, borderRadius: BorderRadius.zero)]);
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1, getTitlesWidget: (value, meta) => Text(value.toInt().toString()))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                          return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(_applicationTrendsData.keys.toList()[value.toInt()], style: const TextStyle(fontSize: 10)));
                      })),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ),
          ],
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

  Future<void> _showExportDialog() async {
    final Map<String, bool> reportOptions = {
      "Summary Cards": true,
      "User Growth Chart": true,
      "Top Employers Chart": true,
      "Top Skills Chart": true,
      "Application Trends Chart": true,
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
                  title: Text(key), value: reportOptions[key],
                  onChanged: (bool? value) => setDialogState(() => reportOptions[key] = value!),
                );
              }).toList(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
              ElevatedButton.icon(
                onPressed: () { Navigator.of(context).pop(); _generateAndPrintPdf(reportOptions); },
                icon: const Icon(Icons.print), label: const Text("Print"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () { Navigator.of(context).pop(); _generateAndDownloadPdf(reportOptions); },
                icon: const Icon(Icons.download), label: const Text("Export"),
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
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to print report: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _generateAndDownloadPdf(Map<String, bool> options) async {
    try {
      final pdf = await _generatePdfDocument(options);
      final fileName = 'ITapply_Platform_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
      
      String? downloadsPath = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select download location', initialDirectory: await _getDownloadsDirectory());
      
      if (downloadsPath != null) {
        final file = File('$downloadsPath/$fileName');
        await file.writeAsBytes(await pdf.save());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report saved to: $downloadsPath\\$fileName'),
              backgroundColor: Colors.green,
              action: SnackBarAction(label: 'Open Folder', textColor: Colors.white, onPressed: () => _openFileLocation(downloadsPath)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download report: $e'), backgroundColor: Colors.red));
    }
  }

  pw.Widget _buildPdfSummaryCards() {
    final totalUsers = _allUsers.length;
    final totalEmployers = _allEmployers.length;
    final totalApplications = _allApplications.length;
    final totalSkills = _allJobSkills.map((e) => e.skillId).toSet().length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Column(
        children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
            _buildPdfSummaryCard('Total Users', totalUsers.toString()),
            _buildPdfSummaryCard('Total Employers', totalEmployers.toString()),
          ]),
          pw.SizedBox(height: 16),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
            _buildPdfSummaryCard('Total Applications', totalApplications.toString()),
            _buildPdfSummaryCard('Unique Skills', totalSkills.toString()),
          ]),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummaryCard(String title, String value) {
    return pw.Container(
      width: 200, padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppTheme.primaryColor.value))),
      ]),
    );
  }
  
  pw.Widget _buildPdfHeader(String title) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Column(children: [
        pw.Text('ITapply - $title Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
        pw.Text('Generated on: ${DateFormat.yMMMd().format(DateTime.now())}'),
        pw.Divider(thickness: 1.5, color: PdfColors.grey),
      ]),
    );
  }
  
  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
    );
  }
  
  Future<pw.Document> _generatePdfDocument(Map<String, bool> options) async {
    final pdf = pw.Document();
    
    final userGrowthImage = options["User Growth Chart"] == true ? await _captureChart(_userGrowthChartKey) : null;
    final topEmployersImage = options["Top Employers Chart"] == true ? await _captureChart(_topEmployersChartKey) : null;
    final topSkillsImage = options["Top Skills Chart"] == true ? await _captureChart(_topSkillsChartKey) : null;
    final appTrendsImage = options["Application Trends Chart"] == true ? await _captureChart(_applicationTrendsChartKey) : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildPdfHeader("Platform"),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          if (options["Summary Cards"] == true) ...[
            pw.Header(level: 1, text: 'Platform Summary'),
            _buildPdfSummaryCards(),
            pw.SizedBox(height: 30),
          ],
          
          if (userGrowthImage != null) ...[
            pw.Header(level: 1, text: 'User Registrations (Last 6 Months)'),
            pw.Image(pw.MemoryImage(userGrowthImage), height: 250),
            pw.SizedBox(height: 20),
          ],
          if (topEmployersImage != null) ...[
            pw.Header(level: 1, text: 'Top Employers by Application Count'),
            pw.Image(pw.MemoryImage(topEmployersImage), height: 300),
            pw.SizedBox(height: 20),
          ],
          if (topSkillsImage != null) ...[
            pw.Header(level: 1, text: 'Top 10 Required Skills in Job Postings'),
            pw.Image(pw.MemoryImage(topSkillsImage), height: 300),
            pw.SizedBox(height: 20),
          ],
          if (appTrendsImage != null) ...[
            pw.Header(level: 1, text: 'Application Volume (Last 6 Months)'),
            pw.Image(pw.MemoryImage(appTrendsImage), height: 250),
            pw.SizedBox(height: 20),
          ],
        ],
      ),
    );

    return pdf;
  }

  Future<Uint8List?> _captureChart(GlobalKey key) async {
      try {
        final context = key.currentContext;
        if (context == null) return null;
        
        RenderRepaintBoundary boundary = context.findRenderObject() as RenderRepaintBoundary;
        if (boundary.debugNeedsPaint) {
          await Future.delayed(const Duration(milliseconds: 100));
          return _captureChart(key);
        }
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      } catch (e) {
        debugPrint('Error capturing chart: $e');
        return null;
      }
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
}