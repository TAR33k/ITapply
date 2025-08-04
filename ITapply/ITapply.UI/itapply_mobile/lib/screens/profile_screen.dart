import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/models/candidate.dart';
import 'package:itapply_mobile/models/candidate_skill.dart';
import 'package:itapply_mobile/models/education.dart';
import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/location.dart';
import 'package:itapply_mobile/models/preferences.dart';
import 'package:itapply_mobile/models/requests/candidate_skill_insert_request.dart';
import 'package:itapply_mobile/models/requests/candidate_skill_update_request.dart';
import 'package:itapply_mobile/models/requests/candidate_update_request.dart';
import 'package:itapply_mobile/models/requests/change_password_request.dart';
import 'package:itapply_mobile/models/requests/education_insert_request.dart';
import 'package:itapply_mobile/models/requests/education_update_request.dart';
import 'package:itapply_mobile/models/requests/preferences_insert_request.dart';
import 'package:itapply_mobile/models/requests/preferences_update_request.dart';
import 'package:itapply_mobile/models/requests/user_update_request.dart';
import 'package:itapply_mobile/models/requests/work_experience_insert_request.dart';
import 'package:itapply_mobile/models/requests/work_experience_update_request.dart';
import 'package:itapply_mobile/models/search_objects/candidate_skill_search_object.dart';
import 'package:itapply_mobile/models/search_objects/location_search_object.dart';
import 'package:itapply_mobile/models/search_objects/preferences_search_object.dart';
import 'package:itapply_mobile/models/search_objects/skill_search_object.dart';
import 'package:itapply_mobile/models/search_result.dart';
import 'package:itapply_mobile/models/skill.dart';
import 'package:itapply_mobile/models/user.dart' as app_user;
import 'package:itapply_mobile/models/work_experience.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:itapply_mobile/providers/candidate_provider.dart';
import 'package:itapply_mobile/providers/candidate_skill_provider.dart';
import 'package:itapply_mobile/providers/education_provider.dart';
import 'package:itapply_mobile/providers/location_provider.dart';
import 'package:itapply_mobile/providers/preferences_provider.dart';
import 'package:itapply_mobile/providers/skill_provider.dart';
import 'package:itapply_mobile/providers/user_provider.dart';
import 'package:itapply_mobile/providers/utils.dart';
import 'package:itapply_mobile/providers/work_experience_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _error;

  Candidate? _candidate;
  app_user.User? _user;
  Preferences? _preferences;
  List<WorkExperience> _workExperiences = [];
  List<Education> _educations = [];
  List<CandidateSkill> _candidateSkills = [];
  List<Skill> _allSkills = [];
  List<Location> _locations = [];

  bool _isEditingProfile = false;
  bool _isSavingProfile = false;
  final _profileFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      _candidate = authProvider.currentCandidate;
      _user = authProvider.currentUser;

      if (_candidate == null || _user == null) {
        throw Exception("User is not logged in or is not a candidate.");
      }

      final results = await Future.wait([
        context.read<WorkExperienceProvider>().getByCandidateId(_candidate!.id),
        context.read<EducationProvider>().getByCandidateId(_candidate!.id),
        context.read<CandidateSkillProvider>().get(
            filter: CandidateSkillSearchObject(
                CandidateId: _candidate!.id, RetrieveAll: true)),
        context.read<PreferencesProvider>().get(
            filter: PreferencesSearchObject(CandidateId: _candidate!.id)),
        context
            .read<SkillProvider>()
            .get(filter: SkillSearchObject(RetrieveAll: true)),
        context
            .read<LocationProvider>()
            .get(filter: LocationSearchObject(RetrieveAll: true)),
      ]);

      if (!mounted) return;

      _workExperiences = results[0] as List<WorkExperience>;
      _educations = results[1] as List<Education>;
      _candidateSkills =
          (results[2] as SearchResult<CandidateSkill>).items ?? [];
      final prefsResult = (results[3] as SearchResult<Preferences>).items;
      _preferences = (prefsResult?.isNotEmpty ?? false) ? prefsResult!.first : null;
      _allSkills = (results[4] as SearchResult<Skill>).items ?? [];
      _locations = (results[5] as SearchResult<Location>).items ?? [];
    } catch (e) {
      if (mounted) _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? AppTheme.accentColor : AppTheme.confirmColor,
      ),
    );
  }

  void _handleLogout() {
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.loginRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Profile',
      selectedIndex: 3,
      showBackButton: false,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text("Error: $_error"));
    }
    if (_candidate == null || _user == null) {
      return const Center(child: Text("Could not load profile data."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildAccountCard(),
          const SizedBox(height: 16),
          _buildPreferencesCard(),
          const SizedBox(height: 24),
          _buildSubEntitySection(
            title: "Work Experience",
            data: _workExperiences,
            itemBuilder: (exp) => ListTile(
              title: Text(exp.position,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exp.companyName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text("${DateFormat.yMMM().format(exp.startDate)} - ${exp.endDate != null ? DateFormat.yMMM().format(exp.endDate!) : 'Present'}"),
                  if (exp.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(exp.description!, style: const TextStyle(color: AppTheme.secondaryColor)),
                  ],
                ],
              ),
              isThreeLine: true,
            ),
            onAdd: () => _showWorkExperienceDialog(),
            onEdit: (exp) => _showWorkExperienceDialog(experience: exp),
            onDelete: (exp) =>
                context.read<WorkExperienceProvider>().delete(exp.id),
          ),
          const SizedBox(height: 24),
          _buildSubEntitySection(
            title: "Education",
            data: _educations,
            itemBuilder: (edu) => ListTile(
              title: Text(edu.degree,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(edu.institution, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(edu.fieldOfStudy),
                  Text("${DateFormat.yMMM().format(edu.startDate)} - ${edu.endDate != null ? DateFormat.yMMM().format(edu.endDate!) : 'Present'}"),
                  if (edu.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(edu.description!, style: const TextStyle(color: AppTheme.secondaryColor)),
                  ],
                ],
              ),
              isThreeLine: true,
            ),
            onAdd: () => _showEducationDialog(),
            onEdit: (edu) => _showEducationDialog(education: edu),
            onDelete: (edu) => context.read<EducationProvider>().delete(edu.id),
          ),
          const SizedBox(height: 24),
          _buildSkillsSection(),
          const SizedBox(height: 24),
          _buildNavigationActions(),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSavingProfile = true);

    final formData = _profileFormKey.currentState!.value;
    final request = CandidateUpdateRequest(
      firstName: formData['firstName'],
      lastName: formData['lastName'],
      phoneNumber: formData['phoneNumber'],
      title: formData['title'],
      bio: formData['bio'],
      locationId: formData['locationId'],
      experienceYears: int.parse(formData['experienceYears']),
      experienceLevel: formData['experienceLevel'],
    );

    try {
      await context.read<CandidateProvider>().update(_candidate!.id, request);
      
      final updatedCandidate = await context.read<CandidateProvider>().getById(_candidate!.id);
      
      if (!mounted) return;

      setState(() {
        _candidate = updatedCandidate;
        _isEditingProfile = false;
      });
      
      context.read<AuthProvider>().setCurrentCandidate(updatedCandidate);
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile updated successfully."),
        backgroundColor: AppTheme.confirmColor,
      ));

    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update profile: $e"),
        backgroundColor: AppTheme.accentColor,
      ));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
        });
      }
    }
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _profileFormKey,
          enabled: _isEditingProfile,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Personal Profile", style: Theme.of(context).textTheme.titleLarge),
                  if (_isSavingProfile)
                    const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                  else if (_isEditingProfile)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Cancel",
                          icon: const Icon(Icons.close, color: AppTheme.accentColor), 
                          onPressed: () => setState(() => _isEditingProfile = false)
                        ),
                        IconButton(
                          tooltip: "Save",
                          icon: const Icon(Icons.check, color: AppTheme.confirmColor), 
                          onPressed: _saveProfile
                        ),
                      ],
                    )
                  else
                    IconButton(
                      tooltip: "Edit Profile",
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                      onPressed: () => setState(() => _isEditingProfile = true),
                    ),
                ],
              ),
              const Divider(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isEditingProfile
                    ? _buildEditableProfileFields()
                    : _buildReadOnlyProfileInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyProfileInfo() {
    return Column(
      key: const ValueKey('readOnlyProfile'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.person, "Name", '${_candidate!.firstName} ${_candidate!.lastName}'),
        if (_candidate!.title?.isNotEmpty ?? false)
          _buildInfoRow(Icons.work, "Title", _candidate!.title!),
        if (_candidate!.locationName?.isNotEmpty ?? false)
          _buildInfoRow(Icons.location_on, "Location", _candidate!.locationName!),
        _buildInfoRow(Icons.phone, "Phone", _candidate!.phoneNumber ?? "Not provided"),
        _buildInfoRow(Icons.work_history, "Experience", "${_candidate!.experienceYears} years"),
        _buildInfoRow(Icons.leaderboard, "Level", experienceLevelToString(_candidate!.experienceLevel)),
        if (_candidate!.bio?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text("Bio", style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(_candidate!.bio!, style: const TextStyle(color: AppTheme.secondaryColor)),
        ],
      ],
    );
  }

  Widget _buildEditableProfileFields() {
    return Column(
      key: const ValueKey('editableProfile'),
      children: [
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'firstName',
                initialValue: _candidate!.firstName,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: FormBuilderValidators.required(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormBuilderTextField(
                name: 'lastName',
                initialValue: _candidate!.lastName,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: FormBuilderValidators.required(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'title', 
          initialValue: _candidate!.title,
          decoration: const InputDecoration(labelText: "Professional Title")
        ),
        const SizedBox(height: 16),
        FormBuilderTypeAhead<Location>(
          name: 'locationId',
          decoration: const InputDecoration(labelText: "Location"),
          itemBuilder: (context, item) => ListTile(title: Text("${item.city}, ${item.country}")),
          suggestionsCallback: (pattern) async => _locations.where((loc) => loc.city.toLowerCase().contains(pattern.toLowerCase()) || loc.country.toLowerCase().contains(pattern.toLowerCase())).toList(),
          valueTransformer: (location) => location?.id,
          selectionToTextTransformer: (location) => "${location.city}, ${location.country}",
          initialValue: _candidate!.locationId != null && _locations.any((l) => l.id == _candidate!.locationId)
            ? _locations.firstWhere((l) => l.id == _candidate!.locationId) 
            : null,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'phoneNumber', 
          initialValue: _candidate!.phoneNumber,
          decoration: const InputDecoration(labelText: "Phone Number"),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.maxLength(20, errorText: 'Phone number cannot exceed 20 characters.'),
            FormBuilderValidators.match(RegExp(r'^\+?[0-9\s\-\(\)]+$'), errorText: 'Phone number format is invalid.')
          ]),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: FormBuilderTextField(
                name: 'experienceYears',
                initialValue: _candidate!.experienceYears.toString(),
                decoration: const InputDecoration(labelText: "Years of Exp."),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.integer(),
                  FormBuilderValidators.min(0, errorText: 'Experience years cannot be negative.')
                ]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: FormBuilderDropdown<ExperienceLevel>(
                name: 'experienceLevel',
                initialValue: _candidate!.experienceLevel,
                decoration: const InputDecoration(labelText: "Level"),
                items: ExperienceLevel.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(experienceLevelToString(e)),
                        ))
                    .toList(),
                validator: (value) => value == null ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'bio', 
          initialValue: _candidate!.bio,
          maxLines: 4, 
          decoration: const InputDecoration(labelText: "Bio", hintText: "A short summary about you...")
        ),
      ],
    );
  }

  Widget _buildAccountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader("Account Settings", () => _showEditAccountDialog()),
            const Divider(height: 24),
            _buildInfoRow(Icons.email, "Email", _user!.email),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showChangePasswordDialog,
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                child: const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader("Job Preferences", () => _showEditPreferencesDialog()),
            const Divider(height: 24),
            _buildInfoRow(Icons.location_city, "Location",
                _preferences?.locationName ?? "Any"),
            _buildInfoRow(Icons.work_outline, "Employment",
                _preferences?.employmentType != null ? employmentTypeToString(_preferences!.employmentType!) : "Any"),
            _buildInfoRow(Icons.home_work_outlined, "Remote",
                _preferences?.remote != null ? remoteToString(_preferences!.remote!) : "Any"),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title, VoidCallback onEditPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
          onPressed: onEditPressed,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.secondaryColor),
          const SizedBox(width: 16),
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: AppTheme.secondaryColor))),
        ],
      ),
    );
  }

  Widget _buildSubEntitySection<T>({
    required String title,
    required List<T> data,
    required Widget Function(T item) itemBuilder,
    required VoidCallback onAdd,
    required Function(T item) onEdit,
    required Future<void> Function(T item) onDelete,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryColor),
                    onPressed: onAdd),
              ],
            ),
            const Divider(),
            if (data.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No items added yet.",
                    style: TextStyle(color: AppTheme.secondaryColor)),
              ))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 50.0),
                        child: itemBuilder(item),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: AppTheme.secondaryColor),
                                onPressed: () => onEdit(item)),
                            IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: AppTheme.accentColor),
                                onPressed: () async {
                                  final confirmed = await _showConfirmDialog(
                                      "Delete Item?",
                                      "Are you sure you want to delete this item?");
                                  if (confirmed == true) {
                                    try {
                                      await onDelete(item);
                                      _showFeedback("Item deleted.");
                                      _fetchData();
                                    } catch (e) {
                                      _showFeedback(e.toString(),
                                          isError: true);
                                    }
                                  }
                                }),
                          ],
                        ),
                      )
                    ],
                  );
                },
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Skills", style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  onPressed: _showSkillsDialog,
                ),
              ],
            ),
            const Divider(),
            if (_candidateSkills.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No skills added yet.",
                    style: TextStyle(color: AppTheme.secondaryColor)),
              ))
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _candidateSkills.map((cs) {
                  final skill = _allSkills.firstWhere((s) => s.id == cs.skillId,
                      orElse: () => Skill(id: 0, name: 'Unknown'));
                  return Chip(
                    label: Text('${skill.name} (Level ${cs.level}/5)', style: const TextStyle(color: AppTheme.lightColor)),
                    backgroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  );
                }).toList(),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationActions() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.article, color: AppTheme.primaryColor),
            title: const Text("My Applications"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.applicationsRoute, arguments: _candidate!.id);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading:
                const Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
            title: const Text("Manage CVs"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.cvDocumentsRoute, arguments: _candidate!.id);
            },
          ),
        ),
      ],
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: AppTheme.lightColor),
              child: const Text("Confirm")),
        ],
      ),
    );
  }
  
  Future<void> _showEditAccountDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => _EditAccountDialog(user: _user!),
    );
    if (result == true) {
      _fetchData();
      _showFeedback("Account email updated successfully.");
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(userId: _user!.id),
    );
    if (result == true) {
      _showFeedback("Password changed successfully. Please log in again.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleLogout();
      });
    }
  }

  Future<void> _showEditPreferencesDialog() async {
     final result = await showDialog(
      context: context,
      builder: (context) => _EditPreferencesDialog(
        preferences: _preferences,
        candidateId: _candidate!.id,
        locations: _locations,
      ),
    );
    if (result == true) {
      _fetchData();
      _showFeedback("Preferences updated successfully.");
    }
  }

  Future<void> _showWorkExperienceDialog({WorkExperience? experience}) async {
    final result = await showDialog(
      context: context,
      builder: (context) =>
          _WorkExperienceDialog(candidateId: _candidate!.id, experience: experience),
    );
    if (result == true) {
      _fetchData();
    }
  }

  Future<void> _showEducationDialog({Education? education}) async {
    final result = await showDialog(
      context: context,
      builder: (context) =>
          _EducationDialog(candidateId: _candidate!.id, education: education),
    );
    if (result == true) {
      _fetchData();
    }
  }

  Future<void> _showSkillsDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => _SkillsManagementDialog(
        candidateId: _candidate!.id,
        currentSkills: _candidateSkills,
        allSkills: _allSkills,
      ),
    );
    if (result == true) {
      _fetchData();
    }
  }
}

