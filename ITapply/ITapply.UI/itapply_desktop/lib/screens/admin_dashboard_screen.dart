import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/review.dart';
import 'package:itapply_desktop/models/search_objects/employer_search_object.dart';
import 'package:itapply_desktop/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_desktop/models/search_objects/review_search_object.dart';
import 'package:itapply_desktop/models/search_objects/user_search_object.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/review_provider.dart';
import 'package:itapply_desktop/providers/user_provider.dart';
import 'package:itapply_desktop/screens/admin_user_management_screen.dart';
import 'package:itapply_desktop/widgets/stat_card.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  String? _error;

  int _totalUsers = 0;
  int _activeCompanies = 0;
  int _activeJobs = 0;
  int _totalReviews = 0;
  List<Employer> _pendingCompanies = [];
  List<Review> _recentReviews = [];
  Map<String, int> _topSkills = {};

  @override
  void initState() {
    super.initState();
    _fetchAdminDashboardData();
  }

  Future<void> _fetchAdminDashboardData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final results = await Future.wait([
        context.read<UserProvider>().get(filter: UserSearchObject(RetrieveAll: true)),
        context.read<EmployerProvider>().get(filter: EmployerSearchObject(RetrieveAll: true)),
        context.read<JobPostingProvider>().get(filter: JobPostingSearchObject(RetrieveAll: true)),
        context.read<ReviewProvider>().get(filter: ReviewSearchObject(RetrieveAll: true, PageSize: 5)),
      ]);

      if (mounted) {
        final allUsers = results[0].items;
        final allEmployers = results[1].items as List<Employer>;
        final allJobs = results[2].items as List<JobPosting>;
        final recentReviews = results[3].items as List<Review>;

        _totalUsers = allUsers!.length;
        _activeCompanies = allEmployers.where((e) => e.verificationStatus == VerificationStatus.approved).length;
        _activeJobs = allJobs.where((j) => j.status == JobPostingStatus.active).length;
        _totalReviews = results[3].totalCount ?? recentReviews.length;

        _pendingCompanies = allEmployers
            .where((e) => e.verificationStatus == VerificationStatus.pending)
            .take(5)
            .toList();
        
        _recentReviews = recentReviews;

        _calculateTopSkills(allJobs);

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

  void _calculateTopSkills(List<JobPosting> allJobs) {
    Map<String, int> skillCounts = {};
    for (var job in allJobs) {
      for (var skill in job.skills) {
        if (skill.skillName != null) {
          skillCounts[skill.skillName!] = (skillCounts[skill.skillName] ?? 0) + 1;
        }
      }
    }
    var sortedSkills = skillCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    _topSkills = Map.fromEntries(sortedSkills.take(5));
  }
  
  Future<void> _handleVerification(int companyId, VerificationStatus newStatus) async {
    final isApproval = newStatus == VerificationStatus.approved;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproval ? 'Approve Company' : 'Reject Company'),
        content: Text(isApproval
            ? 'Are you sure you want to approve this company? It will be allowed to post jobs on the platform.'
            : 'Are you sure you want to reject this company? They will be blocked from posting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? Colors.green : Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isApproval ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<EmployerProvider>().updateVerificationStatus(companyId, newStatus);
      _fetchAdminDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Administrator Dashboard",
      selectedRoute: AppRouter.adminDashboardRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsGrid(),
        const SizedBox(height: 24),
        (_pendingCompanies.isNotEmpty) ? 
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildVerificationsTable()),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: _buildTopSkillsChart()),
          ],
        ) : 
        _buildTopSkillsChart(),
        const SizedBox(height: 24),
        _buildRecentReviewsTable(),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / 280).floor();
        return GridView.count(
          crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            StatCard(title: "Total Users", value: _totalUsers.toString(), icon: Icons.group_outlined, color: Colors.blue, onTap: () => Navigator.pushNamed(context, AppRouter.adminUserManagementRoute)),
            StatCard(title: "Active Companies", value: _activeCompanies.toString(), icon: Icons.business_center_outlined, color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminUserManagementScreen(startingIndex: 2)))),
            StatCard(title: "Active Job Postings", value: _activeJobs.toString(), icon: Icons.work_outline, color: Colors.orange, onTap: () => Navigator.pushNamed(context, AppRouter.adminJobPostingsRoute)),
            StatCard(title: "Total Reviews", value: _totalReviews.toString(), icon: Icons.rate_review_outlined, color: Colors.purple, onTap: () => Navigator.pushNamed(context, AppRouter.adminReviewsRoute)),
          ],
        );
      },
    );
  }

  Widget _buildTopSkillsChart() {
    final totalSkillMentions = _topSkills.values.fold(0, (prev, element) => prev + element);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Most Wanted Skills", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            if (_topSkills.isEmpty)
              const Center(child: Text("Not enough data to show top skills.")),
            ..._topSkills.entries.map((entry) {
              final percentage = totalSkillMentions > 0 ? entry.value / totalSkillMentions : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text("${(percentage * 100).toStringAsFixed(0)}%"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearPercentIndicator(
                      percent: percentage,
                      lineHeight: 10,
                      backgroundColor: AppTheme.grayColor,
                      progressColor: AppTheme.primaryColor,
                      barRadius: const Radius.circular(5),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pending Company Verifications", style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminUserManagementScreen(startingIndex: 2)));
                }, child: const Text("View All"))
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Company")),
                  DataColumn(label: Text("Submitted On")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: _pendingCompanies.map((company) => DataRow(cells: [
                  DataCell(Text(company.companyName)),
                  DataCell(Text(DateFormat.yMMMd().format(company.registrationDate))),
                  DataCell(Row(children: [
                    IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.green), tooltip: "Approve", onPressed: () => _handleVerification(company.id, VerificationStatus.approved)),
                    IconButton(icon: const Icon(Icons.highlight_off_outlined, color: Colors.red), tooltip: "Reject", onPressed: () => _handleVerification(company.id, VerificationStatus.rejected)),
                    IconButton(icon: const Icon(Icons.visibility_outlined, color: Colors.grey), tooltip: "View Details", onPressed: () async {
                      final result = await Navigator.pushNamed(
                          context, AppRouter.adminEmployerDetailsRoute,
                          arguments: company);
                      if (result == true) {
                        await _fetchAdminDashboardData();
                      }
                    }),
                  ])),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReviewsTable() {
     return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Reviews", style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () {
                  Navigator.pushNamed(context, AppRouter.adminReviewsRoute);
                }, child: const Text("View All"))
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Company")),
                  DataColumn(label: Text("Author")),
                  DataColumn(label: Text("Rating")),
                  DataColumn(label: Text("Comment")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: _recentReviews.map((review) => DataRow(cells: [
                  DataCell(Text(review.companyName ?? 'N/A')),
                  DataCell(Text(review.candidateName ?? 'N/A')),
                  DataCell(Row(children: List.generate(5, (index) => Icon(index < review.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)))),
                  DataCell(SizedBox(width: 200, child: Text(review.comment ?? '', overflow: TextOverflow.ellipsis))),
                  DataCell(IconButton(icon: const Icon(Icons.visibility_outlined), tooltip: "View & Moderate", onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.adminReviewsRoute,
                      arguments: {
                        'review': review,
                      },
                    );
                  })),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}