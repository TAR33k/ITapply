import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/role.dart';
import 'package:itapply_desktop/models/requests/user_update_request.dart';
import 'package:itapply_desktop/models/requests/user_insert_request.dart';
import 'package:itapply_desktop/models/requests/user_role_insert_request.dart';
import 'package:itapply_desktop/models/search_objects/candidate_search_object.dart';
import 'package:itapply_desktop/models/search_objects/employer_search_object.dart';
import 'package:itapply_desktop/models/search_objects/role_search_object.dart';
import 'package:itapply_desktop/models/search_objects/user_role_search_object.dart';
import 'package:itapply_desktop/models/search_objects/user_search_object.dart';
import 'package:itapply_desktop/models/user.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/providers/candidate_provider.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/role_provider.dart';
import 'package:itapply_desktop/providers/user_provider.dart';
import 'package:itapply_desktop/providers/user_role_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key, this.startingIndex = 0});

  final int startingIndex;

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<User> _allUsers = [];
  List<Candidate> _candidates = [];
  List<Employer> _employers = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showActiveOnly = false;
  VerificationStatus? _selectedVerificationStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.startingIndex);
    _fetchData();
    _tabController.addListener(() {
      setState(() {
        _tabController.index;
      });
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        context
            .read<UserProvider>()
            .get(filter: UserSearchObject(RetrieveAll: true)),
        context
            .read<CandidateProvider>()
            .get(filter: CandidateSearchObject(RetrieveAll: true)),
        context
            .read<EmployerProvider>()
            .get(filter: EmployerSearchObject(RetrieveAll: true)),
      ]);

      if (mounted) {
        setState(() {
          _allUsers = results[0].items as List<User>;
          _candidates = results[1].items as List<Candidate>;
          _employers = results[2].items as List<Employer>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<User> get _filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesActive = !_showActiveOnly || user.isActive;
      return matchesSearch && matchesActive;
    }).toList();
  }

  List<Candidate> get _filteredCandidates {
    return _candidates.where((candidate) {
      final matchesSearch = _searchQuery.isEmpty ||
          candidate.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          '${candidate.firstName} ${candidate.lastName}'
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesActive = !_showActiveOnly || candidate.isActive;
      return matchesSearch && matchesActive;
    }).toList();
  }

  List<Employer> get _filteredEmployers {
    return _employers.where((employer) {
      final matchesSearch = _searchQuery.isEmpty ||
          employer.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employer.companyName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesActive = !_showActiveOnly || employer.isActive;
      final matchesVerificationStatus = _selectedVerificationStatus == null ||
          employer.verificationStatus == _selectedVerificationStatus;
      return matchesSearch && matchesActive && matchesVerificationStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "User Management",
      selectedRoute: AppRouter.adminUserManagementRoute,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text("Failed to load user data",
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchData, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildButtons(),
        const SizedBox(height: 16),
        _buildHeader(),
        const SizedBox(height: 16),
        _buildSearchAndFilters(),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsersTab(),
              _buildCandidatesTab(),
              _buildEmployersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
              onPressed: _addAdmin,
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Add Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
              onPressed: _addCandidate,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Candidate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
              onPressed: _addEmployer,
              icon: const Icon(Icons.business),
              label: const Text('Add Employer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              )),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.people_alt_outlined),
                const SizedBox(width: 8),
                Text('All Users (${_filteredUsers.length})')
              ])),
              Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Text('Candidates (${_filteredCandidates.length})')
              ])),
              Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.business_outlined),
                const SizedBox(width: 8),
                Text('Employers (${_filteredEmployers.length})')
              ])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search users by email...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('Active Only'),
                  selected: _showActiveOnly,
                  onSelected: (selected) =>
                      setState(() => _showActiveOnly = selected),
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.secondaryColor,
                  checkmarkColor: Colors.white,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            if (_tabController.index == 2) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Verification Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  DropdownButton<VerificationStatus?>(
                    value: _selectedVerificationStatus,
                    hint: const Text('All Statuses'),
                    items: [
                      const DropdownMenuItem<VerificationStatus?>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...VerificationStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: verificationStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(verificationStatusToString(status)),
                          ],
                        ),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedVerificationStatus = value),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Roles')),
            DataColumn(label: Text('Registration Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _filteredUsers
              .map((user) => DataRow(
                    cells: [
                      DataCell(Text(user.email == AuthProvider.email
                          ? "${user.email} (YOU)"
                          : user.email)),
                      
                      DataCell(
                        Wrap(
                          spacing: 4,
                          children: user.roles
                              .map((role) => Chip(
                                    label: Text(role.name,
                                        style: TextStyle(color: _getRoleColor(role.name), fontWeight: FontWeight.bold)),
                                    backgroundColor:
                                        _getRoleColor(role.name).withOpacity(0.15),
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ))
                              .toList(),
                        ),
                      ),
                      DataCell(
                          Text(DateFormat.yMMMd().format(user.registrationDate))),
                      DataCell(Chip(
                        label: Text(user.isActive ? 'Active' : 'Inactive', style: TextStyle(color: user.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        backgroundColor: user.isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      )),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Edit User',
                              onPressed: () => _editUser(user),
                            ),
                            if (user.email != AuthProvider.email)
                              IconButton(
                                icon: const Icon(Icons.delete_outlined),
                                tooltip: 'Delete User',
                                onPressed: () => _deleteUser(user),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCandidatesTab() {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Experience')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _filteredCandidates
              .map((candidate) => DataRow(
                    cells: [
                      DataCell(Text('${candidate.firstName} ${candidate.lastName}')),
                      DataCell(Text(candidate.email)),
                      DataCell(Text(candidate.title ?? 'N/A')),
                      DataCell(Text(
                          '${candidate.experienceYears} years (${experienceLevelToString(candidate.experienceLevel)})')),
                      DataCell(Chip(
                        label: Text(candidate.isActive ? 'Active' : 'Inactive', style: TextStyle(color: candidate.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        backgroundColor: candidate.isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      )),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit_note),
                                tooltip: 'View & Edit Details',
                                onPressed: () =>
                                    _viewCandidateDetails(candidate)),
                            IconButton(
                                icon: const Icon(Icons.work_outline),
                                tooltip: 'View Applications',
                                onPressed: () => _viewCandidateApplications(candidate),
                              ),
                            IconButton(
                                icon: const Icon(Icons.rate_review_outlined),
                                tooltip: 'View Reviews',
                                onPressed: () => _viewCandidateReviews(candidate),
                              ),
                            IconButton(
                                icon: const Icon(Icons.delete_outlined),
                                tooltip: 'Delete User',
                                onPressed: () => _deleteCandidate(candidate),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildEmployersTab() {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Company')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Verification')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _filteredEmployers
              .map((employer) => DataRow(
                    cells: [
                      DataCell(Text(employer.companyName)),
                      DataCell(Text(employer.email)),
                      DataCell(
                        Chip(
                          label: Text(verificationStatusToString(
                              employer.verificationStatus), style: TextStyle(color: verificationStatusColor(employer.verificationStatus), fontWeight: FontWeight.bold)),
                          backgroundColor: verificationStatusColor(
                                  employer.verificationStatus)
                              .withOpacity(0.15),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      DataCell(Chip(
                        label: Text(employer.isActive ? 'Active' : 'Inactive', style: TextStyle(color: employer.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        backgroundColor: employer.isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      )),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit_note),
                                tooltip: 'View & Edit Details',
                                onPressed: () => _viewEmployerDetails(employer)),
                            IconButton(
                                icon: const Icon(Icons.work_outline),
                                tooltip: 'View Job Postings',
                                onPressed: () => _viewEmployerJobPostings(employer)),
                            IconButton(
                                icon: const Icon(Icons.rate_review_outlined),
                                tooltip: 'View Reviews',
                                onPressed: () => _viewEmployerReviews(employer),
                              ),
                            IconButton(
                                icon: const Icon(Icons.delete_outlined),
                                tooltip: 'Delete User',
                                onPressed: () => _deleteEmployer(employer),
                              ),
                            if (employer.verificationStatus ==
                                VerificationStatus.pending) ...[
                              IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  tooltip: 'Approve',
                                  onPressed: () => _handleVerification(
                                      employer, VerificationStatus.approved)),
                              IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  tooltip: 'Reject',
                                  onPressed: () => _handleVerification(
                                      employer, VerificationStatus.rejected)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'administrator':
        return Colors.red;
      case 'employer':
        return Colors.blue;
      case 'candidate':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      title: isError ? "Operation Failed" : "Success",
      message: message,
      duration: const Duration(seconds: 1),
      backgroundColor: isError ? Colors.red.shade700 : AppTheme.confirmColor,
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white),
    ).show(context);
  }

  Future<void> _editUser(User user) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => _UserEditDialog(user: user),
    );
    if (success == true) {
      await _fetchData();
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _UserConfirmDeleteDialog(user: user),
    );

    if (confirmed == true) {
      try {
        await context.read<UserProvider>().delete(user.id);
        _showFeedback("User '${user.email}' was deleted successfully.");

        await _fetchData();
      } catch (e) {
        _showFeedback(
            e.toString().replaceFirst("Exception: ", ""), isError: true);
      }
    }
  }

  Future<void> _deleteCandidate(Candidate candidate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _CandidateConfirmDeleteDialog(candidate: candidate),
    );

    if (confirmed == true) {
      try {
        await context.read<CandidateProvider>().delete(candidate.id);
        _showFeedback("Candidate '${candidate.email}' was deleted successfully.");

        await _fetchData();
      } catch (e) {
        _showFeedback(
            e.toString().replaceFirst("Exception: ", ""), isError: true);
      }
    }
  }

  Future<void> _deleteEmployer(Employer employer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _EmployerConfirmDeleteDialog(employer: employer),
    );

    if (confirmed == true) {
      try {
        await context.read<EmployerProvider>().delete(employer.id);
        _showFeedback("Employer '${employer.companyName}' was deleted successfully.");

        await _fetchData();
      } catch (e) {
        _showFeedback(
            e.toString().replaceFirst("Exception: ", ""), isError: true);
      }
    }
  }

  Future<void> _addAdmin() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => const _AddAdminDialog(),
    );
    if (success == true) {
      await _fetchData();
    }
  }

  Future<void> _addCandidate() async {
    final result = await Navigator.pushNamed(
        context, AppRouter.adminCandidateDetailsRoute);
    if (result == true) {
      await _fetchData();
    }
  }

  Future<void> _addEmployer() async {
    final result = await Navigator.pushNamed(
        context, AppRouter.adminEmployerDetailsRoute);
    if (result == true) {
      await _fetchData();
    }
  }

  Future<void> _viewCandidateDetails(Candidate candidate) async {
    final result = await Navigator.pushNamed(
        context, AppRouter.adminCandidateDetailsRoute,
        arguments: candidate);
    if (result == true) {
      await _fetchData();
    }
  }

  Future<void> _viewEmployerDetails(Employer employer) async {
    final result = await Navigator.pushNamed(
        context, AppRouter.adminEmployerDetailsRoute,
        arguments: employer);
    if (result == true) {
      await _fetchData();
    }
  }

  void _viewCandidateApplications(Candidate candidate) {
    Navigator.of(context).pushNamed(
      AppRouter.adminApplicationsRoute,
      arguments: {
        'candidate': candidate,
      },
    );
  }

  void _viewCandidateReviews(Candidate candidate) {
    Navigator.of(context).pushNamed(
      AppRouter.adminReviewsRoute,
      arguments: {
        'candidate': candidate,
      },
    );
  }

  void _viewEmployerJobPostings(Employer employer) {
    Navigator.of(context).pushNamed(
      AppRouter.adminJobPostingsRoute,
      arguments: employer.companyName,
    );
  }

  void _viewEmployerReviews(Employer employer) {
    Navigator.of(context).pushNamed(
      AppRouter.adminReviewsRoute,
      arguments: {
        'employer': employer,
      },
    );
  }

  Future<void> _handleVerification(
      Employer employer, VerificationStatus newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update verification status"),
        content: Text("Are you sure you want to ${newStatus == VerificationStatus.approved ? 'approve' : 'reject'} ${employer.companyName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(newStatus == VerificationStatus.approved ? "Approve" : "Reject"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await context
            .read<EmployerProvider>()
            .updateVerificationStatus(employer.id, newStatus);
        _showFeedback(
          '${employer.companyName} has been ${newStatus == VerificationStatus.approved ? 'approved' : 'rejected'}.'
        );
        await _fetchData();
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
      }
    }
  }
}

class _UserConfirmDeleteDialog extends StatelessWidget {
  final User user;

  const _UserConfirmDeleteDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text(
          'Are you sure you want to delete ${user.email}? This will also delete all data related to this user and cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _CandidateConfirmDeleteDialog extends StatelessWidget {
  final Candidate candidate;

  const _CandidateConfirmDeleteDialog({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text(
          'Are you sure you want to delete ${candidate.email}? This will also delete the user and all data related to this user and cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _EmployerConfirmDeleteDialog extends StatelessWidget {
  final Employer employer;

  const _EmployerConfirmDeleteDialog({required this.employer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text(
          'Are you sure you want to delete ${employer.companyName}? This will also delete the user and all data related to this user and cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _UserEditDialog extends StatefulWidget {
  final User user;

  const _UserEditDialog({required this.user});

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  List<Role> _availableRoles = [];
  late List<int> _selectedRoleIds;

  @override
  void initState() {
    super.initState();
    _selectedRoleIds = widget.user.roles.map((role) => role.id).toList();
    _loadAvailableRoles();
  }

  Future<void> _loadAvailableRoles() async {
    try {
      _availableRoles = (await context.read<RoleProvider>().get()).items!;
      if (mounted) setState(() {});
    } catch (e) {
      _showFeedback('Failed to load roles: ${e.toString()}', isError: true);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Flushbar(
          title: isError ? "Error" : "Success",
          message: message,
          duration: const Duration(seconds: 3),
          backgroundColor:
              isError ? Colors.red.shade700 : AppTheme.confirmColor,
          icon: Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white),
        ).show(context);
      }
    });
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _isLoading = true);

    try {
      final formData = _formKey.currentState!.value;

      final userUpdateRequest = UserUpdateRequest(
        email: formData['email'] as String,
        password:
            formData['password']?.isNotEmpty == true ? formData['password'] as String : null,
        isActive: formData['isActive'] as bool,
      );

      await context.read<UserProvider>().update(widget.user.id, userUpdateRequest);

      final currentRoleIds = widget.user.roles.map((role) => role.id).toSet();
      final newRoleIds = _selectedRoleIds.toSet();

      if (currentRoleIds != newRoleIds) {
        final userRoles = await context
            .read<UserRoleProvider>()
            .get(filter: UserRoleSearchObject(UserId: widget.user.id));
        
        for (final roleId in currentRoleIds.difference(newRoleIds)) {
            final userRoleId = userRoles.items!.firstWhere((ur) => ur.roleId == roleId).id;
            await context.read<UserRoleProvider>().delete(userRoleId);
        }

        for (final roleId in newRoleIds.difference(currentRoleIds)) {
            final insertRequest = UserRoleInsertRequest(userId: widget.user.id, roleId: roleId);
            await context.read<UserRoleProvider>().insert(insertRequest);
        }
      }

      _showFeedback('User updated successfully!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showFeedback('Failed to update user: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User: ${widget.user.email}'),
      content: SizedBox(
        width: 500,
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'email': widget.user.email,
            'password': '',
            'isActive': widget.user.isActive,
          },
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(
                  labelText: 'New Password (leave empty to keep current)',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              FormBuilderSwitch(
                name: 'isActive',
                title: const Text('Account Active'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'User Roles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              if (_availableRoles.isNotEmpty)
                FormBuilderCheckboxGroup<int>(
                  name: 'roles',
                  initialValue: _selectedRoleIds,
                  onChanged: (newRoles) => setState(() => _selectedRoleIds = newRoles ?? []),
                  decoration: InputDecoration(
                    labelText: "Select roles",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  options: _availableRoles
                      .map((role) => FormBuilderFieldOption(
                            value: role.id,
                            child: Text(role.name),
                          ))
                      .toList(),
                )
            ],
          )),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _AddAdminDialog extends StatefulWidget {
  const _AddAdminDialog();

  @override
  State<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<_AddAdminDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Flushbar(
          title: isError ? "Error" : "Success",
          message: message,
          duration: const Duration(seconds: 3),
          backgroundColor:
              isError ? Colors.red.shade700 : AppTheme.confirmColor,
          icon: Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white),
        ).show(context);
      }
    });
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _isLoading = true);

    try {
      final formData = _formKey.currentState!.value;

      final adminRole = (await context
              .read<RoleProvider>()
              .get(filter: RoleSearchObject(Name: "Administrator")))
          .items!
          .first;

      final userInsertRequest = UserInsertRequest(
        email: formData['email'] as String,
        password: formData['password'] as String,
        roleIds: [adminRole.id],
      );

      await context.read<UserProvider>().insert(userInsertRequest);

      _showFeedback('Administrator created successfully!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showFeedback('Failed to create administrator: ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.admin_panel_settings, color: Colors.red),
          SizedBox(width: 8),
          Text('Create New Administrator'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  helperText: 'This will be the administrator\'s login email',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                  helperText: 'Minimum 8 characters required',
                ),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(8,
                      errorText: 'Password must be at least 8 characters'),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'confirmPassword',
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  final password =
                      _formKey.currentState?.fields['password']?.value;
                  if (value != password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createAdmin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Create Administrator'),
        ),
      ],
    );
  }
}