class _EditAccountDialog extends StatefulWidget {
  final app_user.User user;
  const _EditAccountDialog({required this.user});

  @override
  State<_EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<_EditAccountDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final formData = _formKey.currentState!.value;
    final request = UserUpdateRequest(email: formData['email']);
    final authProvider = context.read<AuthProvider>();

    try {
      await context.read<UserProvider>().update(widget.user.id, request);
      if (!mounted) return;

      authProvider.logout(); 

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Email updated. Please log in with your new email address."),
        backgroundColor: AppTheme.confirmColor,
      ));

      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (route) => false);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Account Email"),
      content: FormBuilder(
        key: _formKey,
        initialValue: {'email': widget.user.email},
        child: FormBuilderTextField(name: 'email', decoration: const InputDecoration(labelText: "Email Address"), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()])),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor), child: const Text("Cancel")),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text("Save", style: TextStyle(color: AppTheme.lightColor))),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final int userId;
  const _ChangePasswordDialog({required this.userId});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  
  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final formData = _formKey.currentState!.value;
    final request = ChangePasswordRequest(
      oldPassword: formData['oldPassword'],
      newPassword: formData['newPassword'],
      confirmPassword: formData['confirmPassword'],
    );
    
    try {
      await context.read<UserProvider>().changePassword(widget.userId, request);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Password"),
      content: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(name: 'oldPassword', obscureText: true, decoration: const InputDecoration(labelText: "Old Password"), validator: FormBuilderValidators.required()),
              const SizedBox(height: 16),
              FormBuilderTextField(name: 'newPassword', obscureText: true, decoration: const InputDecoration(labelText: "New Password"), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters long.')])),
              const SizedBox(height: 16),
              FormBuilderTextField(name: 'confirmPassword', obscureText: true, decoration: const InputDecoration(labelText: "Confirm New Password"), validator: (val) {
                if (val != _formKey.currentState?.fields['newPassword']?.value) {
                  return 'Passwords do not match';
                }
                return null;
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor), child: const Text("Cancel")),
        ElevatedButton(onPressed: _save, child: const Text("Save")),
      ],
    );
  }
}

