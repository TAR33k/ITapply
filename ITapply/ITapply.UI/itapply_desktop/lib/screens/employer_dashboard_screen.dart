import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
import 'package:itapply_desktop/widgets/stat_card.dart';
import 'package:provider/provider.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  bool _isLoading = true;
  String? _error;

  String companyName = "Company";
  int _activeListingsCount = 0;
  int _newApplicationsCount = 0;
  int _totalApplicationsCount = 0;
  List<Application> _recentApplications = [];
  List<JobPosting> _activeJobPostings = [];
  List<BarChartGroupData> _chartData = [];
  List<String> _chartDailyLabels = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final employerId = authProvider.currentEmployer?.id;

      if (employerId == null) {
        throw Exception("Employer not found. Please log in again.");
      }

      companyName = context.read<AuthProvider>().currentEmployer!.companyName;

      final results = await Future.wait([
        context.read<ApplicationProvider>().get(
            filter: ApplicationSearchObject(
                EmployerId: employerId, RetrieveAll: true)),
        context.read<JobPostingProvider>().get(
            filter: JobPostingSearchObject(
                EmployerId: employerId,
                Status: JobPostingStatus.active,
                RetrieveAll: true)),
      ]);

      if (mounted) {
        final List<Application> allApplications = results[0].items as List<Application>;
        final List<JobPosting> allActiveJobs = results[1].items as List<JobPosting>;

        _totalApplicationsCount = allApplications.length;
        _activeListingsCount = allActiveJobs.length;

        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        _newApplicationsCount = allApplications
            .where((app) => app.applicationDate.isAfter(sevenDaysAgo) && app.status == ApplicationStatus.applied)
            .length;

        _recentApplications = allApplications
            .toList()
            ..sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
        _recentApplications = _recentApplications.take(5).toList();
                _activeJobPostings = allActiveJobs.take(5).toList();

        _activeJobPostings = allActiveJobs
            .toList()
            ..sort((a, b) => b.postedDate.compareTo(a.postedDate));
        _activeJobPostings = _activeJobPostings.take(5).toList();

        _chartData = _generateChartData(allApplications);

        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  List<BarChartGroupData> _generateChartData(List<Application> applications) {
    final Map<String, int> dailyCounts = {};
    final today = DateTime.now();
    _chartDailyLabels = [];

    for (int i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      dailyCounts[dayKey] = 0;
    }

    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    for (var app in applications) {
      if (app.applicationDate.isAfter(thirtyDaysAgo)) {
        final key = DateFormat('yyyy-MM-dd').format(app.applicationDate);
        if (dailyCounts.containsKey(key)) {
          dailyCounts[key] = dailyCounts[key]! + 1;
        }
      }
    }
    
    _chartDailyLabels = dailyCounts.keys.map((key) => DateFormat('dd/MMM').format(DateTime.parse(key))).toList();

    int index = 0;
    return dailyCounts.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: AppTheme.primaryColor,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          )
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Employer Dashboard",
      selectedRoute: AppRouter.employerDashboardRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildDashboardContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text("Failed to load dashboard", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchDashboardData, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeMessage(),
        const SizedBox(height: 12),
        _buildStatsGrid(),
        const SizedBox(height: 24),
        _buildPerformanceChart(),
        const SizedBox(height: 24),
        _buildRecentApplicationsTable(),
        const SizedBox(height: 24),
        _buildActivePostingsTable(),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Welcome to your dashboard, $companyName!",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / 300).floor();
        return GridView.count(
          crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            StatCard(title: "Active Job Postings", value: _activeListingsCount.toString(), icon: Icons.work_outline, color: Colors.blue, onTap: () => Navigator.pushNamed(context, AppRouter.employerJobPostingsRoute)),
            StatCard(title: "New Applications (7d)", value: _newApplicationsCount.toString(), icon: Icons.file_copy_outlined, color: Colors.orange),
            StatCard(title: "Total Applications", value: _totalApplicationsCount.toString(), icon: Icons.people_outline, color: Colors.green, onTap: () => Navigator.pushNamed(context, AppRouter.employerApplicationsRoute)),
          ],
        );
      },
    );
  }
  
  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Applications per Day (Last 30 Days)", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${_chartDailyLabels[groupIndex]}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                              text: rod.toY.round().toString(),
                              style: const TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _calculateLabelInterval(context),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _chartDailyLabels.length) {
                            return Padding(padding: EdgeInsetsDirectional.only(top: 10.0),
                            child: Transform.rotate(
                              angle: -math.pi / 4,
                              child: Text(
                                _chartDailyLabels[index],
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => (value % 1 == 0) ? Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)) : const SizedBox.shrink())),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                  borderData: FlBorderData(show: false),
                  barGroups: _chartData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateLabelInterval(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 900) {
      return 3.0;
    } else {
      return 1.0;
    }
  }

  Widget _buildRecentApplicationsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Applications", style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () => Navigator.pushNamed(context, AppRouter.employerApplicationsRoute), child: const Text("View All"))
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Candidate")),
                  DataColumn(label: Text("Job Title")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: _recentApplications.map((app) => DataRow(cells: [
                  DataCell(Text(app.candidateName ?? 'N/A')),
                  DataCell(Text(app.jobTitle ?? 'N/A')),
                  DataCell(Text(DateFormat.yMMMd().format(app.applicationDate))),
                  DataCell(Chip(
                    label: Text(applicationStatusToString(app.status), style: TextStyle(color: applicationStatusColor(app.status), fontWeight: FontWeight.bold)),
                    backgroundColor: applicationStatusColor(app.status).withOpacity(0.15),
                    side: BorderSide.none,
                  )),
                  DataCell(IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.employerApplicationDetailsRoute, arguments: app);
                    },
                    tooltip: "View Application",
                  )),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePostingsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Job Postings", style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () => {
                  Navigator.pushReplacementNamed(context, AppRouter.employerJobPostingsRoute),
                }, child: const Text("View All"))
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Title", style: TextStyle(fontSize: 14))),
                  DataColumn(label: Text("Posted Date", style: TextStyle(fontSize: 14))),
                  DataColumn(label: Text("Deadline Date", style: TextStyle(fontSize: 14))),
                  DataColumn(label: Text("Applications", style: TextStyle(fontSize: 14))),
                  DataColumn(label: Text("Status", style: TextStyle(fontSize: 14))),
                  DataColumn(label: Text("Actions", style: TextStyle(fontSize: 14))),
                ],
                rows: _activeJobPostings.map((job) => DataRow(cells: [
                  DataCell(Text(job.title)),
                  DataCell(Text(DateFormat.yMMMd().format(job.postedDate))),
                  DataCell(Text(DateFormat.yMMMd().format(job.applicationDeadline))),
                  DataCell(Text(job.applicationCount.toString())),
                  DataCell(Chip(
                    label: Text(jobPostingStatusToString(job.status), style: TextStyle(color: jobPostingStatusColor(job.status), fontWeight: FontWeight.bold)),
                    backgroundColor: jobPostingStatusColor(job.status).withOpacity(0.15),
                    side: BorderSide.none,
                  )),
                  DataCell(Row(
                    children: [
                      IconButton(icon: const Icon(Icons.people_alt_outlined), tooltip: "View Applications", onPressed: () => Navigator.pushNamed(context, AppRouter.employerApplicationsRoute, arguments: job)),
                      IconButton(icon: const Icon(Icons.edit_outlined), tooltip: "Edit Posting", onPressed: () => Navigator.pushNamed(context, AppRouter.employerJobPostingDetailsRoute, arguments: job)),
                    ],
                  )),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}