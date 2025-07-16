import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/requests/job_posting_insert_request.dart';
import 'package:itapply_desktop/models/requests/job_posting_update_request.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/models/search_objects/skill_search_object.dart';
import 'package:itapply_desktop/models/search_result.dart';
import 'package:itapply_desktop/models/skill.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/location_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/widgets/form_builder_chips.dart';
import 'package:itapply_desktop/widgets/form_builder_searchable_location.dart';
import 'package:provider/provider.dart';

class EmployerJobPostingDetailsScreen extends StatefulWidget {
  final JobPosting? jobPosting;
  const EmployerJobPostingDetailsScreen({super.key, this.jobPosting});

  @override
  State<EmployerJobPostingDetailsScreen> createState() => _EmployerJobPostingDetailsScreenState();
}

class _EmployerJobPostingDetailsScreenState extends State<EmployerJobPostingDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  late Future<List<dynamic>> _dependenciesFuture;

  bool get isEditMode => widget.jobPosting != null;

  @override
  void initState() {
    super.initState();
    _dependenciesFuture = Future.wait([
      context.read<SkillProvider>().get(filter: SkillSearchObject(RetrieveAll: true)),
      context.read<LocationProvider>().get(filter: LocationSearchObject(RetrieveAll: true)),
    ]);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      final formValues = _formKey.currentState!.value;
      final employerId = context.read<AuthProvider>().currentEmployer?.id;
      if (employerId == null) {
        _showError("Could not identify current employer.");
        return;
      }

      try {
        if (isEditMode) {
          final request = JobPostingUpdateRequest(
            title: formValues['title'],
            description: formValues['description'],
            requirements: formValues['requirements'],
            benefits: formValues['benefits'],
            employmentType: formValues['employmentType'],
            experienceLevel: formValues['experienceLevel'],
            remote: formValues['remote'],
            minSalary: int.tryParse(formValues['minSalary'] ?? ''),
            maxSalary: int.tryParse(formValues['maxSalary'] ?? ''),
            applicationDeadline: formValues['applicationDeadline'],
            status: formValues['status'],
            skillIds: (formValues['skills'] as List<Skill>).map((s) => s.id).toList(),
            locationId: formValues['locationId'],
          );
          await context.read<JobPostingProvider>().update(widget.jobPosting!.id, request);
        } else {
          final request = JobPostingInsertRequest(
            employerId: employerId,
            title: formValues['title'],
            description: formValues['description'],
            requirements: formValues['requirements'],
            benefits: formValues['benefits'],
            employmentType: formValues['employmentType'],
            experienceLevel: formValues['experienceLevel'],
            remote: formValues['remote'],
            minSalary: int.tryParse(formValues['minSalary'] ?? ''),
            maxSalary: int.tryParse(formValues['maxSalary'] ?? ''),
            applicationDeadline: formValues['applicationDeadline'],
            skillIds: (formValues['skills'] as List<Skill>).map((s) => s.id).toList(),
            locationId: formValues['locationId'],
          );
          await context.read<JobPostingProvider>().insert(request);
        }
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        _showError(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.replaceFirst("Exception: ", "")), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: isEditMode ? "Details - ${widget.jobPosting!.title}" : "Create New Job Posting",
      selectedRoute: '/job-posting-details',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<List<dynamic>>(
            future: _dependenciesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("Error fetching dependencies: ${snapshot.error}"),
                );
              }

              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.length < 2) {
                print("Snapshot data incomplete: ${snapshot.data}");
                return const Center(child: Text("Could not load required data."));
              }

              final skillsResult = snapshot.data![0];
              final locationsResult = snapshot.data![1];

              if (skillsResult == null || locationsResult == null) {
                return const Center(child: Text("One of the results was null."));
              }

              final skills = skillsResult as SearchResult<Skill>;
              final locations = locationsResult as SearchResult<Location>;

              return _buildForm(skills, locations);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(SearchResult<Skill> skills, SearchResult<Location> locations) {
    final initialSkills = isEditMode
        ? skills.items!.where((s) => widget.jobPosting!.skills.any((js) => js.skillId == s.id)).toList()
        : <Skill>[];

    Location? initialLocation;
    if (isEditMode && widget.jobPosting!.locationId != null) {
      initialLocation = locations.items!
          .firstWhere((loc) => loc.id == widget.jobPosting!.locationId);
    }

    return FormBuilder(
      key: _formKey,
      initialValue: isEditMode
          ? {
              'title': widget.jobPosting!.title,
              'description': widget.jobPosting!.description,
              'requirements': widget.jobPosting!.requirements,
              'benefits': widget.jobPosting!.benefits,
              'employmentType': widget.jobPosting!.employmentType,
              'experienceLevel': widget.jobPosting!.experienceLevel,
              'remote': widget.jobPosting!.remote,
              'minSalary': widget.jobPosting!.minSalary?.toString(),
              'maxSalary': widget.jobPosting!.maxSalary?.toString(),
              'applicationDeadline': widget.jobPosting!.applicationDeadline,
              'status': widget.jobPosting!.status,
              'locationId': initialLocation,
              'skills': initialSkills,
            }
          : {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormSection(
            title: "Core Information",
            child: Column(
              children: [
                FormBuilderTextField(
                  name: "title",
                  decoration: InputDecoration(
                    labelText: "Position Title *",
                    border: const OutlineInputBorder(),
                    counterText: "${_formKey.currentState?.fields['title']?.value?.length ?? 0} / 200",
                  ),
                  maxLength: 200,
                  maxLines: 1,
                  onChanged: (_) {
                    setState(() {});
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(200),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderSearchableLocation(
                  name: 'locationId',
                  locations: locations.items!,
                  validator: FormBuilderValidators.required(),
                  labelText: "Job Position *",
                ),
              ],
            ),
          ),
          _buildFormSection(
            title: "Position Details",
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: FormBuilderDropdown<EmploymentType>(
                    name: 'employmentType',
                    decoration: const InputDecoration(labelText: 'Employment Type *'),
                    items: EmploymentType.values.map((e) => DropdownMenuItem(value: e, child: Text(employmentTypeToString(e), style: TextStyle(color: employmentTypeColor(e)),))).toList(),
                    validator: FormBuilderValidators.required(),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: FormBuilderDropdown<ExperienceLevel>(
                    name: 'experienceLevel',
                    decoration: const InputDecoration(labelText: 'Experience Level *'),
                    items: ExperienceLevel.values.map((e) => DropdownMenuItem(value: e, child: Text(experienceLevelToString(e), style: TextStyle(color: experienceLevelColor(e)),))).toList(),
                    validator: FormBuilderValidators.required(),
                  )),
                ]),
                const SizedBox(height: 16),
                FormBuilderDropdown<Remote>(
                  name: 'remote',
                  decoration: const InputDecoration(labelText: 'Remote Policy *'),
                  items: Remote.values.map((e) => DropdownMenuItem(value: e, child: Text(remoteToString(e), style: TextStyle(color: remoteColor(e)),))).toList(),
                  validator: FormBuilderValidators.required(),
                ),
              ],
            )
          ),
          _buildFormSection(
            title: "Description & Salary",
            child: Column(
              children: [
                 FormBuilderTextField(
                  name: "description",
                  decoration: InputDecoration(
                    labelText: "Job Description *",
                    border: const OutlineInputBorder(),
                    counterText: "${_formKey.currentState?.fields['description']?.value?.length ?? 0} / 10000",
                  ),
                  maxLength: 10000,
                  maxLines: 6,
                  onChanged: (_) {
                    setState(() {});
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(10000),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: "requirements",
                  decoration: InputDecoration(
                    labelText: "Requirements",
                    border: const OutlineInputBorder(),
                    counterText: "${_formKey.currentState?.fields['requirements']?.value?.length ?? 0} / 5000",
                  ),
                  maxLength: 5000,
                  maxLines: 4,
                  onChanged: (_) {
                    setState(() {});
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.maxLength(5000, checkNullOrEmpty: false),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: "benefits",
                  decoration: InputDecoration(
                    labelText: "Benefits",
                    border: const OutlineInputBorder(),
                    counterText: "${_formKey.currentState?.fields['benefits']?.value?.length ?? 0} / 3000",
                  ),
                  maxLength: 3000,
                  maxLines: 3,
                  onChanged: (_) {
                    setState(() {});
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.maxLength(3000, checkNullOrEmpty: false),
                  ]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'minSalary',
                        decoration: const InputDecoration(labelText: 'Minimum Salary (KM)'),
                        keyboardType: TextInputType.number,
                        validator: (val) => _salaryValidator(val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'maxSalary',
                        decoration: const InputDecoration(labelText: 'Maximum Salary (KM)'),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          final err = _salaryValidator(val);
                          if (err != null) return err;
                          final min = int.tryParse(_formKey.currentState?.fields['minSalary']?.value ?? '');
                          final max = int.tryParse(val ?? '');
                          if (min != null && max != null && max < min) return 'Must be ≥ Minimum Salary';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ]
            ),
          ),
          _buildFormSection(
            title: "Required Skills",
            child: FormBuilderChips(
              name: 'skills',
              allSkills: skills.items!,
              initialSkills: initialSkills,
            ),
          ),
          if (isEditMode)
            _buildFormSection(
              title: "Administrative",
              child: Row(children: [
                Expanded(child: FormBuilderDropdown<JobPostingStatus>(
                  name: 'status',
                  decoration: const InputDecoration(labelText: 'Posting Status *'),
                  items: JobPostingStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(jobPostingStatusToString(e), style: TextStyle(color: jobPostingStatusColor(e)),))).toList(),
                  validator: FormBuilderValidators.required(),
                )),
                const SizedBox(width: 16),
                Expanded(child: FormBuilderDateTimePicker(
                  name: 'applicationDeadline',
                  inputType: InputType.date,
                  format: DateFormat("dd-MM-yyyy"),
                  decoration: const InputDecoration(
                    labelText: 'Application Deadline *',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                ),),
              ]),
            ),
          if (!isEditMode)
             _buildFormSection(
              title: "Administrative",
              child: FormBuilderDateTimePicker(
                name: 'applicationDeadline',
                inputType: InputType.date,
                format: DateFormat("dd-MM-yyyy"),
                decoration: const InputDecoration(
                  labelText: 'Application Deadline *',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.required(),
              ),
            ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditMode ? "SAVE CHANGES" : "CREATE POSTING"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _salaryValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final val = int.tryParse(value);
    if (val == null || val < 0) return 'Must be a positive number';
    return null;
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}