class _EditPreferencesDialog extends StatefulWidget {
  final Preferences? preferences;
  final int candidateId;
  final List<Location> locations;
  const _EditPreferencesDialog({this.preferences, required this.candidateId, required this.locations});

  @override
  State<_EditPreferencesDialog> createState() => _EditPreferencesDialogState();
}

class _EditPreferencesDialogState extends State<_EditPreferencesDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final formData = _formKey.currentState!.value;

    try {
      if (widget.preferences != null) {
        final request = PreferencesUpdateRequest(
          locationId: formData['locationId'],
          employmentType: formData['employmentType'],
          remote: formData['remote'],
        );
        await context.read<PreferencesProvider>().update(widget.preferences!.id, request);
      } else {
        final request = PreferencesInsertRequest(
          candidateId: widget.candidateId,
          locationId: formData['locationId'],
          employmentType: formData['employmentType'],
          remote: formData['remote'],
        );
        await context.read<PreferencesProvider>().insert(request);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Job Preferences"),
      content: FormBuilder(
        key: _formKey,
        initialValue: {
          'employmentType': widget.preferences?.employmentType,
          'remote': widget.preferences?.remote,
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTypeAhead<Location>(
                name: 'locationId',
                decoration: const InputDecoration(labelText: "Preferred Location"),
                itemBuilder: (context, item) => ListTile(title: Text('${item.city}, ${item.country}')),
                suggestionsCallback: (pattern) async => widget.locations.where((loc) => 
                    loc.city.toLowerCase().contains(pattern.toLowerCase()) ||
                    loc.country.toLowerCase().contains(pattern.toLowerCase())).toList(),
                valueTransformer: (location) => location?.id,
                selectionToTextTransformer: (location) => '${location.city}, ${location.country}',
                initialValue: widget.preferences?.locationId != null && widget.locations.any((l) => l.id == widget.preferences!.locationId)
                    ? widget.locations.firstWhere((l) => l.id == widget.preferences!.locationId) 
                    : null,
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<EmploymentType>(
                name: 'employmentType',
                decoration: const InputDecoration(labelText: "Preferred Employment Type"),
                items: EmploymentType.values.map((e) => DropdownMenuItem(value: e, child: Text(employmentTypeToString(e)))).toList(),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<Remote>(
                name: 'remote',
                decoration: const InputDecoration(labelText: "Remote Preference"),
                items: Remote.values.map((e) => DropdownMenuItem(value: e, child: Text(remoteToString(e)))).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor), child: const Text("Cancel")),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text("Save", style: TextStyle(color: AppTheme.lightColor))),
      ],
    );
  }
}

