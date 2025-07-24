import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/candidate_skill.dart';
import 'package:itapply_desktop/models/cv_document.dart';
import 'package:itapply_desktop/models/education.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/preferences.dart';
import 'package:itapply_desktop/models/requests/candidate_insert_request.dart';
import 'package:itapply_desktop/models/requests/candidate_update_request.dart';
import 'package:itapply_desktop/models/requests/candidate_skill_insert_request.dart';
import 'package:itapply_desktop/models/requests/cv_document_insert_request.dart';
import 'package:itapply_desktop/models/requests/education_insert_request.dart';
import 'package:itapply_desktop/models/requests/education_update_request.dart';
import 'package:itapply_desktop/models/requests/preferences_insert_request.dart';
import 'package:itapply_desktop/models/requests/preferences_update_request.dart';
import 'package:itapply_desktop/models/requests/user_insert_request.dart';
import 'package:itapply_desktop/models/requests/user_update_request.dart';
import 'package:itapply_desktop/models/requests/work_experience_update_request.dart';
import 'package:itapply_desktop/models/role.dart';
import 'package:itapply_desktop/models/search_objects/candidate_skill_search_object.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/models/search_objects/preferences_search_object.dart';
import 'package:itapply_desktop/models/search_objects/role_search_object.dart';
import 'package:itapply_desktop/models/search_objects/skill_search_object.dart';
import 'package:itapply_desktop/models/search_result.dart';
import 'package:itapply_desktop/models/skill.dart';
import 'package:itapply_desktop/models/user.dart';
import 'package:itapply_desktop/models/work_experience.dart';
import 'package:itapply_desktop/providers/candidate_provider.dart';
import 'package:itapply_desktop/providers/candidate_skill_provider.dart';
import 'package:itapply_desktop/providers/cv_document_provider.dart';
import 'package:itapply_desktop/providers/education_provider.dart';
import 'package:itapply_desktop/providers/location_provider.dart';
import 'package:itapply_desktop/providers/preferences_provider.dart';
import 'package:itapply_desktop/providers/role_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:itapply_desktop/providers/user_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/providers/work_experience_provider.dart';
import 'package:itapply_desktop/widgets/form_builder_searchable_location.dart';
import 'package:itapply_desktop/widgets/form_builder_chips.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:itapply_desktop/models/requests/work_experience_insert_request.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminCandidateDetailsScreen extends StatefulWidget {
  final Candidate? candidate;
  const AdminCandidateDetailsScreen({super.key, this.candidate});

  @override
  State<AdminCandidateDetailsScreen> createState() =>
      _AdminCandidateDetailsScreenState();
}

