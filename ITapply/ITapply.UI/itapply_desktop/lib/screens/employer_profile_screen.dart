import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/employer_skill.dart';
import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/requests/change_password_request.dart';
import 'package:itapply_desktop/models/requests/employer_skill_insert_request.dart';
import 'package:itapply_desktop/models/requests/employer_update_request.dart';
import 'package:itapply_desktop/models/requests/user_update_request.dart';
import 'package:itapply_desktop/models/review.dart';
import 'package:itapply_desktop/models/search_objects/employer_skill_search_object.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/models/search_objects/review_search_object.dart';
import 'package:itapply_desktop/models/search_objects/skill_search_object.dart';
import 'package:itapply_desktop/models/search_result.dart';
import 'package:itapply_desktop/models/skill.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/employer_skill_provider.dart';
import 'package:itapply_desktop/providers/location_provider.dart';
import 'package:itapply_desktop/providers/review_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:itapply_desktop/providers/user_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/widgets/form_builder_chips.dart';
import 'package:itapply_desktop/widgets/form_builder_searchable_location.dart';
import 'package:itapply_desktop/widgets/tabbed_card.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final _profileFormKey = GlobalKey<FormBuilderState>();
  final _emailFormKey = GlobalKey<FormBuilderState>();
  final _passwordFormKey = GlobalKey<FormBuilderState>();

  bool _isLoading = true;
  String? _error;

  Employer? _employer;
  SearchResult<Review>? _reviewsResult;
  double _averageRating = 0.0;
  Map<int, int> _ratingDistribution = {};

  String? _logoBase64;
  ImageProvider? _logoPreview;

  List<Location> _locations = [];
  List<Skill> _allSkills = [];
  List<EmployerSkill> _currentEmployerSkills = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentEmployer == null) {
        throw Exception("Employer profile not found. Please log in again.");
      }

      final employerId = authProvider.currentEmployer!.id;

      final results = await Future.wait([
        context.read<EmployerProvider>().getById(employerId),
        context.read<ReviewProvider>().get(
            filter: ReviewSearchObject(
                EmployerId: employerId, IncludeTotalCount: true, RetrieveAll: true)),
        context.read<LocationProvider>().get(filter: LocationSearchObject(RetrieveAll: true)),
        context.read<SkillProvider>().get(filter: SkillSearchObject(RetrieveAll: true)),
        context.read<EmployerSkillProvider>().get(
            filter: EmployerSkillSearchObject(
                EmployerId: employerId, RetrieveAll: true)),
      ]);

      if (mounted) {
        setState(() {
          _employer = results[0] as Employer;
          _reviewsResult = results[1] as SearchResult<Review>;
          _locations = (results[2] as SearchResult<Location>).items!;
          _allSkills = (results[3] as SearchResult<Skill>).items!;
          _currentEmployerSkills = (results[4] as SearchResult<EmployerSkill>).items!;

          if (_employer?.logo != null && _employer!.logo!.isNotEmpty) {
            _logoPreview = MemoryImage(base64Decode(_employer!.logo!));
          } else {
            _logoPreview = const AssetImage("assets/images/placeholder_logo.png");
          }
          _calculateReviewStats();

          _profileFormKey.currentState?.patchValue(_getInitialProfileValues());
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateReviewStats() {
    _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    if (_reviewsResult == null || _reviewsResult!.items!.isEmpty) {
      _averageRating = 0.0;
      return;
    }

    final reviews = _reviewsResult!.items;
    _averageRating = reviews!.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    for (var review in reviews) {
      _ratingDistribution[review.rating] = (_ratingDistribution[review.rating] ?? 0) + 1;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxHeight: 600, maxWidth: 600);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _logoBase64 = base64Encode(bytes);
        _logoPreview = MemoryImage(bytes);
        _profileFormKey.currentState?.fields['logo']?.didChange(_logoBase64);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_profileFormKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final form = _profileFormKey.currentState!.value;

        final currentSkillIds = _currentEmployerSkills.map((es) => es.skillId).toSet();
        
        final selectedSkills = List<Skill>.from(form['skills'] ?? []);
        final selectedSkillIds = selectedSkills.map((s) => s.id).toSet();

        final skillIdsToAdd = selectedSkillIds.difference(currentSkillIds);
        final skillIdsToRemove = currentSkillIds.difference(selectedSkillIds);

        final List<Future> skillUpdateFutures = [];
        final employerSkillProvider = context.read<EmployerSkillProvider>();

        for (final skillId in skillIdsToRemove) {
          final employerSkillToRemove =
              _currentEmployerSkills.firstWhere((es) => es.skillId == skillId);
          skillUpdateFutures.add(employerSkillProvider.delete(employerSkillToRemove.id));
        }

        for (final skillId in skillIdsToAdd) {
          final request = EmployerSkillInsertRequest(employerId: _employer!.id, skillId: skillId);
          skillUpdateFutures.add(employerSkillProvider.insert(request));
        }

        String website = form['website'] ?? '';
        if (website.isNotEmpty && !website.startsWith(RegExp(r'https?://'))) {
          website = 'https://$website';
        }

        final request = EmployerUpdateRequest(
          companyName: form['companyName'],
          industry: form['industry'],
          yearsInBusiness: form['yearsInBusiness'],
          description: form['description'],
          benefits: form['benefits'],
          address: form['address'],
          size: form['size'],
          website: website,
          contactEmail: form['contactEmail'],
          contactPhone: form['contactPhone'],
          locationId: form['locationId'],
          logo: _logoBase64,
        );

        final updatedEmployer =
            await context.read<EmployerProvider>().update(_employer!.id, request);
        context.read<AuthProvider>().setCurrentEmployer(updatedEmployer);

        if (skillUpdateFutures.isNotEmpty) {
          await Future.wait(skillUpdateFutures);
        }

        _showFeedback("Profile updated successfully.", isError: false);

        _fetchData();
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _logoBase64 = null;
          });
        }
      }
    } else {
      _showFeedback("Please fix the errors before saving.", isError: true);
    }
  }

  Future<void> _changeEmail() async {
    if (!(_emailFormKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final form = _emailFormKey.currentState!.value;
      final currentUser = context.read<AuthProvider>().currentUser!;
      
      if (form['newEmail'] == currentUser.email) {
        _emailFormKey.currentState!.fields['newEmail']?.invalidate('New email is the same as current email.');
        return;
      }
      
      final emailExists = await context.read<UserProvider>().checkEmailExists(form['newEmail']);
      if (emailExists) {
        _emailFormKey.currentState!.fields['newEmail']?.invalidate('This email is already taken.');
        return;
      }
      
      final request = UserUpdateRequest(
        email: form['newEmail'],
      );

      final updatedUser = await context.read<UserProvider>().update(currentUser.id, request);
      context.read<AuthProvider>().setCurrentUser(updatedUser);

      if (mounted) {
        _showFeedback("Email updated successfully.", isError: false);
        _emailFormKey.currentState?.reset();
        _emailFormKey.currentState?.patchValue({'newEmail': updatedUser.email});
      }
    } catch (e) {
      _showFeedback(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_passwordFormKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final form = _passwordFormKey.currentState!.value;
        final userId = context.read<AuthProvider>().currentUser!.id;
        final request = ChangePasswordRequest(
          oldPassword: form['oldPassword'],
          newPassword: form['newPassword'],
          confirmPassword: form['confirmPassword'],
        );

        await context.read<UserProvider>().changePassword(userId, request);

        if (mounted) {
          _showFeedback("Password changed successfully. Please log in again.", isError: false);
          _passwordFormKey.currentState?.reset();
          context.read<AuthProvider>().logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRouter.loginRoute, (route) => false);
        }
      } catch (e) {
        _showFeedback(e.toString().replaceFirst("Exception: ", ""));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
       _showFeedback("Please fix the errors before saving.", isError: true);
    }
  }

  void _showFeedback(String message, {bool isError = true}) {
    if (!mounted) return;
    Flushbar(
      title: isError ? "Operation Failed" : "Success",
      message: message,
      duration: const Duration(seconds: 4),
      backgroundColor: isError ? Colors.red.shade700 : AppTheme.confirmColor,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    ).show(context);
  }

  Map<String, dynamic> _getInitialProfileValues() {
    if (_employer == null) return {};

    final map = _employer!.toJson();

    if (map['yearsInBusiness'] != null) {
      map['yearsInBusiness'] = map['yearsInBusiness'].toString();
    }

    if (map['locationId'] != null && _locations.isNotEmpty) {
      try {
        final initialLocation = _locations.firstWhere((loc) => loc.id == map['locationId']);
        map['locationId'] = initialLocation;
      } catch (e) {
        map['locationId'] = null;
      }
    } else {
      map['locationId'] = null;
    }

    if (_allSkills.isNotEmpty) {
      final Map<int, Skill> allSkillsMap = {for (var s in _allSkills) s.id: s};
      final currentSkills = _currentEmployerSkills
          .map((es) => allSkillsMap[es.skillId])
          .where((s) => s != null)
          .cast<Skill>()
          .toList();
      
      map['skills'] = currentSkills;
    } else {
      map['skills'] = <Skill>[];
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _employer == null) {
      return MasterScreen(
        title: "Company Profile & Settings",
        selectedRoute: AppRouter.employerProfileRoute,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return MasterScreen(
        title: "Company Profile & Settings",
        selectedRoute: AppRouter.employerProfileRoute,
        child: Center(child: Text("Error: $_error", style: const TextStyle(color: Colors.red, fontSize: 16))),
      );
    }
    
    return MasterScreen(
      title: "Company Profile & Settings",
      selectedRoute: AppRouter.employerProfileRoute,
      child: _buildTabbedContent(),
    );
  }

  Widget _buildTabbedContent() {
    return Stack(
      children: [
        TabbedCard(
          title: _employer?.companyName ?? "Company Profile",
          icon: Icons.store_outlined,
          tabTitles: const ["Profile", "Reviews", "Account"],
          tabViews: [
            _buildProfileTab(),
            _buildReviewsTab(),
            _buildAccountTab(),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildProfileTab() {
    if (_employer == null) return const Center(child: Text("Profile data not available."));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: FormBuilder(
        key: _profileFormKey,
        initialValue: _getInitialProfileValues(),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'companyName',
                        decoration: const InputDecoration(
                            labelText: 'Company Name', prefixIcon: Icon(Icons.business_outlined)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(200)
                        ]),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: 'industry',
                        decoration: const InputDecoration(
                            labelText: 'Industry (e.g., Software Development)',
                            prefixIcon: Icon(Icons.factory_outlined)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(100)
                        ]),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: 'website',
                        decoration: const InputDecoration(
                            labelText: 'Company Website', prefixIcon: Icon(Icons.public_outlined)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.match(
                            RegExp(r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?$'),
                            errorText: "Enter a valid website URL (e.g., https://example.com)",
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderSearchableLocation(
                        name: 'locationId',
                        locations: _locations,
                        validator: FormBuilderValidators.required(
                            errorText: "Location is required"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text("Company Logo", style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              image: _logoPreview != null
                                  ? DecorationImage(
                                      image: _logoPreview!,
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                          child: _logoPreview == null
                              ? const Center(
                                  child: Icon(Icons.add_a_photo_outlined,
                                      color: AppTheme.secondaryColor, size: 40))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Upload New Logo")),
                      FormBuilderField<String>(
                        name: 'logo',
                        builder: (field) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40, thickness: 0.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'address',
                    decoration: const InputDecoration(
                        labelText: 'Company Address', prefixIcon: Icon(Icons.location_on_outlined)),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(500)
                    ]),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'size',
                    decoration: const InputDecoration(
                        labelText: 'Company Size (e.g., 50-200)',
                        prefixIcon: Icon(Icons.people_outline)),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(50),
                      FormBuilderValidators.match(RegExp(r'^\d+(-\d+)?\+?$'),
                          errorText: 'Invalid format. Use "10", "1-10", or "10+".'),
                    ]),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'yearsInBusiness',
                    decoration: const InputDecoration(
                        labelText: 'Years in Business',
                        prefixIcon: Icon(Icons.calendar_today_outlined)),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.integer(errorText: "Must be a whole number."),
                      FormBuilderValidators.min(0, errorText: "Cannot be negative."),
                      FormBuilderValidators.max(1000, errorText: "Value seems too high."),
                    ]),
                    valueTransformer: (text) => int.tryParse(text ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'contactEmail',
                    decoration: const InputDecoration(
                        labelText: 'Public Contact Email',
                        prefixIcon: Icon(Icons.alternate_email)),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'contactPhone',
                    decoration: const InputDecoration(
                        labelText: 'Public Contact Phone', prefixIcon: Icon(Icons.phone_outlined)),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.match(
                        RegExp(
                            r'^\+?[0-9]{1,3}?[-.\s]?(\(?\d{1,4}?\)?)[-.\s]?\d{1,4}[-.\s]?\d{1,9}$'),
                        errorText: 'Invalid phone number format.',
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            const Divider(height: 40, thickness: 0.5),
            FormBuilderTextField(
              name: 'description',
              decoration: const InputDecoration(
                  labelText: 'About The Company',
                  hintText: 'Describe your company culture, mission, and values...',
                  border: OutlineInputBorder()),
              maxLines: 5,
              validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(), FormBuilderValidators.maxLength(5000)]),
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'benefits',
              decoration: const InputDecoration(
                  labelText: 'Employee Benefits',
                  hintText: 'List the benefits and perks your company offers...',
                  border: OutlineInputBorder()),
              maxLines: 5,
              validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(), FormBuilderValidators.maxLength(3000)]),
            ),
            const Divider(height: 40, thickness: 0.5),
            Text("Company Skills", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              "Add skills that represent your company's technology stack and expertise. These will help candidates find you.",
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
            const SizedBox(height: 16),
            FormBuilderChips(
              name: 'skills',
              allSkills: _allSkills,
              initialValue: _currentEmployerSkills.isNotEmpty && _allSkills.isNotEmpty
                  ? _currentEmployerSkills
                      .map((es) => _allSkills.firstWhere((s) => s.id == es.skillId, orElse: () => Skill(id: -1, name: '')))
                      .where((s) => s.id != -1)
                      .toList()
                  : [],
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: const Icon(Icons.save_as_outlined),
                  label: const Text("SAVE PROFILE"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_reviewsResult == null || _reviewsResult!.items!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("No reviews yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(),
          const Divider(height: 40),
          Text("All Reviews (${_reviewsResult!.totalCount})",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildReviewsTable(),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 56, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < _averageRating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text("Based on ${_reviewsResult!.totalCount} reviews",
                  style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: _ratingDistribution.entries.map((entry) {
              final star = entry.key;
              final count = entry.value;
              final percentage =
                  _reviewsResult!.totalCount! > 0 ? count / _reviewsResult!.totalCount! : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text("$star star"),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearPercentIndicator(
                        percent: percentage,
                        lineHeight: 18.0,
                        backgroundColor: Colors.grey.shade300,
                        progressColor: AppTheme.primaryColor,
                        center: Text(
                          count.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        barRadius: const Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTable() {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Rating')),
          DataColumn(label: Expanded(child: Text('Comment'))),
          DataColumn(label: Text('Reviewer')),
          DataColumn(label: Text('Position')),
          DataColumn(label: Text('Date')),
        ],
        rows: _reviewsResult!.items!
            .map((review) => DataRow(cells: [
                  DataCell(Row(
                    children: [
                      Text(review.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  )),
                  DataCell(SizedBox(
                      width: 300,
                      child: Text(
                        review.comment ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ))),
                  DataCell(
                      Text("${review.candidateName} - ${reviewRelationshipToString(review.relationship)}")),
                  DataCell(Text(review.position ?? "")),
                  DataCell(Text(DateFormat.yMMMd().format(review.reviewDate))),
                ]))
            .toList(),
      ),
    );
  }

  Widget _buildAccountTab() {
    final currentUser = context.read<AuthProvider>().currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Account Settings", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            "Update your account information and security settings.",
            style: TextStyle(color: AppTheme.secondaryColor),
          ),
          const Divider(height: 40),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FormBuilder(
                key: _emailFormKey,
                initialValue: {
                  'newEmail': currentUser?.email ?? '',
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        Text("Change Email Address", style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Current Email: ${currentUser?.email ?? 'Not available'}", 
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor)),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'newEmail',
                      decoration: const InputDecoration(
                        labelText: "New Email Address",
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _changeEmail,
                        icon: const Icon(Icons.save),
                        label: const Text("UPDATE EMAIL"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FormBuilder(
                key: _passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        Text("Change Password", style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "For your security, you must enter your current password to change it.",
                      style: TextStyle(color: AppTheme.secondaryColor),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'oldPassword',
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Current Password",
                        prefixIcon: Icon(Icons.lock_clock_outlined),
                      ),
                      validator: FormBuilderValidators.required(errorText: "Current password is required"),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'newPassword',
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(8, errorText: "Password must be at least 8 characters long."),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'confirmPassword',
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Confirm New Password",
                        prefixIcon: Icon(Icons.lock_person_outlined),
                      ),
                      validator: (val) {
                        final newPassword = _passwordFormKey.currentState?.fields['newPassword']?.value;
                        if (val != newPassword) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _changePassword,
                        icon: const Icon(Icons.save),
                        label: const Text("CHANGE PASSWORD"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}