class _WorkExperienceDialog extends StatefulWidget {
  final int candidateId;
  final WorkExperience? experience;
  const _WorkExperienceDialog({required this.candidateId, this.experience});

  @override
  State<_WorkExperienceDialog> createState() => _WorkExperienceDialogState();
}

class _WorkExperienceDialogState extends State<_WorkExperienceDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) return;
    final formData = _formKey.currentState!.value;

    try {
      if (widget.experience == null) {
        final request = WorkExperienceInsertRequest(
          candidateId: widget.candidateId,
          companyName: formData['companyName'],
          position: formData['position'],
          startDate: formData['startDate'],
          endDate: formData['endDate'],
          description: formData['description'],
        );
        await context.read<WorkExperienceProvider>().insert(request);
      } else {
        final request = WorkExperienceUpdateRequest(
          companyName: formData['companyName'],
          position: formData['position'],
          startDate: formData['startDate'],
          endDate: formData['endDate'],
          description: formData['description'],
        );
        await context
            .read<WorkExperienceProvider>()
            .update(widget.experience!.id, request);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.experience == null ? 'Add Experience' : 'Edit Experience'),
      content: FormBuilder(
        key: _formKey,
        initialValue: {
          'companyName': widget.experience?.companyName,
          'position': widget.experience?.position,
          'startDate': widget.experience?.startDate,
          'endDate': widget.experience?.endDate,
          'description': widget.experience?.description,
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              FormBuilderTextField(
                  name: 'companyName',
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: FormBuilderValidators.required()),
              FormBuilderTextField(
                  name: 'position',
                  decoration: const InputDecoration(labelText: 'Position'),
                  validator: FormBuilderValidators.required()),
              FormBuilderDateTimePicker(
                  name: 'startDate',
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  inputType: InputType.date,
                  validator: FormBuilderValidators.required()),
              FormBuilderDateTimePicker(
                  name: 'endDate',
                  decoration: const InputDecoration(labelText: 'End Date (optional)'),
                  inputType: InputType.date,
                  validator: (value) {
                    if (value == null) return null;
                    final startDate = _formKey.currentState?.fields['startDate']?.value as DateTime?;
                    if (startDate != null && value.isBefore(startDate)) {
                      return 'End date must be after start date.';
                    }
                    return null;
                  }),
              FormBuilderTextField(
                  name: 'description',
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('Save', style: TextStyle(color: AppTheme.lightColor))),
      ],
    );
  }
}