class _AdminCandidateDetailsScreenState
    extends State<AdminCandidateDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool _isEditMode = false;
  bool _isLoading = true;
  String? _error;
  bool _hasMadeChanges = false;

  Candidate? _candidate;
  User? _user;
  Preferences? _preferences;

  List<WorkExperience> _workExperiences = [];
  List<Education> _educations = [];
  List<CandidateSkill> _candidateSkills = [];
  List<CVDocument> _cvDocuments = [];
  List<Preferences> _preferencesList = [];

  List<Location> _locations = [];
  List<Skill> _allSkills = [];
  late Role _candidateRole;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.candidate != null;
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        context
            .read<LocationProvider>()
            .get(filter: LocationSearchObject(RetrieveAll: true)),
        context
            .read<SkillProvider>()
            .get(filter: SkillSearchObject(RetrieveAll: true)),
        context
            .read<RoleProvider>()
            .get(filter: RoleSearchObject(Name: "Candidate")),
      ]);

      _locations = results[0].items as List<Location>;
      _allSkills = results[1].items as List<Skill>;
      _candidateRole = (results[2].items as List<Role>).first;

      if (_isEditMode) {
        await _fetchCandidateSpecificData(widget.candidate!.id);
      }
    } catch (e) {
      if (mounted) {
        _error = "Failed to load required data: ${e.toString().replaceFirst("Exception: ", "")}";
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCandidateSpecificData(int candidateId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        context.read<CandidateProvider>().getById(candidateId),
        context.read<UserProvider>().getById(candidateId),
        context.read<PreferencesProvider>().get(filter: PreferencesSearchObject(CandidateId: candidateId)),
        context.read<WorkExperienceProvider>().getByCandidateId(candidateId),
        context.read<EducationProvider>().getByCandidateId(candidateId),
        context.read<CandidateSkillProvider>().get(filter: CandidateSkillSearchObject(CandidateId: candidateId)),
        context.read<CVDocumentProvider>().getByCandidateId(candidateId),
      ]);

      _candidate = results[0] as Candidate?;
      _user = results[1] as User?;
      _preferencesList = (results[2] as SearchResult<Preferences>).items ?? [];
      _workExperiences = results[3] as List<WorkExperience>;
      _educations = results[4] as List<Education>;
      _candidateSkills = (results[5] as SearchResult<CandidateSkill>).items ?? [];
      _cvDocuments = results[6] as List<CVDocument>;

      if (_preferencesList.isNotEmpty) {
        _preferences = _preferencesList.first;
      }

      _formKey.currentState?.patchValue(_getInitialValues());
    } catch (e) {
      if (mounted) _error = "Failed to load candidate data: ${e.toString().replaceFirst("Exception: ", "")}";
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      _showFeedback("Please correct validation errors in the main profile.", isError: true);
      return;
    }
    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        await _handleUpdate();
        _showFeedback("Candidate updated successfully.");
      } else {
        await _handleCreate();
        _showFeedback("Candidate created successfully. You can now add skills, experience, and more.");
      }
      _hasMadeChanges = true;
    } catch (e) {
      _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCreate() async {
    final formData = _formKey.currentState!.value;

    final userInsertReq = UserInsertRequest(
      email: formData['email'],
      password: formData['password'],
      roleIds: [_candidateRole.id],
    );
    final newUser = await context.read<UserProvider>().insert(userInsertReq);

    final candidateInsertReq = CandidateInsertRequest(
      userId: newUser.id,
      firstName: formData['firstName'],
      lastName: formData['lastName'],
      title: formData['title'],
      phoneNumber: formData['phoneNumber'],
      bio: formData['bio'],
      locationId: formData['locationId'],
      experienceYears: int.tryParse(formData['experienceYears'] ?? '0') ?? 0,
      experienceLevel: formData['experienceLevel'],
    );
    final newCandidate = await context.read<CandidateProvider>().insert(candidateInsertReq);

    final prefsInsertReq = PreferencesInsertRequest(
      candidateId: newCandidate.id,
      locationId: formData['pref_locationId'],
      employmentType: formData['pref_employmentType'],
      remote: formData['pref_remote'],
    );
    await context.read<PreferencesProvider>().insert(prefsInsertReq);

    await _updateSkills(formData['skills'], newCandidate.id);

    setState(() {
      _isEditMode = true;
      _candidate = newCandidate;
    });
    await _fetchCandidateSpecificData(newCandidate.id);
  }

  Future<void> _handleUpdate() async {
    final formData = _formKey.currentState!.value;

    final userUpdateReq = UserUpdateRequest(
      email: formData['email'],
      password: formData['password']?.isNotEmpty == true ? formData['password'] : null,
      isActive: formData['isActive'],
    );

    final candidateUpdateReq = CandidateUpdateRequest(
      firstName: formData['firstName'],
      lastName: formData['lastName'],
      title: formData['title'],
      phoneNumber: formData['phoneNumber'],
      bio: formData['bio'],
      locationId: formData['locationId'],
      experienceYears: int.tryParse(formData['experienceYears'] ?? '0') ?? 0,
      experienceLevel: formData['experienceLevel'],
    );

    final prefsUpdateReq = PreferencesUpdateRequest(
      locationId: formData['pref_locationId'],
      employmentType: formData['pref_employmentType'],
      remote: formData['pref_remote'],
    );

    await Future.wait([
      context.read<UserProvider>().update(_user!.id, userUpdateReq),
      context.read<CandidateProvider>().update(_candidate!.id, candidateUpdateReq),
      if (_preferences != null)
        context.read<PreferencesProvider>().update(_preferences!.id, prefsUpdateReq)
      else
        context.read<PreferencesProvider>().insert(PreferencesInsertRequest(
          candidateId: _candidate!.id,
          locationId: formData['pref_locationId'],
          employmentType: formData['pref_employmentType'],
          remote: formData['pref_remote'],
        )),
    ]);

    await _updateSkills(formData['skills'], _candidate!.id);

    await _fetchCandidateSpecificData(_candidate!.id);
  }
  
  Future<void> _deleteCandidate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Candidate"),
        content: Text("Are you sure you want to delete ${_candidate?.firstName ?? 'this candidate'} ${_candidate?.lastName ?? ''}? This action is irreversible and will delete all associated data."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && _candidate != null) {
      setState(() => _isLoading = true);
      try {
        await context.read<CandidateProvider>().delete(_candidate!.id);
        _showFeedback("Candidate deleted successfully.");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
          }
        });
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSkills(List<Skill>? selectedSkills, int candidateId) async {
    if (selectedSkills == null) return;

    final currentSkillIds = _candidateSkills.map((cs) => cs.skillId).toSet();
    final selectedSkillIds = selectedSkills.map((s) => s.id).toSet();

    final skillsToAdd = selectedSkillIds.difference(currentSkillIds);
    final skillsToRemove = currentSkillIds.difference(selectedSkillIds);

    for (final skillId in skillsToAdd) {
      final insertReq = CandidateSkillInsertRequest(
        candidateId: candidateId,
        skillId: skillId,
        level: 1,
      );
      await context.read<CandidateSkillProvider>().insert(insertReq);
    }

    for (final skillId in skillsToRemove) {
      final candidateSkill = _candidateSkills.firstWhere((cs) => cs.skillId == skillId);
      await context.read<CandidateSkillProvider>().delete(candidateSkill.id);
    }
  }

  Map<String, dynamic> _getInitialValues() {
    if (!_isEditMode) {
      return {'isActive': true, 'experienceLevel': ExperienceLevel.entryLevel, 'pref_remote': Remote.no};
    }
    
    final map = _candidate!.toJson();
    if (_user != null) {
      map.addAll(_user!.toJson());
    }
    
    if (map['experienceLevel'] != null) {
      map['experienceLevel'] = _candidate!.experienceLevel;
    }
    
    if (_preferences != null) {
      if (_locations.isNotEmpty && _preferences!.locationId != null) {
        map['pref_locationId'] = _locations.firstWhere((l) => l.id == _preferences!.locationId);
      }
      if (_preferences!.employmentType != null) {
        map['pref_employmentType'] = _preferences!.employmentType;
      }
      if (_preferences!.remote != null) {
        map['pref_remote'] = _preferences!.remote;
      }
    }

    map['experienceYears'] = map['experienceYears']?.toString();
    if (map['locationId'] != null && _locations.isNotEmpty) {
      try {
        map['locationId'] = _locations.firstWhere((l) => l.id == map['locationId']);
      } catch (e) {
        map['locationId'] = null;
      }
    }
    
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _isEditMode ? "Edit Candidate Profile" : "Add New Candidate",
      selectedRoute: AppRouter.adminUserManagementRoute,
      child: PopScope(
        canPop: !_hasMadeChanges,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _hasMadeChanges) {
            _showUnsavedChangesDialog();
          }
        },
        child: _isLoading && _isEditMode && _candidate == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text("Error: $_error"))
                : _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return FormBuilder(
      key: _formKey,
      initialValue: _getInitialValues(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            _buildSectionHeader("Candidate Profile"),
            _buildProfileSection(),
            const Divider(height: 50, thickness: 0.5),

            _buildSectionHeader("Account Details"),
            _buildAccountSection(),
            const Divider(height: 50, thickness: 0.5),

            _buildSectionHeader("Job Preferences"),
            _buildPreferencesSection(),
            const Divider(height: 50, thickness: 0.5),

            _buildSectionHeader("Skills"),
            FormBuilderChips(
              name: 'skills',
              allSkills: _allSkills,
              initialValue: _candidateSkills.map((cs) => _allSkills.firstWhere((s) => s.id == cs.skillId)).toList(),
              validator: (skills) {
                if (skills == null || skills.isEmpty) {
                  return 'Please select at least one skill';
                }
                return null;
              },
            ),
            const Divider(height: 50, thickness: 0.5),

            _buildSubEntitySection<WorkExperience>(
              title: "Work Experience",
              data: _workExperiences,
              itemBuilder: (exp) => ListTile(
                leading: const Icon(Icons.work_history_outlined),
                title: Text(exp.position, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${exp.companyName} (${DateFormat.yMMM().format(exp.startDate)} - ${exp.endDate != null ? DateFormat.yMMM().format(exp.endDate!) : 'Present'})"),
              ),
              onAdd: () => _showWorkExperienceDialog(),
              onEdit: (exp) => _showWorkExperienceDialog(experience: exp),
              onDelete: (exp) => context.read<WorkExperienceProvider>().delete(exp.id),
            ),
            const Divider(height: 50, thickness: 0.5),

             _buildSubEntitySection<Education>(
              title: "Education",
              data: _educations,
              itemBuilder: (edu) => ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(edu.degree, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${edu.institution} - ${edu.fieldOfStudy}"),
              ),
              onAdd: () => _showEducationDialog(),
              onEdit: (edu) => _showEducationDialog(education: edu),
              onDelete: (edu) => context.read<EducationProvider>().delete(edu.id),
            ),
            const Divider(height: 50, thickness: 0.5),

            _buildCVSection(),
            const SizedBox(height: 50),

            _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.secondaryColor)),
          ],
        ],
      ),
    );
  }

  Widget _buildCVSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("CV / Resumes"),
            ElevatedButton.icon(
              onPressed: (!_isEditMode || _candidate == null) ? null : _uploadCv,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload CV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (!_isEditMode || _candidate == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Save the main candidate profile first to add items here.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          )
        else if (_cvDocuments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No CV documents uploaded yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload a CV to get started',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ...(_cvDocuments.map((cv) => _buildCVItem(cv)).toList()),
      ],
    );
  }

  Widget _buildCVItem(CVDocument cv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: cv.isMain ? AppTheme.confirmColor.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: cv.isMain ? AppTheme.confirmColor : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.fileName,
                  style: TextStyle(
                    fontWeight: cv.isMain ? FontWeight.bold : FontWeight.normal,
                    color: cv.isMain ? AppTheme.confirmColor : null,
                  ),
                ),
                if (cv.isMain)
                  const Text(
                    'Main CV',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.confirmColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!cv.isMain)
                IconButton(
                  onPressed: () => _setMainCv(cv),
                  icon: const Icon(Icons.star_border),
                  tooltip: 'Set as Main CV',
                  color: Colors.orange,
                ),
              IconButton(
                onPressed: () => _downloadCv(cv),
                icon: const Icon(Icons.download),
                tooltip: 'Download CV',
                color: AppTheme.primaryColor,
              ),
              IconButton(
                onPressed: () => _deleteCv(cv),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete CV',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: FormBuilderTextField(
              name: 'firstName', 
              decoration: const InputDecoration(labelText: 'First Name *'), 
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'First name is required.'),
                FormBuilderValidators.maxLength(100, errorText: 'First name cannot exceed 100 characters.')
              ])
            )),
            const SizedBox(width: 20),
            Expanded(child: FormBuilderTextField(
              name: 'lastName', 
              decoration: const InputDecoration(labelText: 'Last Name *'), 
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Last name is required.'),
                FormBuilderValidators.maxLength(100, errorText: 'Last name cannot exceed 100 characters.')
              ])
            )),
          ],
        ),
        const SizedBox(height: 20),
        FormBuilderTextField(
          name: 'title', 
          decoration: const InputDecoration(labelText: 'Title / Headline', hintText: 'e.g., Senior Software Engineer'),
          validator: FormBuilderValidators.maxLength(100, errorText: 'Title cannot exceed 100 characters.', checkNullOrEmpty: false)
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: FormBuilderTextField(
              name: 'phoneNumber', 
              decoration: const InputDecoration(labelText: 'Phone Number'), 
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.maxLength(20, errorText: 'Phone number cannot exceed 20 characters.', checkNullOrEmpty: false),
                FormBuilderValidators.match(RegExp(r'^\+?[0-9\s\-\(\)]+$'), errorText: 'Phone number format is invalid.', checkNullOrEmpty: false)
              ])
            )),
            const SizedBox(width: 20),
            Expanded(child: FormBuilderSearchableLocation(name: 'locationId', labelText: 'Location', locations: _locations)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: FormBuilderTextField(
              name: 'experienceYears', 
              decoration: const InputDecoration(labelText: 'Years of Experience *'), 
              keyboardType: TextInputType.number, 
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Experience years is required.'),
                FormBuilderValidators.integer(errorText: 'Experience years must be a valid number.'),
                FormBuilderValidators.min(0, errorText: 'Experience years must be between 0 and 100.'),
                FormBuilderValidators.max(100, errorText: 'Experience years must be between 0 and 100.')
              ])
            )),
            const SizedBox(width: 20),
            Expanded(child: FormBuilderDropdown<ExperienceLevel>(
              name: 'experienceLevel', 
              decoration: const InputDecoration(labelText: 'Experience Level *'), 
              items: ExperienceLevel.values.map((level) => DropdownMenuItem(value: level, child: Text(experienceLevelToString(level)))).toList(), 
              validator: FormBuilderValidators.required(errorText: 'Experience level is required.')
            )),
          ],
        ),
        const SizedBox(height: 20),
        FormBuilderTextField(
          name: 'bio', 
          decoration: const InputDecoration(labelText: 'Bio / Summary', border: OutlineInputBorder()), 
          maxLines: 5, 
          validator: FormBuilderValidators.maxLength(2000, errorText: 'Bio cannot exceed 2000 characters.', checkNullOrEmpty: false)
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        FormBuilderTextField(name: 'email', decoration: const InputDecoration(labelText: 'Email Address *'), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()])),
        const SizedBox(height: 20),
        FormBuilderTextField(
          name: 'password',
          decoration: InputDecoration(labelText: _isEditMode ? 'New Password (leave blank to keep current)' : 'Password *', helperText: 'Password must be at least 8 characters long.'),
          obscureText: true,
          validator: _isEditMode
              ? FormBuilderValidators.minLength(8, checkNullOrEmpty: false)
              : FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.minLength(8)]),
        ),
        if (!_isEditMode) ...[
          const SizedBox(height: 20),
          FormBuilderTextField(name: 'confirmPassword', decoration: const InputDecoration(labelText: 'Confirm Password *'), obscureText: true, validator: (val) {
              if (val != _formKey.currentState?.fields['password']?.value) return 'Passwords do not match';
              return null;
            }),
        ],
        const SizedBox(height: 30),
        if (_isEditMode) FormBuilderCheckbox(name: 'isActive', title: const Text('Account Active')),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: FormBuilderSearchableLocation(name: 'pref_locationId', labelText: 'Preferred Location', locations: _locations)),
            const SizedBox(width: 20),
            Expanded(child: FormBuilderDropdown<EmploymentType>(name: 'pref_employmentType', decoration: const InputDecoration(labelText: 'Preferred Employment Type'), items: EmploymentType.values.map((e) => DropdownMenuItem(value: e, child: Text(employmentTypeToString(e)))).toList())),
          ],
        ),
        const SizedBox(height: 20),
        FormBuilderDropdown<Remote>(name: 'pref_remote', decoration: const InputDecoration(labelText: 'Remote Work Preference'), items: Remote.values.map((r) => DropdownMenuItem(value: r, child: Text(remoteToString(r)))).toList()),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        if (!_isEditMode)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text("Save the main candidate profile first to add items here.", style: TextStyle(color: AppTheme.accentColor))),
          )
        else ...[
          if (data.isEmpty)
            const Center(child: Text("No items added yet.", style: TextStyle(color: Colors.grey)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  elevation: 1,
                  child: Stack(
                    children: [
                      itemBuilder(item),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => onEdit(item)),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: () async {
                              final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text("Delete Item?"), content: Text("Are you sure? This cannot be undone."), actions: [TextButton(onPressed:() => Navigator.pop(context, false), child: Text("Cancel")), ElevatedButton(onPressed:() => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text("Delete"))]));
                              if (confirmed == true) {
                                try {
                                  await onDelete(item);
                                  _showFeedback("Item deleted.");
                                  await _fetchCandidateSpecificData(_candidate!.id);
                                } catch (e) {
                                  _showFeedback(e.toString(), isError: true);
                                }
                              }
                            }),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text("Add New $title"),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isEditMode) ...[
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _deleteCandidate,
            icon: const Icon(Icons.delete_outline),
            label: const Text("DELETE CANDIDATE"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24)),
          ),
        ],
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(_hasMadeChanges),
          icon: const Icon(Icons.arrow_back),
          label: const Text("BACK"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(_isEditMode ? Icons.save_as_outlined : Icons.add_circle_outline),
            label: Text(_isEditMode ? "SAVE CHANGES" : "CREATE CANDIDATE"),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
          ),
        ),
      ],
    );
  }

  Future<void> _showUnsavedChangesDialog() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unsaved Changes"),
        content: const Text("You have unsaved changes. Are you sure you want to leave without saving?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Discard Changes"),
          ),
        ],
      ),
    );

    if (shouldDiscard == true) {
      setState(() => _hasMadeChanges = false);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      title: isError ? "Operation Failed" : "Success",
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: isError ? Colors.red.shade700 : AppTheme.confirmColor,
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
    ).show(context);
  }

  Future<void> _showWorkExperienceDialog({WorkExperience? experience}) async {
    if (!_isEditMode || _candidate == null) {
      _showFeedback('Please save the candidate first before adding work experience.', isError: true);
      return;
    }

    final result = await showDialog<WorkExperience>(
      context: context,
      builder: (context) => _WorkExperienceDialog(
        candidateId: _candidate!.id,
        experience: experience,
        locations: _locations,
      ),
    );

    if (result != null) {
      await _fetchCandidateSpecificData(_candidate!.id);
      _showFeedback(experience == null ? 'Work experience added successfully.' : 'Work experience updated successfully.');
    }
  }

  Future<void> _showEducationDialog({Education? education}) async {
    if (!_isEditMode || _candidate == null) {
      _showFeedback('Please save the candidate first before adding education.', isError: true);
      return;
    }

    final result = await showDialog<Education>(
      context: context,
      builder: (context) => _EducationDialog(
        candidateId: _candidate!.id,
        education: education,
      ),
    );

    if (result != null) {
      await _fetchCandidateSpecificData(_candidate!.id);
      _showFeedback(education == null ? 'Education added successfully.' : 'Education updated successfully.');
    }
  }

  Future<void> _uploadCv() async {
    if (!_isEditMode || _candidate == null) {
      _showFeedback('Please save the candidate first before uploading CV.', isError: true);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        
        if (bytes != null) {
          setState(() => _isLoading = true);
          
          try {
            final base64Content = base64Encode(bytes);
            
            final insertReq = CVDocumentInsertRequest(
              candidateId: _candidate!.id,
              fileName: file.name,
              fileContent: base64Content,
              isMain: _cvDocuments.isEmpty,
            );

            await context.read<CVDocumentProvider>().insert(insertReq);
            
            await _fetchCandidateSpecificData(_candidate!.id);
            
            _showFeedback('CV "${file.name}" uploaded successfully.');
            
            setState(() => _hasMadeChanges = true);
          } catch (e) {
            _showFeedback('Failed to upload CV: ${e.toString()}', isError: true);
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        } else {
          _showFeedback('Failed to read file content. Please try again.', isError: true);
        }
      } else {
      }
    } catch (e) {
      _showFeedback('Failed to select file: ${e.toString()}', isError: true);
    }
  }

  Future<void> _setMainCv(CVDocument cv) async {
    if (_isLoading) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set as Main CV'),
        content: Text('Set "${cv.fileName}" as the main CV? This will unmark any other CV as main.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.confirmColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set as Main'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await context.read<CVDocumentProvider>().setAsMain(
          cv.id,
        );

        await _fetchCandidateSpecificData(_candidate!.id);
        _showFeedback('"${cv.fileName}" set as main CV successfully.');
      } catch (e) {
        _showFeedback('Failed to set main CV: ${e.toString()}', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadCv(CVDocument cv) async {
    try {
      setState(() => _isLoading = true);
      
      final cvWithContent = await context.read<CVDocumentProvider>().getById(cv.id);
      
      final bytes = base64Decode(cvWithContent.fileContent);
        
      final result = await FileSaver.instance.saveFile(
          name: cv.fileName.split('.').first,
          bytes: bytes,
          fileExtension: cv.fileName.split('.').last,
        );
        
      _showFeedback('CV downloaded successfully. $result');
    } catch (e) {
      _showFeedback('Failed to download CV: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCv(CVDocument cv) async {
    if (_isLoading) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete CV'),
        content: Text('Are you sure you want to delete "${cv.fileName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await context.read<CVDocumentProvider>().delete(cv.id);
        await _fetchCandidateSpecificData(_candidate!.id);
        _showFeedback('CV "${cv.fileName}" deleted successfully.');
      } catch (e) {
        _showFeedback('Failed to delete CV: ${e.toString()}', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

class _WorkExperienceDialog extends StatefulWidget {
  final int candidateId;
  final WorkExperience? experience;
  final List<Location> locations;

  const _WorkExperienceDialog({
    required this.candidateId,
    this.experience,
    required this.locations,
  });

  @override
  State<_WorkExperienceDialog> createState() => _WorkExperienceDialogState();
}

class _WorkExperienceDialogState extends State<_WorkExperienceDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.experience == null ? 'Add Work Experience' : 'Edit Work Experience'),
      content: SizedBox(
        width: 500,
        child: FormBuilder(
          key: _formKey,
          initialValue: widget.experience != null ? {
            'position': widget.experience!.position,
            'companyName': widget.experience!.companyName,
            'description': widget.experience!.description,
            'startDate': widget.experience!.startDate,
            'endDate': widget.experience!.endDate,
          } : {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'position',
                decoration: const InputDecoration(labelText: 'Position *'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'companyName',
                decoration: const InputDecoration(labelText: 'Company Name *'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'startDate',
                      decoration: const InputDecoration(labelText: 'Start Date *'),
                      inputType: InputType.date,
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'endDate',
                      decoration: const InputDecoration(labelText: 'End Date'),
                      inputType: InputType.date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.experience == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final formData = _formKey.currentState!.value;
      
      if (widget.experience == null) {
        final insertReq = WorkExperienceInsertRequest(
          candidateId: widget.candidateId,
          position: formData['position'],
          companyName: formData['companyName'],
          description: formData['description'],
          startDate: formData['startDate'],
          endDate: formData['endDate'],
        );
        final result = await context.read<WorkExperienceProvider>().insert(insertReq);
        Navigator.of(context).pop(result);
      } else {
        final updateReq = WorkExperienceUpdateRequest(
          position: formData['position'],
          companyName: formData['companyName'],
          description: formData['description'],
          startDate: formData['startDate'],
          endDate: formData['endDate']
        );
        final result = await context.read<WorkExperienceProvider>().update(widget.experience!.id, updateReq);
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _EducationDialog extends StatefulWidget {
  final int candidateId;
  final Education? education;

  const _EducationDialog({
    required this.candidateId,
    this.education,
  });

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.education == null ? 'Add Education' : 'Edit Education'),
      content: SizedBox(
        width: 500,
        child: FormBuilder(
          key: _formKey,
          initialValue: widget.education != null ? {
            'degree': widget.education!.degree,
            'institution': widget.education!.institution,
            'fieldOfStudy': widget.education!.fieldOfStudy,
            'startDate': widget.education!.startDate,
            'endDate': widget.education!.endDate,
            'description': widget.education!.description,
          } : {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'degree',
                decoration: const InputDecoration(labelText: 'Degree *'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'institution',
                decoration: const InputDecoration(labelText: 'Institution *'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'fieldOfStudy',
                decoration: const InputDecoration(labelText: 'Field of Study *'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'startDate',
                      decoration: const InputDecoration(labelText: 'Start Date *'),
                      inputType: InputType.date,
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'endDate',
                      decoration: const InputDecoration(labelText: 'End Date'),
                      inputType: InputType.date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.education == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final formData = _formKey.currentState!.value;
      
      if (widget.education == null) {
        final insertReq = EducationInsertRequest(
          candidateId: widget.candidateId,
          degree: formData['degree'],
          institution: formData['institution'],
          fieldOfStudy: formData['fieldOfStudy'],
          startDate: formData['startDate'],
          endDate: formData['endDate'],
          description: formData['description'],
        );
        final result = await context.read<EducationProvider>().insert(insertReq);
        Navigator.of(context).pop(result);
      } else {
        final updateReq = EducationUpdateRequest(
          degree: formData['degree'],
          institution: formData['institution'],
          fieldOfStudy: formData['fieldOfStudy'],
          startDate: formData['startDate'],
          endDate: formData['endDate'],
          description: formData['description'],
        );
        final result = await context.read<EducationProvider>().update(widget.education!.id, updateReq);
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}