import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:intl/intl.dart';
import 'package:itapply_mobile/providers/job_posting_provider.dart';
import 'package:provider/provider.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/models/application.dart';
import 'package:itapply_mobile/models/employer.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/search_objects/application_search_object.dart';

import 'package:itapply_mobile/providers/application_provider.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:itapply_mobile/providers/utils.dart';
import 'package:itapply_mobile/widgets/application_card.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _companySearchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();
  
  // ignore: prefer_final_fields
  Map<int, Employer> _employerCache = {};
  // ignore: prefer_final_fields
  Map<int, int> _jobToEmployerIdCache = {};

  bool _showFilters = false;
  List<Application> _applications = [];
  
  String _searchQuery = '';
  String _companySearchQuery = '';
  ApplicationStatus? _selectedStatus;
  DateTime? _applicationDateFrom;
  DateTime? _applicationDateTo;
  
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _totalCount = 0;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _companySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadApplications(reset: true);
  }

  Future<void> _loadApplications({bool reset = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _currentPage = 1;
        _applications.clear();
        _hasMoreData = true;
      }
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentCandidate = authProvider.currentCandidate;
      
      if (currentCandidate == null) {
        throw Exception("User is not logged in or is not a candidate.");
      }

      final searchObject = ApplicationSearchObject(
        CandidateId: currentCandidate.id,
        JobTitle: _searchQuery.isNotEmpty ? _searchQuery : null,
        CompanyName: _companySearchQuery.isNotEmpty ? _companySearchQuery : null,
        Status: _selectedStatus,
        ApplicationDateFrom: _applicationDateFrom,
        ApplicationDateTo: _applicationDateTo,
        Page: reset ? 0 : _currentPage + 1,
        PageSize: _pageSize,
        IncludeTotalCount: true,
      );

      final result = await context.read<ApplicationProvider>().get(filter: searchObject);
      
      if (!mounted) return;

      final newApplications = result.items ?? [];
      
      await _loadEmployerData(newApplications);

      setState(() {
        if (reset) {
          _applications = newApplications;
          _currentPage = 0;
          _hasMoreData = newApplications.length >= _pageSize;
        } else {
          _applications.addAll(newApplications);
          _currentPage++;
          _hasMoreData = newApplications.length >= _pageSize;
        }
        _totalCount = result.totalCount ?? _applications.length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading applications: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadEmployerData(List<Application> applications) async {
    final jobPostingProvider = context.read<JobPostingProvider>();
    
    final newJobPostingIds = applications
        .map((app) => app.jobPostingId)
        .where((id) => !_jobToEmployerIdCache.containsKey(id))
        .toSet();

    if (newJobPostingIds.isNotEmpty) {
      for (final jobPostingId in newJobPostingIds) {
        try {
          final jobPosting = await jobPostingProvider.getById(jobPostingId);
          _jobToEmployerIdCache[jobPosting.id] = jobPosting.employerId;
        } catch (e) {
          debugPrint('Failed to load job posting $jobPostingId: $e');
          _jobToEmployerIdCache[jobPostingId] = -1; 
        }
      }
    }

    final employerProvider = context.read<EmployerProvider>();

    final newEmployerIds = applications
        .map((app) => _jobToEmployerIdCache[app.jobPostingId])
        .where((id) => id != null && id != -1 && !_employerCache.containsKey(id))
        .cast<int>()
        .toSet();

    if (newEmployerIds.isEmpty) return;
    
    for (final employerId in newEmployerIds) {
      try {
        final employer = await employerProvider.getById(employerId);
        _employerCache[employerId] = employer;
      } catch (e) {
        debugPrint('Failed to load employer $employerId: $e');
      }
    }
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _loadApplications(reset: true);
  }

  void _onCompanySearchChanged(String value) {
    _debouncer.run(() {
      if (mounted) {
        setState(() {
          _companySearchQuery = value;
        });
        _loadApplications(reset: true);
      }
    });
  }

  void _applyFilters() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      setState(() {
        _selectedStatus = formData['status'];
        _applicationDateFrom = formData['dateFrom'];
        _applicationDateTo = formData['dateTo'];
      });
      _loadApplications(reset: true);
    }
  }

  void _clearFilters() {
    _formKey.currentState?.reset();
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedStatus = null;
      _applicationDateFrom = null;
      _applicationDateTo = null;
      _companySearchQuery = '';
      _companySearchController.clear();
    });
    _loadApplications(reset: true);
  }

  void _showApplicationDetails(Application application) {
    showDialog(
      context: context,
      builder: (context) => _ApplicationDetailsDialog(
        application: application,
        onNotificationToggle: (receiveNotifications) async {
          await _updateApplicationNotifications(application.id, receiveNotifications);
        },
      ),
    );
  }

  Future<void> _updateApplicationNotifications(int applicationId, bool receiveNotifications) async {
    try {
      final application = await context.read<ApplicationProvider>().getById(applicationId);

      if (receiveNotifications != application.receiveNotifications) {
        final updatedApplication = await context.read<ApplicationProvider>().toggleNotifications(applicationId);
        
        setState(() {
          final index = _applications.indexWhere((app) => app.id == applicationId);
          if (index != -1) {
            _applications[index] = updatedApplication;
          }
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification preference ${receiveNotifications ? 'enabled' : 'disabled'}'),
            backgroundColor: AppTheme.confirmColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating notification preference: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  void _onScroll() {
    if (!_isLoading && _hasMoreData) {
      _loadApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'My Applications',
      selectedIndex: 3,
      showBackButton: true,
      onScroll: _onScroll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilterHeader(),
          if (_showFilters) _buildFiltersPanel(),
          _buildResultsHeader(),
          _buildApplicationsList(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Search applications...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: AppTheme.primaryColor),
                  onPressed: _onSearch,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_totalCount applications found',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      size: 18,
                    ),
                    label: Text(_showFilters ? 'Hide Filters' : 'Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showFilters ? AppTheme.primaryColor : Colors.white,
                      foregroundColor: _showFilters ? Colors.white : AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All', style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormBuilder(
              key: _formKey,
              initialValue: {
                'status': _selectedStatus,
                'dateFrom': _applicationDateFrom,
                'dateTo': _applicationDateTo,
              },
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: FormBuilderTextField(
                          name: 'companySearch',
                          controller: _companySearchController,
                          decoration: const InputDecoration(
                            hintText: 'Search by company name',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) => _onCompanySearchChanged(value ?? ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Application Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: FormBuilderDropdown<ApplicationStatus>(
                          name: 'status',
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          hint: const Text('All statuses'),
                          items: [
                            const DropdownMenuItem<ApplicationStatus>(
                              value: null,
                              child: Text('All statuses'),
                            ),
                            ...ApplicationStatus.values.map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(applicationStatusToString(status)),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: FormBuilderDateTimePicker(
                                name: 'dateFrom',
                                decoration: const InputDecoration(
                                  hintText: 'Select date',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                inputType: InputType.date,
                                onChanged: (value) {
                                  setState(() {
                                    _applicationDateFrom = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'To Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: FormBuilderDateTimePicker(
                                name: 'dateTo',
                                decoration: const InputDecoration(
                                  hintText: 'Select date',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                inputType: InputType.date,
                                onChanged: (value) {
                                  setState(() {
                                    _applicationDateTo = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    if (_applications.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Showing ${_applications.length} of $_totalCount applications',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    if (_isLoading && _applications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No applications found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _applications.length + (_hasMoreData && !_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _applications.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final application = _applications[index];
        final employerId = _jobToEmployerIdCache[application.jobPostingId];
        final employer = (employerId != null && employerId != -1)
            ? _employerCache[employerId]
            : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ApplicationCard(
            applicationId: application.id,
            jobTitle: application.jobTitle ?? 'Unknown Position',
            companyName: application.companyName ?? 'Unknown Company',
            companyLogoBase64: employer?.logo,
            applicationDate: application.applicationDate,
            status: application.status,
            employerMessage: application.employerMessage,
            onDetailsPressed: () => _showApplicationDetails(application),
          ),
        );
      },
    );
  }
}

class _ApplicationDetailsDialog extends StatefulWidget {
  final Application application;
  final Function(bool) onNotificationToggle;

  const _ApplicationDetailsDialog({
    required this.application,
    required this.onNotificationToggle,
  });

  @override
  State<_ApplicationDetailsDialog> createState() => _ApplicationDetailsDialogState();
}

class _ApplicationDetailsDialogState extends State<_ApplicationDetailsDialog> {
  late bool _receiveNotifications;

  @override
  void initState() {
    super.initState();
    _receiveNotifications = widget.application.receiveNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Details',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.application.jobTitle ?? 'Unknown Position',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.secondaryColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Company', widget.application.companyName ?? 'Unknown'),
                    _buildDetailRow('Application Date', 
                        DateFormat('MMMM dd, yyyy').format(widget.application.applicationDate)),
                    _buildDetailRow('Status', applicationStatusToString(widget.application.status)),
                    
                    if (widget.application.coverLetter?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection('Cover Letter', widget.application.coverLetter!),
                    ],
                    
                    if (widget.application.cvDocumentName?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      _buildDetailRow('CV Document', widget.application.cvDocumentName!),
                    ],
                    
                    if (widget.application.availability?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection('Availability', widget.application.availability!),
                    ],
                    
                    if (widget.application.employerMessage?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection('Employer Message', widget.application.employerMessage!),
                    ],
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email Notifications',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Receive updates about this application',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _receiveNotifications,
                          onChanged: (value) {
                            setState(() {
                              _receiveNotifications = value;
                            });
                            widget.onNotificationToggle(value);
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.textColor.withOpacity(0.2),
            ),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: AppTheme.secondaryColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