class _EducationDialog extends StatefulWidget {
  final int candidateId;
  final Education? education;
  const _EducationDialog({required this.candidateId, this.education});

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) return;
    final formData = _formKey.currentState!.value;

    try {
      if (widget.education == null) {
        final request = EducationInsertRequest(
          candidateId: widget.candidateId,
          institution: formData['institution'],
          degree: formData['degree'],
          fieldOfStudy: formData['fieldOfStudy'],
          startDate: formData['startDate'],
          endDate: formData['endDate'],
          description: formData['description'],
        );
        await context.read<EducationProvider>().insert(request);
      } else {
        final request = EducationUpdateRequest(
          institution: formData['institution'],
          degree: formData['degree'],
          fieldOfStudy: formData['fieldOfStudy'],
          startDate: formData['startDate'],
          endDate: formData['endDate'],
          description: formData['description'],
        );
        await context
            .read<EducationProvider>()
            .update(widget.education!.id, request);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.education == null ? 'Add Education' : 'Edit Education'),
      content: FormBuilder(
        key: _formKey,
        initialValue: {
          'institution': widget.education?.institution,
          'degree': widget.education?.degree,
          'fieldOfStudy': widget.education?.fieldOfStudy,
          'startDate': widget.education?.startDate,
          'endDate': widget.education?.endDate,
          'description': widget.education?.description,
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              FormBuilderTextField(
                  name: 'institution',
                  decoration: const InputDecoration(labelText: 'Institution'),
                  validator: FormBuilderValidators.required()),
              FormBuilderTextField(
                  name: 'degree',
                  decoration: const InputDecoration(labelText: 'Degree'),
                  validator: FormBuilderValidators.required()),
              FormBuilderTextField(
                  name: 'fieldOfStudy',
                  decoration: const InputDecoration(labelText: 'Field of Study'),
                  validator: FormBuilderValidators.required()),
              FormBuilderDateTimePicker(
                  name: 'startDate',
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  inputType: InputType.date,
                  validator: FormBuilderValidators.required()),
              FormBuilderDateTimePicker(
                  name: 'endDate',
                  decoration: const InputDecoration(labelText: 'End Date (optional)'),
                  inputType: InputType.date,
                  validator: (value) {
                    if (value == null) return null;
                    final startDate = _formKey.currentState?.fields['startDate']?.value as DateTime?;
                    if (startDate != null && value.isBefore(startDate)) {
                      return 'End date must be after start date.';
                    }
                    return null;
                  }),
              FormBuilderTextField(
                  name: 'description',
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('Save', style: TextStyle(color: AppTheme.lightColor))),
      ],
    );
  }
}

