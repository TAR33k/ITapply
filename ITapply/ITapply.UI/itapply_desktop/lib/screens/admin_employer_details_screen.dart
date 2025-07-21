import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/employer_skill.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/requests/employer_insert_request.dart';
import 'package:itapply_desktop/models/requests/employer_skill_insert_request.dart';
import 'package:itapply_desktop/models/requests/employer_update_request.dart';
import 'package:itapply_desktop/models/requests/user_insert_request.dart';
import 'package:itapply_desktop/models/requests/user_update_request.dart';
import 'package:itapply_desktop/models/role.dart';
import 'package:itapply_desktop/models/search_objects/employer_skill_search_object.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/models/search_objects/role_search_object.dart';
import 'package:itapply_desktop/models/search_objects/skill_search_object.dart';
import 'package:itapply_desktop/models/skill.dart';
import 'package:itapply_desktop/models/user.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/employer_skill_provider.dart';
import 'package:itapply_desktop/providers/location_provider.dart';
import 'package:itapply_desktop/providers/role_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:itapply_desktop/providers/user_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/widgets/form_builder_chips.dart';
import 'package:itapply_desktop/widgets/form_builder_searchable_location.dart';
import 'package:provider/provider.dart';

class AdminEmployerDetailsScreen extends StatefulWidget {
  final Employer? employer;
  const AdminEmployerDetailsScreen({super.key, this.employer});

  @override
  State<AdminEmployerDetailsScreen> createState() =>
      _AdminEmployerDetailsScreenState();
}

