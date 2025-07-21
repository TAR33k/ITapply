import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/location.dart';
import 'package:itapply_desktop/models/requests/job_posting_insert_request.dart';
import 'package:itapply_desktop/models/requests/job_posting_update_request.dart';
import 'package:itapply_desktop/models/search_objects/employer_search_object.dart';
import 'package:itapply_desktop/models/search_objects/location_search_object.dart';
import 'package:itapply_desktop/models/search_objects/skill_search_object.dart';
import 'package:itapply_desktop/models/search_result.dart';
import 'package:itapply_desktop/models/skill.dart';
import 'package:itapply_desktop/providers/employer_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/location_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/widgets/form_builder_chips.dart';
import 'package:itapply_desktop/widgets/form_builder_searchable_location.dart';
import 'package:provider/provider.dart';

class AdminJobPostingDetailsScreen extends StatefulWidget {
  final JobPosting? jobPosting;
  const AdminJobPostingDetailsScreen({super.key, this.jobPosting});

  @override
  State<AdminJobPostingDetailsScreen> createState() => _AdminJobPostingDetailsScreenState();
}

class _AdminJobPostingDetailsScreenState extends State<AdminJobPostingDetailsScreen> {
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
      context.read<EmployerProvider>().get(filter: EmployerSearchObject(RetrieveAll: true)),
    ]);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      final formValues = _formKey.currentState!.value;

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
            employerId: formValues['employerId'],
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

  Future<void> _deleteJobPosting() async {
    if (!isEditMode) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete "${widget.jobPosting!.title}"? This action cannot be undone.'),
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
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await context.read<JobPostingProvider>().delete(widget.jobPosting!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job posting deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        _showError(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: isEditMode ? "Details - ${widget.jobPosting!.title}" : "Create New Job Posting",
      selectedRoute: '/admin-job-postings',
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

              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.length < 3) {
                return const Center(child: Text("Could not load required data."));
              }

              final skillsResult = snapshot.data![0] as SearchResult<Skill>?;
              final locationsResult = snapshot.data![1] as SearchResult<Location>?;
              final employersResult = snapshot.data![2] as SearchResult<Employer>?;

              if (skillsResult == null || locationsResult == null || employersResult == null) {
                return const Center(child: Text("Failed to load skills, locations, or employers."));
              }

              return _buildForm(skillsResult, locationsResult, employersResult);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(SearchResult<Skill> skills, SearchResult<Location> locations, SearchResult<Employer> employers) {
    final initialSkills = isEditMode
        ? skills.items!.where((s) => widget.jobPosting!.skills.any((js) => js.skillId == s.id)).toList()
        : <Skill>[];

    Location? initialLocation;
    if (isEditMode && widget.jobPosting!.locationId != null) {
      initialLocation = locations.items!.firstWhere((loc) => loc.id == widget.jobPosting!.locationId);
    }
    
    Employer? initialEmployer;
    if (isEditMode) {
      initialEmployer = employers.items!.firstWhere((emp) => emp.id == widget.jobPosting!.employerId);
    }

    return FormBuilder(
      key: _formKey,
      initialValue: isEditMode
          ? {
              'employerId': initialEmployer,
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
                FormBuilderTypeAhead<Employer?>(
                  name: 'employerId',
                  enabled: !isEditMode,
                  decoration: InputDecoration(
                    labelText: 'Employer *',
                    border: const OutlineInputBorder(),
                    filled: isEditMode,
                    fillColor: isEditMode ? Theme.of(context).disabledColor.withOpacity(0.1) : null,
                  ),
                  itemBuilder: (context, employer) => ListTile(title: Text(employer?.companyName ?? '')),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return employers.items!;
                    return employers.items!
                        .where((emp) => emp.companyName.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  selectionToTextTransformer: (employer) => employer?.companyName ?? "",
                  valueTransformer: (employer) => employer?.id,
                  validator: FormBuilderValidators.required(errorText: "Employer must be selected."),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: "title",
                  decoration: InputDecoration(
                    labelText: "Position Title *",
                    border: const OutlineInputBorder(),
                    counterText: "${_formKey.currentState?.fields['title']?.value?.length ?? 0} / 200",
                  ),
                  maxLength: 200,
                  maxLines: 1,
                  onChanged: (_) => setState(() {}),
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
                  labelText: "Job Location *",
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
                  onChanged: (_) => setState(() {}),
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
                  onChanged: (_) => setState(() {}),
                  validator: FormBuilderValidators.maxLength(5000, checkNullOrEmpty: false),
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
                  onChanged: (_) => setState(() {}),
                  validator: FormBuilderValidators.maxLength(3000, checkNullOrEmpty: false),
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
              initialValue: initialSkills,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isEditMode)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _isLoading ? null : _deleteJobPosting,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("DELETE", style: TextStyle(color: Colors.white)),
                  ),
                ),
              if (isEditMode) const SizedBox(width: 300),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditMode ? "SAVE CHANGES" : "CREATE POSTING"),
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