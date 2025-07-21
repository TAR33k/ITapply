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
import 'package:itapply_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class AdminJobPostingListScreen extends StatefulWidget {
  final int? employerId;
  final String? employerName;
  
  const AdminJobPostingListScreen({super.key, this.employerId, this.employerName});

  @override
  State<AdminJobPostingListScreen> createState() => _AdminJobPostingListScreenState();
}

class _AdminJobPostingListScreenState extends State<AdminJobPostingListScreen> {
  late JobPostingProvider _jobPostingProvider;
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  DateTime? _postedAfter;
  DateTime? _deadlineBefore;
  JobPostingStatus? _selectedStatus;

  SearchResult<JobPosting>? _pagedResult;
  bool _isLoading = true;

  int _currentPage = 0;
  int _rowsPerPage = 10;
  final _dataTableKey = GlobalKey<PaginatedDataTableState>();

  @override
  void initState() {
    super.initState();
    _jobPostingProvider = context.read<JobPostingProvider>();
    
    if (widget.employerName != null) {
      _companyController.text = widget.employerName!;
    }
    
    _fetchData();
  }

  void _performSearch() {
    setState(() {
      _currentPage = 0;
      _dataTableKey.currentState?.pageTo(0);
    });
    _fetchData();
  }

  void _clearFilters() {
    setState(() {
      _titleController.clear();
      _companyController.clear();
      _postedAfter = null;
      _deadlineBefore = null;
      _selectedStatus = null;
    });
    _performSearch();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      var searchObject = JobPostingSearchObject(
        Title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
        EmployerName: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
        EmployerId: widget.employerId,
        PostedAfter: _postedAfter,
        DeadlineBefore: _deadlineBefore,
        Status: _selectedStatus,
        IncludeExpired: true,
        Page: _currentPage,
        PageSize: _rowsPerPage,
        IncludeTotalCount: true,
      );

      var data = await _jobPostingProvider.get(filter: searchObject);
      if (mounted) setState(() => _pagedResult = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleJobStatus(JobPosting job) async {
    final newStatus = job.status == JobPostingStatus.active
        ? JobPostingStatus.closed
        : JobPostingStatus.active;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus == JobPostingStatus.closed ? 'Deactivate Posting' : 'Reactivate Posting'),
        content: Text(newStatus == JobPostingStatus.closed
            ? 'Are you sure you want to deactivate this job posting?'
            : 'Are you sure you want to reactivate this job posting?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: newStatus == JobPostingStatus.closed ? Colors.red : Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: Text(newStatus == JobPostingStatus.closed ? 'Deactivate' : 'Reactivate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _jobPostingProvider.updateStatus(job.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status updated to ${newStatus.name}"), backgroundColor: AppTheme.confirmColor),
        );
        _fetchData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "All Job Postings",
      selectedRoute: AppRouter.adminJobPostingsRoute,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _pagedResult == null
              ? const Center(child: CircularProgressIndicator())
              : _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    suffixIcon: _titleController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _titleController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(
                    labelText: "Company Name",
                    suffixIcon: _companyController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _companyController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: _postedAfter ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selected != null) {
                      setState(() => _postedAfter = selected);
                      _performSearch();
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Posted After',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _postedAfter = null);
                          _performSearch();
                        },
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(_postedAfter != null
                        ? DateFormat.yMMMd().format(_postedAfter!)
                        : 'Select Date'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: _deadlineBefore ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selected != null) {
                      setState(() => _deadlineBefore = selected);
                      _performSearch();
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Deadline Before',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _deadlineBefore = null);
                          _performSearch();
                        },
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(_deadlineBefore != null
                        ? DateFormat.yMMMd().format(_deadlineBefore!)
                        : 'Select Date'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<JobPostingStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Status",
                    suffixIcon: _selectedStatus != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _selectedStatus = null);
                              _performSearch();
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() => _selectedStatus = val);
                    _performSearch();
                  },
                  items: JobPostingStatus.values.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(jobPostingStatusToString(e)),
                    );
                  }).toList(),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () async {
                  final result = await Navigator.pushNamed(context, AppRouter.adminJobPostingDetailsRoute);
                  if (result == true) _performSearch();
                },
                icon: const Icon(Icons.add),
                label: const Text("New Posting"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _performSearch,
                icon: const Icon(Icons.search),
                label: const Text("Search"),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text("Clear Filters"),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final dataSource = _JobPostingDataSource(
      jobPostings: _pagedResult?.items ?? [],
      totalRowCount: _pagedResult?.totalCount ?? 0,
      firstRowIndexOnPage: _currentPage * _rowsPerPage,
      isLoading: _isLoading,
      onEdit: (job) async {
        final result = await Navigator.pushNamed(context, AppRouter.adminJobPostingDetailsRoute, arguments: job);
        if (result == true) _fetchData();
      },
      onToggleStatus: _toggleJobStatus,
      onViewApplications: (_) {},
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: PaginatedDataTable(
        key: _dataTableKey,
        header: const Text('Job Postings'),
        columns: const [
          DataColumn(label: Text("Position")),
          DataColumn(label: Text("Company")),
          DataColumn(label: Text("Posted Date")),
          DataColumn(label: Text("Deadline")),
          DataColumn(label: Text("Applications")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Actions")),
        ],
        source: dataSource,
        rowsPerPage: _rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        onRowsPerPageChanged: _isLoading ? null : (value) {
          if (value != null) {
            setState(() {
              _rowsPerPage = value;
              _currentPage = 0;
            });
            _fetchData();
          }
        },
        onPageChanged: _isLoading ? null : (pageIndex) {
          final newPage = pageIndex ~/ _rowsPerPage;
          if (newPage != _currentPage) {
            setState(() => _currentPage = newPage);
            _fetchData();
          }
        },
        dataRowHeight: 48,
        columnSpacing: 20,
      ),
    );
  }
}