class _AdminEmployerDetailsScreenState
    extends State<AdminEmployerDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool _isEditMode = false;
  bool _isLoading = true;
  String? _error;
  bool _hasMadeChanges = false;

  Employer? _employer;
  User? _user;
  List<EmployerSkill> _employerSkills = [];
  List<Location> _locations = [];
  List<Skill> _allSkills = [];
  Role? _employerRole;

  String? _logoBase64;
  ImageProvider? _logoPreview;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.employer != null;
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
            .get(filter: RoleSearchObject(Name: "Employer")),
      ]);

      _locations = results[0].items as List<Location>;
      _allSkills = results[1].items as List<Skill>;
      _employerRole = (results[2].items as List<Role>).first;

      if (_isEditMode) {
        await _fetchEmployerSpecificData(widget.employer!.id);
      } else {
        _logoPreview = const AssetImage("assets/placeholder_logo.png");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load required data: ${e.toString().replaceFirst("Exception: ", "")}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchEmployerSpecificData(int employerId) async {
    try {
      final results = await Future.wait([
        context.read<EmployerProvider>().getById(employerId),
        context.read<UserProvider>().getById(employerId),
      ]);

      final employerSkills = await context.read<EmployerSkillProvider>().get(
            filter: EmployerSkillSearchObject(
                EmployerId: employerId, RetrieveAll: true));

      if (mounted) {
        _employer = results[0] as Employer?;
        _user = results[1] as User?;
        _employerSkills = employerSkills.items!;
        _updateLogoPreview();

        _formKey.currentState?.patchValue(_getInitialValues());
      }
    } catch (e) {
      if (mounted) _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      _showFeedback("Please correct all validation errors before saving.",
          isError: true);
      return;
    }
    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        await _handleUpdate();
        _showFeedback("Employer updated successfully.");
      } else {
        await _handleCreate();
        _showFeedback("Employer created successfully.");
      }
      _hasMadeChanges = true;
    } catch (e) {
      _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _logoBase64 = null;
        });
      }
    }
  }

  Future<void> _handleCreate() async {
    final formData = _formKey.currentState!.value;

    final userInsertReq = UserInsertRequest(
      email: formData['email'],
      password: formData['password'],
      roleIds: [_employerRole!.id],
    );
    final newUser = await context.read<UserProvider>().insert(userInsertReq);

    final employerInsertReq = EmployerInsertRequest(
      userId: newUser.id,
      companyName: formData['companyName'],
      industry: formData['industry'],
      yearsInBusiness: formData['yearsInBusiness'],
      description: formData['description'],
      benefits: formData['benefits'],
      address: formData['address'],
      size: formData['size'],
      website: _prepareWebsiteUrl(formData['website']),
      contactEmail: formData['contactEmail'],
      contactPhone: formData['contactPhone'],
      locationId: formData['locationId'],
      logo: _logoBase64,
    );
    final newEmployer =
        await context.read<EmployerProvider>().insert(employerInsertReq);

    final List<Skill> selectedSkills =
        List<Skill>.from(formData['skills'] ?? []);
    if (selectedSkills.isNotEmpty) {
      final skillFutures = selectedSkills.map((skill) => context
          .read<EmployerSkillProvider>()
          .insert(EmployerSkillInsertRequest(
              employerId: newEmployer.id, skillId: skill.id)));
      await Future.wait(skillFutures);
    }

    setState(() {
      _isEditMode = true;
      _employer = newEmployer;
      _user = newUser;
    });
    await _fetchEmployerSpecificData(newEmployer.id);
  }

  Future<void> _handleUpdate() async {
    final formData = _formKey.currentState!.value;
    final employerUpdateReq = EmployerUpdateRequest(
      companyName: formData['companyName'],
      industry: formData['industry'],
      yearsInBusiness: formData['yearsInBusiness'],
      description: formData['description'],
      benefits: formData['benefits'],
      address: formData['address'],
      size: formData['size'],
      website: _prepareWebsiteUrl(formData['website']),
      contactEmail: formData['contactEmail'],
      contactPhone: formData['contactPhone'],
      locationId: formData['locationId'],
      logo: _logoBase64,
    );

    final userUpdateReq = UserUpdateRequest(
      email: formData['email'],
      password:
          formData['password']?.isNotEmpty == true ? formData['password'] : null,
      isActive: formData['isActive'],
    );

    await Future.wait([
      context.read<EmployerProvider>().update(_employer!.id, employerUpdateReq),
      context.read<UserProvider>().update(_user!.id, userUpdateReq),
      _updateSkills(formData['skills']),
    ]);
    await _fetchEmployerSpecificData(_employer!.id);
  }

  Future<void> _updateSkills(List<dynamic>? selectedSkillsList) async {
    final currentSkillIds = _employerSkills.map((es) => es.skillId).toSet();
    final selectedSkills = List<Skill>.from(selectedSkillsList ?? []);
    final selectedSkillIds = selectedSkills.map((s) => s.id).toSet();

    final skillsToAdd = selectedSkillIds.difference(currentSkillIds);
    final skillsToRemove = currentSkillIds.difference(selectedSkillIds);

    final List<Future> futures = [];
    final provider = context.read<EmployerSkillProvider>();

    for (final skillId in skillsToRemove) {
      final skillToRemove =
          _employerSkills.firstWhere((es) => es.skillId == skillId);
      futures.add(provider.delete(skillToRemove.id));
    }
    for (final skillId in skillsToAdd) {
      futures.add(provider.insert(EmployerSkillInsertRequest(
          employerId: _employer!.id, skillId: skillId)));
    }
    if (futures.isNotEmpty) await Future.wait(futures);
  }

  Future<void> _approveEmployer() async {
    if (_employer == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Approve Employer"),
        content: Text("Are you sure you want to approve ${_employer!.companyName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Approve"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final updatedEmployer = await context
            .read<EmployerProvider>()
            .updateVerificationStatus(_employer!.id, VerificationStatus.approved);
        
        setState(() {
          _employer = updatedEmployer;
          _hasMadeChanges = true;
        });
        
        _showFeedback("Employer approved successfully.");
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectEmployer() async {
    if (_employer == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Employer"),
        content: Text("Are you sure you want to reject ${_employer!.companyName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final updatedEmployer = await context
            .read<EmployerProvider>()
            .updateVerificationStatus(_employer!.id, VerificationStatus.rejected);
        
        setState(() {
          _employer = updatedEmployer;
          _hasMadeChanges = true;
        });
        
        _showFeedback("Employer rejected successfully.");
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setPendingStatus() async {
    if (_employer == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Pending Status"),
        content: Text("Are you sure you want to set ${_employer!.companyName} status to pending?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Set Pending"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final updatedEmployer = await context
            .read<EmployerProvider>()
            .updateVerificationStatus(_employer!.id, VerificationStatus.pending);
        
        setState(() {
          _employer = updatedEmployer;
          _hasMadeChanges = true;
        });
        
        _showFeedback("Employer status set to pending successfully.");
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEmployer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Employer"),
        content: Text(
          "Are you sure you want to delete ${_employer?.companyName ?? 'this employer'}? This action cannot be undone.",
        ),
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
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && _employer != null) {
      setState(() => _isLoading = true);
      try {
        await context.read<EmployerProvider>().delete(_employer!.id);
        _showFeedback("Employer deleted successfully.");
        
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            }
          });
        }
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""), isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _logoBase64 = base64Encode(bytes);
        _logoPreview = MemoryImage(bytes);
      });
    }
  }
  
  Map<String, dynamic> _getInitialValues() {
    if (!_isEditMode) {
      return {'isActive': true, 'skills': <Skill>[]};
    }

    final map = _employer!.toJson();
    map.addAll(_user!.toJson());

    if (map['yearsInBusiness'] != null) {
      map['yearsInBusiness'] = map['yearsInBusiness'].toString();
    }
    if (map['locationId'] != null && _locations.isNotEmpty) {
      try {
        map['locationId'] =
            _locations.firstWhere((l) => l.id == map['locationId']);
      } catch (e) {
        map['locationId'] = null;
      }
    }
    if (_allSkills.isNotEmpty) {
      final skillsMap = {for (var s in _allSkills) s.id: s};
      map['skills'] = _employerSkills
          .map((es) => skillsMap[es.skillId])
          .where((s) => s != null)
          .cast<Skill>()
          .toList();
    }
    return map;
  }

  void _updateLogoPreview() {
    if (_employer?.logo != null && _employer!.logo!.isNotEmpty) {
      _logoPreview = MemoryImage(base64Decode(_employer!.logo!));
    } else {
      _logoPreview = const AssetImage("assets/placeholder_logo.png");
    }
  }

  String _prepareWebsiteUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (!url.startsWith(RegExp(r'https?://'))) {
      return 'https://$url';
    }
    return url;
  }

  String _getStatusDescription(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return "This employer is pending verification. You can approve or reject this employer.";
      case VerificationStatus.approved:
        return "This employer has been verified and approved. You can reject this employer from the platform.";
      case VerificationStatus.rejected:
        return "This employer has been rejected and cannot access the platform. You can approve or set to pending.";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _isEditMode ? "Edit Employer Profile" : "Add New Employer",
      selectedRoute: AppRouter.adminUserManagementRoute,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
        },
        child: _isLoading && _employer == null && _isEditMode
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Company Profile"),
            _buildProfileSection(),
            const Divider(height: 50, thickness: 0.5),
            _buildSectionHeader("Account Details"),
            _buildAccountSection(),
            const Divider(height: 50, thickness: 0.5),
            _buildSectionHeader("Company Skills",
                subtitle: "Select skills that represent the company's technology stack and expertise."),
            _buildSkillsSection(),
            const SizedBox(height: 30),
            if (_isEditMode && _employer != null) ...[
              const Divider(height: 50, thickness: 0.5),
              _buildVerificationSection(),
              const SizedBox(height: 30),
            ],
            _buildActionButtons(),
          ],
        ),
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

  Widget _buildProfileSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _logoPreview != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(image: _logoPreview!, fit: BoxFit.cover))
                      : const Icon(Icons.business, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: const Icon(Icons.upload_outlined, size: 16),
                  label: const Text("Upload Logo"),
                  style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: FormBuilderTextField(name: 'companyName', decoration: const InputDecoration(labelText: 'Company Name *', prefixIcon: Icon(Icons.business_outlined)), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(100)]))),
                      const SizedBox(width: 20),
                      Expanded(child: FormBuilderTextField(name: 'industry', decoration: const InputDecoration(labelText: 'Industry *', prefixIcon: Icon(Icons.category_outlined)), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(100)]))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: FormBuilderTextField(name: 'website', decoration: const InputDecoration(labelText: 'Company Website', prefixIcon: Icon(Icons.language_outlined), hintText: 'https://example.com'), validator: FormBuilderValidators.compose([FormBuilderValidators.url(errorText: 'Please enter a valid URL')]))),
                      const SizedBox(width: 20),
                      Expanded(child: FormBuilderSearchableLocation(name: 'locationId', labelText: 'Location *', locations: _locations, validator: FormBuilderValidators.required())),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: FormBuilderTextField(name: 'address', decoration: const InputDecoration(labelText: 'Company Address *', prefixIcon: Icon(Icons.location_on_outlined)), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(500)]))),
            const SizedBox(width: 20),
            Expanded(child: FormBuilderTextField(name: 'size', decoration: const InputDecoration(labelText: 'Company Size (e.g., 50-200) *', prefixIcon: Icon(Icons.people_outline)), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(50), FormBuilderValidators.match(RegExp(r'^\d+(-\d+)?\+?$'), errorText: 'Invalid format. Use "10", "1-10", or "10+".')]))),
            const SizedBox(width: 20),
            Expanded(child: FormBuilderTextField(name: 'yearsInBusiness', decoration: const InputDecoration(labelText: 'Years in Business *', prefixIcon: Icon(Icons.calendar_today_outlined)), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.integer(errorText: "Must be a whole number."), FormBuilderValidators.min(0, errorText: "Cannot be negative."), FormBuilderValidators.max(1000, errorText: "Value seems too high.")]), valueTransformer: (text) => int.tryParse(text ?? ''))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: FormBuilderTextField(name: 'contactEmail', decoration: const InputDecoration(labelText: 'Public Contact Email *', prefixIcon: Icon(Icons.alternate_email)), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()]))),
            const SizedBox(width: 20),
            Expanded(child: FormBuilderTextField(name: 'contactPhone', decoration: const InputDecoration(labelText: 'Public Contact Phone *', prefixIcon: Icon(Icons.phone_outlined)), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.match(RegExp(r'^\+?[0-9]{1,3}?[-\.\s]?(\(?\d{1,4}?\)?)?[-\.\s]?\d{1,4}[-\.\s]?\d{1,9}$'), errorText: 'Invalid phone number format.')]))),
          ],
        ),
        const SizedBox(height: 20),
        FormBuilderTextField(name: 'description', decoration: const InputDecoration(labelText: 'About The Company *', hintText: 'Describe the company culture, mission, and values...', border: OutlineInputBorder()), maxLines: 5, validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(5000)])),
        const SizedBox(height: 20),
        FormBuilderTextField(name: 'benefits', decoration: const InputDecoration(labelText: 'Employee Benefits *', hintText: 'List the benefits and perks the company offers...', border: OutlineInputBorder()), maxLines: 5, validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.maxLength(3000)])),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        FormBuilderTextField(name: 'email', decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email_outlined)), validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()])),
        const SizedBox(height: 20),
        FormBuilderTextField(
          name: 'password',
          decoration: InputDecoration(
            labelText: _isEditMode ? 'New Password (leave blank to keep current)' : 'Password *',
            prefixIcon: const Icon(Icons.lock_outlined),
            helperText: _isEditMode ? 'Only enter a password if you want to change it' : 'Password must be at least 8 characters long',
          ),
          obscureText: true,
          validator: _isEditMode
              ? FormBuilderValidators.compose([
                  (val) {
                    if (val != null && val.isNotEmpty && val.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  }
                ])
              : FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters')]),
        ),
        if (!_isEditMode) ...[
          const SizedBox(height: 20),
          FormBuilderTextField(
            name: 'confirmPassword',
            decoration: const InputDecoration(labelText: 'Confirm Password *', prefixIcon: Icon(Icons.lock_outlined)),
            obscureText: true,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              (value) {
                final password = _formKey.currentState?.fields['password']?.value;
                if (value != password) return 'Passwords do not match';
                return null;
              },
            ]),
          ),
        ],
        const SizedBox(height: 30),
        if (_isEditMode)
          FormBuilderCheckbox(name: 'isActive', title: const Text('Account Active'), subtitle: const Text('Uncheck to deactivate the employer account'), initialValue: true),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return FormBuilderChips(
              name: 'skills',
              allSkills: _allSkills,
              initialValue: _employerSkills.isNotEmpty && _allSkills.isNotEmpty
                  ? _employerSkills
                      .map((es) => _allSkills.firstWhere((s) => s.id == es.skillId, orElse: () => Skill(id: -1, name: '')))
                      .where((s) => s.id != -1)
                      .toList()
                  : [],
            );
  }

  Widget _buildVerificationSection() {
    if (_employer == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Verification Status",
            subtitle: "Manage employer verification status for platform access."),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text("Current Status: ", style: TextStyle(fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: verificationStatusColor(_employer!.verificationStatus),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      verificationStatusToString(_employer!.verificationStatus),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getStatusDescription(_employer!.verificationStatus),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (_employer!.verificationStatus != VerificationStatus.approved)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _approveEmployer,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("APPROVE"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  if (_employer!.verificationStatus != VerificationStatus.rejected)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _rejectEmployer,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text("REJECT"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  if (_employer!.verificationStatus != VerificationStatus.pending && _employer!.verificationStatus != VerificationStatus.approved)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _setPendingStatus,
                      icon: const Icon(Icons.pending_outlined),
                      label: const Text("SET PENDING"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isEditMode) ...[
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteEmployer,
              icon: const Icon(Icons.delete_outline),
              label: const Text("DELETE EMPLOYER"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
            ),
          ),
        ],
        Row(
          children: [
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () {
                  Navigator.of(context).pop(_hasMadeChanges);
                },
                icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.arrow_back),
                label: Text(_isEditMode ? "BACK" : "CANCEL"),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor, side: const BorderSide(color: AppTheme.primaryColor)),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(_isEditMode ? Icons.save_as_outlined : Icons.add_circle_outline),
                label: Text(_isEditMode ? "SAVE CHANGES" : "CREATE EMPLOYER"),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      title: isError ? "Operation Failed" : "Success",
      message: message,
      duration: const Duration(seconds: 1),
      backgroundColor: isError ? Colors.red.shade700 : AppTheme.confirmColor,
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
    ).show(context);
  }
}