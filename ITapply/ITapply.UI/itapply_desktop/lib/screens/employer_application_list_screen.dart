import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/application.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/search_objects/application_search_object.dart';
import 'package:itapply_desktop/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_desktop/models/search_result.dart';
import 'package:itapply_desktop/providers/application_provider.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/widgets/form_builder_searchable_job_posting.dart';
import 'package:provider/provider.dart';

class EmployerApplicationListScreen extends StatefulWidget {
  final JobPosting? initialJobPostingFilter;
  
  const EmployerApplicationListScreen({super.key, this.initialJobPostingFilter});

  @override
  State<EmployerApplicationListScreen> createState() => _EmployerApplicationListScreenState();
}

class _EmployerApplicationListScreenState extends State<EmployerApplicationListScreen> {
  late ApplicationProvider _applicationProvider;
  late JobPostingProvider _jobPostingProvider;
  
  final _searchController = TextEditingController();
  SearchResult<Application>? _pagedResult;
  List<JobPosting> _jobPostings = [];
  bool _isLoading = true;

  int _currentPage = 0;
  int _rowsPerPage = 10;
  
  JobPosting? _selectedJobPosting; 
  ApplicationStatus? _selectedStatus;
  String? _candidateNameFilter;

  final _dataTableKey = GlobalKey<PaginatedDataTableState>();

  @override
  void initState() {
    super.initState();
    _applicationProvider = context.read<ApplicationProvider>();
    _jobPostingProvider = context.read<JobPostingProvider>();

    if (widget.initialJobPostingFilter != null) {
      _selectedJobPosting = widget.initialJobPostingFilter;
    }

    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchJobPostings();
    await _fetchApplications();
  }

  Future<void> _fetchJobPostings() async {
    try {
      final employerId = context.read<AuthProvider>().currentEmployer?.id;
      if (employerId == null) throw Exception("Not logged in as an employer.");

      final result = await _jobPostingProvider.get(
        filter: JobPostingSearchObject(
          EmployerId: employerId,
          RetrieveAll: true,
        ),
      );
      
      if (mounted) {
        setState(() {
          _jobPostings = result.items ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching job postings: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _performSearch() {
    setState(() {
      _currentPage = 0;
      _dataTableKey.currentState?.pageTo(0);
    });
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final employerId = context.read<AuthProvider>().currentEmployer?.id;
      if (employerId == null) throw Exception("Not logged in as an employer.");

      var searchObject = ApplicationSearchObject(
        EmployerId: employerId,
        JobPostingId: _selectedJobPosting?.id, 
        Status: _selectedStatus,
        CandidateName: _candidateNameFilter?.trim().isNotEmpty == true ? _candidateNameFilter!.trim() : null,
        Page: _currentPage,
        PageSize: _rowsPerPage,
        IncludeTotalCount: true,
      );
      
      var data = await _applicationProvider.get(filter: searchObject);
      if (mounted) {
        if (data.items != null) {
          data.items!.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
        }
        setState(() {
          _pagedResult = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching applications: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedJobPosting = null; 
      _selectedStatus = null;
      _candidateNameFilter = null;
      _searchController.clear();
      _currentPage = 0;
    });
    _fetchApplications();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Application Management",
      selectedRoute: AppRouter.employerApplicationsRoute,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchAndFilters(),
          const SizedBox(height: 16),
          _pagedResult == null
              ? const Center(child: CircularProgressIndicator())
              : _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Search & Filter Applications", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Search by candidate name",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _candidateNameFilter = value;
                    },
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<ApplicationStatus?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Filter by status",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<ApplicationStatus?>(
                        value: null,
                        child: Text("All statuses"),
                      ),
                      ...ApplicationStatus.values.map((status) => DropdownMenuItem<ApplicationStatus?>(
                        value: status,
                        child: Text(applicationStatusToString(status)),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _performSearch();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FormBuilderSearchableJobPosting(
                    jobPostings: _jobPostings,
                    selectedJobPosting: _selectedJobPosting,
                    labelText: "Filter by job posting",
                    onChanged: (jobPosting) {
                      setState(() {
                        _selectedJobPosting = jobPosting;
                      });
                      _performSearch();
                    },
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text("Search"),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final dataSource = _ApplicationDataSource(
      applications: _pagedResult!.items ?? [],
      totalRowCount: _pagedResult!.totalCount ?? 0,
      onViewDetails: (application) async {
        final result = await Navigator.pushNamed(
          context,
          AppRouter.employerApplicationDetailsRoute,
          arguments: application,
        );

        if (result == true) {
          _fetchApplications();
        }
      },
      firstRowIndexOnPage: _currentPage * _rowsPerPage,
      isLoading: _isLoading,
      context: context,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: PaginatedDataTable(
        key: _dataTableKey,
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("All Applications", style: Theme.of(context).textTheme.titleLarge),
            if (_pagedResult!.totalCount != null)
              Text("${_pagedResult!.totalCount} total applications", 
                   style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        columns: const [
          DataColumn(label: Text("Candidate")),
          DataColumn(label: Text("Job Applied For")),
          DataColumn(label: Text("Application Date")),
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
            _fetchApplications();
          }
        },
        onPageChanged: _isLoading ? null : (pageIndex) {
          final newPage = pageIndex ~/ _rowsPerPage;
          if (newPage != _currentPage) {
            setState(() => _currentPage = newPage);
            _fetchApplications();
          }
        },
        dataRowHeight: 48,
        columnSpacing: 20,
      ),
    );
  }
}

class _ApplicationDataSource extends DataTableSource {
  final List<Application> applications;
  final int totalRowCount;
  final Function(Application) onViewDetails;
  final int firstRowIndexOnPage;
  final bool isLoading;
  final BuildContext context;

  _ApplicationDataSource({
    required this.applications,
    required this.totalRowCount,
    required this.onViewDetails,
    required this.firstRowIndexOnPage,
    required this.isLoading,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    final int localIndex = index - firstRowIndexOnPage;

    if (localIndex < 0 || localIndex >= applications.length) {
      return null;
    }
    
    final application = applications[localIndex];
    final status = applicationStatusToString(application.status);
    final statusColor = applicationStatusColor(application.status);

    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                application.candidateName ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (application.candidateEmail != null)
                Text(
                  application.candidateEmail!,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        DataCell(Text(application.jobTitle ?? 'N/A')),
        DataCell(Text(DateFormat.yMMMd().format(application.applicationDate))),
        DataCell(
          Chip(
            label: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: statusColor.withOpacity(0.15),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: "View Details",
            onPressed: isLoading ? null : () => onViewDetails(application),
          ),
        ),
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