class _JobPostingDataSource extends DataTableSource {
  final List<JobPosting> jobPostings;
  final int totalRowCount;
  final Function(JobPosting) onEdit;
  final Function(JobPosting) onToggleStatus;
  final Function(JobPosting) onViewApplications;
  final int firstRowIndexOnPage;
  final bool isLoading;

  _JobPostingDataSource({
    required this.jobPostings,
    required this.totalRowCount,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onViewApplications,
    required this.firstRowIndexOnPage,
    required this.isLoading,
  });

  @override
  DataRow? getRow(int index) {
    final int localIndex = index - firstRowIndexOnPage;

    if (localIndex < 0 || localIndex >= jobPostings.length) {
      return null;
    }
    final job = jobPostings[localIndex];
    final status = jobPostingStatusToString(job.status);
    final statusColor = jobPostingStatusColor(job.status);

    return DataRow(
      cells: [
        DataCell(Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(job.employerName)),
        DataCell(Text(DateFormat.yMMMd().format(job.postedDate))),
        DataCell(Text(DateFormat.yMMMd().format(job.applicationDeadline))),
        DataCell(Center(child: Text(job.applicationCount.toString()))),
        DataCell(Chip(
          label: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          backgroundColor: statusColor.withOpacity(0.15),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.people_alt_outlined), tooltip: "View Applications", onPressed: isLoading ? null : () => onViewApplications(job)),
            IconButton(icon: const Icon(Icons.edit_outlined), tooltip: "Edit Posting", onPressed: isLoading ? null : () => onEdit(job)),
            IconButton(
              icon: Icon(job.status == JobPostingStatus.active ? Icons.pause_circle_outline : Icons.play_circle_outline, color: job.status == JobPostingStatus.active ? Colors.red.shade400 : Colors.green.shade600),
              tooltip: job.status == JobPostingStatus.active ? "Deactivate" : "Reactivate",
              onPressed: isLoading ? null : () => onToggleStatus(job),
            ),
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => totalRowCount;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
