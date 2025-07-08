import 'package:flutter/material.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/model/job_posting.dart';
import 'package:itapply_desktop/model/search_result.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/screens/job_posting_details.dart';
import 'package:provider/provider.dart';

class JobPostingList extends StatefulWidget {
  const JobPostingList({super.key});

  @override
  State<JobPostingList> createState() => _JobPostingListState();
}

class _JobPostingListState extends State<JobPostingList> {
  late JobPostingProvider _jobPostingProvider;
  final _searchController = TextEditingController();
  SearchResult<JobPosting>? _jobPostings;
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
      var filter;
      if (_searchController.text.trim().isNotEmpty) {
        filter = {"Title": _searchController.text.trim()};
      }
      var data = await _jobPostingProvider.get(filter: filter);
      setState(() {
        _jobPostings = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching data: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Job Postings",
      selectedRoute: AppRouter.jobPostingsRoute,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchAndActions(),
          const SizedBox(height: 24),
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobPostingDetailsScreen()),
                );
                if (result == true) {
                  _fetchData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("New Posting"),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
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
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Title")),
            DataColumn(label: Text("Employer")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Actions")),
          ],
          rows: _isLoading
              ? [const DataRow(cells: [DataCell(Text("")), DataCell(Center(child: CircularProgressIndicator())), DataCell(Text("")), DataCell(Text(""))])]
              : _jobPostings?.items?.map((job) => DataRow(
                    cells: [
                      DataCell(Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(job.employerName)),
                      DataCell(_buildStatusChip(job.status)),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                          onPressed: () async {
                             final result = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) => JobPostingDetailsScreen(jobPosting: job),
                            ));
                            if(result == true) {
                              _fetchData();
                            }
                          },
                        ),
                      ),
                    ],
                  )).toList() ?? [const DataRow(cells: [DataCell(Text("No data found")), DataCell(Text("")), DataCell(Text("")), DataCell(Text(""))])],
        ),
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color color;
    String text;
    switch (status) {
      case 0:
        color = Colors.green;
        text = "Active";
        break;
      case 1:
        color = Colors.grey;
        text = "Inactive";
        break;
      case 2:
        color = Colors.red;
        text = "Closed";
        break;
      default:
        color = Colors.orange;
        text = "Draft";
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