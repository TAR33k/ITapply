import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_desktop/models/search_result.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:provider/provider.dart';

class JobPostingList extends StatefulWidget {
  const JobPostingList({super.key});

  @override
  State<JobPostingList> createState() => _JobPostingListState();
}

class _JobPostingListState extends State<JobPostingList> {
  late JobPostingProvider _jobPostingProvider;
  final _searchController = TextEditingController();
  SearchResult<JobPosting>? _pagedResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _jobPostingProvider = context.read<JobPostingProvider>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      var searchObject = JobPostingSearchObject(
        Title: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
        IncludeExpired: true,
        IncludeTotalCount: true,
        RetrieveAll: true,
      );
      var data = await _jobPostingProvider.get(filter: searchObject);
      setState(() {
        _pagedResult = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error fetching data: $e"),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Job Postings",
      selectedRoute: AppRouter.adminJobPostingsRoute,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchAndActions(),
          const SizedBox(height: 16),
          _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Search by title...",
                  prefixIcon: Icon(Icons.search),
                ),
                onFieldSubmitted: (_) => _fetchData(),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.search),
              label: const Text("Search"),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AppRouter.jobPostingDetailsRoute,
                );
                if (result == true && mounted) {
                  _fetchData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("New Posting"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          header: const Text('Job Postings'),
          columns: const [
            DataColumn(label: Text("Title")),
            DataColumn(label: Text("Employer")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Deadline")),
            DataColumn(label: Text("Actions")),
          ],
          source: _JobPostingDataSource(
            jobPostings: _pagedResult?.items ?? [],
            onEdit: (job) async {
              final result = await Navigator.pushNamed(
                context,
                AppRouter.jobPostingDetailsRoute,
                arguments: job,
              );
              if (result == true && mounted) {
                _fetchData();
              }
            },
          ),
          rowsPerPage: 10,
        ),
      ),
    );
  }
}

class _JobPostingDataSource extends DataTableSource {
  final List<JobPosting> jobPostings;
  final Function(JobPosting) onEdit;

  _JobPostingDataSource({required this.jobPostings, required this.onEdit});

  @override
  DataRow? getRow(int index) {
    if (index >= jobPostings.length) {
      return null;
    }
    final job = jobPostings[index];
    return DataRow(cells: [
      DataCell(Text(job.title,
          style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(job.employerName)),
      DataCell(_buildStatusChip(job.status)),
      DataCell(Text(DateFormat.yMMMd().format(job.applicationDeadline))),
      DataCell(
        IconButton(
          icon: Icon(Icons.edit_outlined,
              color: AppTheme.primaryColor),
          onPressed: () => onEdit(job),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => jobPostings.length;

  @override
  int get selectedRowCount => 0;

  Widget _buildStatusChip(JobPostingStatus status) {
    Color color;
    String text;
    switch (status) {
      case JobPostingStatus.active:
        color = Colors.green;
        text = "Active";
        break;
      case JobPostingStatus.closed:
        color = Colors.red;
        text = "Closed";
        break;
    }
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}