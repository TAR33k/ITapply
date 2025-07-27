import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/application.dart';
import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/search_objects/application_search_object.dart';
import 'package:itapply_desktop/models/search_objects/job_posting_search_object.dart';
import 'package:itapply_desktop/models/search_result.dart';
import 'package:itapply_desktop/providers/application_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/widgets/form_builder_searchable_job_posting.dart';
import 'package:provider/provider.dart';

class AdminApplicationListScreen extends StatefulWidget {
  final JobPosting? initialJobPostingFilter;
  final Candidate? initialCandidateFilter;

  const AdminApplicationListScreen({super.key, this.initialJobPostingFilter, this.initialCandidateFilter});

  @override
  State<AdminApplicationListScreen> createState() =>
      _AdminApplicationListScreenState();
}

class _AdminApplicationListScreenState
    extends State<AdminApplicationListScreen> {
  late ApplicationProvider _applicationProvider;
  late JobPostingProvider _jobPostingProvider;

  final _candidateSearchController = TextEditingController();
  final _employerSearchController = TextEditingController();

  SearchResult<Application>? _pagedResult;
  List<JobPosting> _jobPostings = [];
  bool _isLoading = true;

  int _currentPage = 0;
  final int _rowsPerPage = 10;

  JobPosting? _selectedJobPosting;
  Candidate? _selectedCandidate;
  ApplicationStatus? _selectedStatus;
  String? _candidateNameFilter;
  String? _employerNameFilter;

  final _dataTableKey = GlobalKey<PaginatedDataTableState>();

  @override
  void initState() {
    super.initState();
    _applicationProvider = context.read<ApplicationProvider>();
    _jobPostingProvider = context.read<JobPostingProvider>();

    if (widget.initialJobPostingFilter != null) {
      _selectedJobPosting = widget.initialJobPostingFilter;
    }

    if (widget.initialCandidateFilter != null) {
      _selectedCandidate = widget.initialCandidateFilter;
      _candidateSearchController.text = "${_selectedCandidate!.firstName} ${_selectedCandidate!.lastName}";
    }

    _fetchInitialData();
  }

  @override
  void dispose() {
    _candidateSearchController.dispose();
    _employerSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchJobPostings();
    await _fetchApplications();
  }

  Future<void> _fetchJobPostings() async {
    try {
      final result = await _jobPostingProvider.get(
        filter: JobPostingSearchObject(RetrieveAll: true),
      );
      if (mounted) setState(() => _jobPostings = result.items as List<JobPosting>);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error fetching job postings: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchApplications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      var searchObject = ApplicationSearchObject(
        JobPostingId: _selectedJobPosting?.id,
        CandidateId: _selectedCandidate?.id,
        Status: _selectedStatus,
        CandidateName: _candidateNameFilter?.trim().isNotEmpty == true
            ? _candidateNameFilter!.trim()
            : null,
        CompanyName: _employerNameFilter?.trim().isNotEmpty == true
            ? _employerNameFilter!.trim()
            : null,
        Page: _currentPage,
        PageSize: _rowsPerPage,
        IncludeTotalCount: true,
      );

      var data = await _applicationProvider.get(filter: searchObject);
      if (mounted) {
        data.items!.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
        setState(() => _pagedResult = data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error fetching applications: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _performSearch() {
    setState(() {
      _currentPage = 0;
      _dataTableKey.currentState?.pageTo(0);
      _candidateNameFilter = _candidateSearchController.text;
      _employerNameFilter = _employerSearchController.text;
    });
    _fetchApplications();
  }

  void _clearFilters() {
    setState(() {
      _selectedJobPosting = null;
      _selectedCandidate = null;
      _selectedStatus = null;
      _candidateNameFilter = null;
      _employerNameFilter = null;
      _candidateSearchController.clear();
      _employerSearchController.clear();
      _currentPage = 0;
    });
    _fetchApplications();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "All Platform Applications",
      selectedRoute: AppRouter.adminApplicationsRoute,
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
                  child: TextField(
                    controller: _candidateSearchController,
                    decoration: const InputDecoration(labelText: "Search by candidate name", prefixIcon: Icon(Icons.person_search), border: OutlineInputBorder()),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _employerSearchController,
                    decoration: const InputDecoration(labelText: "Search by company name", prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<ApplicationStatus?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: "Filter by status", border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("All statuses")),
                      ...ApplicationStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(applicationStatusToString(s)))),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
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
                  child: FormBuilderSearchableJobPosting(
                    jobPostings: _jobPostings,
                    selectedJobPosting: _selectedJobPosting,
                    labelText: "Filter by job posting",
                    onChanged: (jobPosting) {
                      setState(() => _selectedJobPosting = jobPosting);
                      _performSearch();
                    },
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(onPressed: _performSearch, icon: const Icon(Icons.search), label: const Text("Search")),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: _clearFilters, icon: const Icon(Icons.clear), label: const Text("Clear")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final dataSource = _ApplicationDataSource(
      applications: _pagedResult!.items as List<Application>,
      totalRowCount: _pagedResult!.totalCount!,
      onViewDetails: (application) async {
        final result = await Navigator.pushNamed(context, AppRouter.adminApplicationDetailsRoute, arguments: application);
        if (result == true) {
          _fetchApplications();
        }
      },
      firstRowIndexOnPage: _currentPage * _rowsPerPage,
      isLoading: _isLoading,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: PaginatedDataTable(
        key: _dataTableKey,
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("All Applications", style: Theme.of(context).textTheme.titleLarge),
            Text("${_pagedResult!.totalCount} total applications", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        columns: const [
          DataColumn(label: Text("Candidate")),
          DataColumn(label: Text("Company")),
          DataColumn(label: Text("Job Applied For")),
          DataColumn(label: Text("Application Date")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Actions")),
        ],
        source: dataSource,
        rowsPerPage: _rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        onRowsPerPageChanged: null,
        onPageChanged: _isLoading ? null : (pageIndex) {
          final newPage = pageIndex ~/ _rowsPerPage;
          if (newPage != _currentPage) {
            setState(() => _currentPage = newPage);
            _fetchApplications();
          }
        },
        dataRowHeight: 52,
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

  _ApplicationDataSource({
    required this.applications,
    required this.totalRowCount,
    required this.onViewDetails,
    required this.firstRowIndexOnPage,
    required this.isLoading,
  });

  @override
  DataRow? getRow(int index) {
    final int localIndex = index - firstRowIndexOnPage;
    if (localIndex < 0 || localIndex >= applications.length) return null;
    
    final application = applications[localIndex];
    return DataRow(
      cells: [
        DataCell(Text(application.candidateName ?? 'N/A')),
        DataCell(Text(application.companyName ?? 'N/A')),
        DataCell(Text(application.jobTitle ?? 'N/A')),
        DataCell(Text(DateFormat.yMMMd().format(application.applicationDate))),
        DataCell(
          Chip(
            label: Text(
              applicationStatusToString(application.status),
              style: TextStyle(color: applicationStatusColor(application.status), fontWeight: FontWeight.bold),
            ),
            backgroundColor: applicationStatusColor(application.status).withOpacity(0.15),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        ),
        DataCell(IconButton(
          icon: const Icon(Icons.visibility_outlined),
          tooltip: "View Details",
          onPressed: isLoading ? null : () => onViewDetails(application),
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