class _SkillsManagementDialog extends StatefulWidget {
  final int candidateId;
  final List<CandidateSkill> currentSkills;
  final List<Skill> allSkills;
  const _SkillsManagementDialog(
      {required this.candidateId,
      required this.currentSkills,
      required this.allSkills});

  @override
  State<_SkillsManagementDialog> createState() =>
      _SkillsManagementDialogState();
}

class _SkillsManagementDialogState extends State<_SkillsManagementDialog> {
  late Map<int, CandidateSkill> _managedSkills;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _managedSkills = {
      for (var cs in widget.currentSkills)
        cs.skillId: CandidateSkill.fromJson(cs.toJson())
    };
  }

  Future<void> _save() async {
    final originalSkillIds =
        widget.currentSkills.map((cs) => cs.skillId).toSet();
    final newSkillIds = _managedSkills.keys.toSet();

    final skillsToAdd = newSkillIds.difference(originalSkillIds);
    final skillsToRemove = originalSkillIds.difference(newSkillIds);
    final skillsToUpdate = newSkillIds.intersection(originalSkillIds);

    try {
      final skillProvider = context.read<CandidateSkillProvider>();

      for (var skillId in skillsToAdd) {
        final request = CandidateSkillInsertRequest(
            candidateId: widget.candidateId,
            skillId: skillId,
            level: _managedSkills[skillId]!.level);
        await skillProvider.insert(request);
      }
      for (var skillId in skillsToRemove) {
        final skillToDelete =
            widget.currentSkills.firstWhere((cs) => cs.skillId == skillId);
        await skillProvider.delete(skillToDelete.id);
      }
      for (var skillId in skillsToUpdate) {
        final originalSkill =
            widget.currentSkills.firstWhere((cs) => cs.skillId == skillId);
        final updatedSkill = _managedSkills[skillId]!;
        if (originalSkill.level != updatedSkill.level) {
          final request = CandidateSkillUpdateRequest(
              skillId: skillId, level: updatedSkill.level);
          await skillProvider.update(originalSkill.id, request);
        }
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Skills'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilder(
              key: _formKey,
              child: FormBuilderTypeAhead<Skill>(
                name: 'add_skill',
                decoration: InputDecoration(
                  labelText: 'Add a new skill',
                  prefixIcon: const Icon(Icons.add_circle_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                itemBuilder: (context, skill) {
                  return ListTile(
                    title: Text(skill.name),
                  );
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.isEmpty) return widget.allSkills.take(10).toList();
                  return widget.allSkills
                      .where((skill) => skill.name
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                      .take(10)
                      .toList();
                },
                onSelected: (Skill skill) {
                  if (!_managedSkills.containsKey(skill.id)) {
                    setState(() {
                      _managedSkills[skill.id] = CandidateSkill(
                          id: 0,
                          candidateId: widget.candidateId,
                          skillId: skill.id,
                          level: 3);
                    });
                    _formKey.currentState?.fields['add_skill']?.reset();
                  }
                },
                selectionToTextTransformer: (Skill skill) => skill.name,
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _managedSkills.values.map((cs) {
                  final skill =
                      widget.allSkills.firstWhere((s) => s.id == cs.skillId);
                  return ListTile(
                    title: Text(skill.name),
                    subtitle: Slider(
                      value: cs.level.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: cs.level.toString(),
                      onChanged: (value) {
                        setState(() {
                          _managedSkills[cs.skillId] = CandidateSkill(
                            id: cs.id,
                            candidateId: cs.candidateId,
                            skillId: cs.skillId,
                            level: value.round(),
                          );
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,
                          color: AppTheme.accentColor),
                      onPressed: () {
                        setState(() {
                          _managedSkills.remove(cs.skillId);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('Save', style: TextStyle(color: AppTheme.lightColor))),
      ],
    );
  }
}