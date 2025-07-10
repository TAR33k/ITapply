import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
import 'package:provider/provider.dart';

class JobPostingDetailsScreen extends StatefulWidget {
  final JobPosting? jobPosting;
  const JobPostingDetailsScreen({super.key, this.jobPosting});

  @override
  State<JobPostingDetailsScreen> createState() => _JobPostingDetailsScreenState();
}

class _JobPostingDetailsScreenState extends State<JobPostingDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late JobPostingProvider _jobPostingProvider;
  bool _isLoading = false;

  late Future<SearchResult<Skill>> _skillsFuture;
  late Future<SearchResult<Employer>> _employersFuture;
  late Future<SearchResult<Location>> _locationsFuture;

  bool get isEditMode => widget.jobPosting != null;

  @override
  void initState() {
    super.initState();
    _jobPostingProvider = context.read<JobPostingProvider>();
    
    _skillsFuture = context.read<SkillProvider>().get(filter: SkillSearchObject(
      RetrieveAll: true,
    ));
    _employersFuture = context.read<EmployerProvider>().get(filter: EmployerSearchObject(
      RetrieveAll: true,
    ));
    _locationsFuture = context.read<LocationProvider>().get(filter: LocationSearchObject(
      RetrieveAll: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: isEditMode ? "Details - ${widget.jobPosting!.title}" : "Create New Job Posting",
      selectedRoute: '/job-posting-details',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder(
            future: Future.wait([_skillsFuture, _employersFuture, _locationsFuture]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error fetching dependencies: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.length < 3) {
                return const Center(child: Text("Could not load required data."));
              }
              
              final skills = snapshot.data![0] as SearchResult<Skill>;
              final employers = snapshot.data![1] as SearchResult<Employer>;
              final locations = snapshot.data![2] as SearchResult<Location>;

              return _buildForm(skills, employers, locations);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(SearchResult<Skill> skills, SearchResult<Employer> employers, SearchResult<Location> locations) {
    return FormBuilder(
      key: _formKey,
      initialValue: isEditMode ? {
        'employerId': widget.jobPosting!.employerId,
        'locationId': widget.jobPosting!.locationId,
        'title': widget.jobPosting!.title,
        'description': widget.jobPosting!.description,
        'requirements': widget.jobPosting!.requirements,
        'benefits': widget.jobPosting!.benefits,
        'employmentType': widget.jobPosting!.employmentType,
        'experienceLevel': widget.jobPosting!.experienceLevel,
        'remote': widget.jobPosting!.remote,
        'minSalary': widget.jobPosting!.minSalary.toString(),
        'maxSalary': widget.jobPosting!.maxSalary.toString(),
        'applicationDeadline': widget.jobPosting!.applicationDeadline,
        'status': widget.jobPosting!.status,
        'skillIds': widget.jobPosting!.skills.map((s) => s.skillId).toList(),
      } : {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection("Job Information", [
            if (!isEditMode) ...[
              FormBuilderDropdown<int>(
                name: 'employerId',
                decoration: const InputDecoration(labelText: 'Employer'),
                items: employers.items?.map((e) => DropdownMenuItem(value: e.id, child: Text(e.companyName))).toList() ?? [],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<int>(
                name: 'locationId',
                decoration: const InputDecoration(labelText: 'Location'),
                items: locations.items?.map((l) => DropdownMenuItem(value: l.id, child: Text("${l.city}, ${l.country}"))).toList() ?? [],
              ),
              const SizedBox(height: 16),
            ],
            FormBuilderTextField(
              name: "title",
              decoration: const InputDecoration(labelText: "Job Title"),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: "description",
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 5,
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: "requirements",
              decoration: const InputDecoration(labelText: "Requirements"),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: "benefits",
              decoration: const InputDecoration(labelText: "Benefits"),
              maxLines: 3,
            ),
          ]),
          _buildSection("Details & Salary", [
            Row(children: [
              Expanded(child: FormBuilderDropdown<EmploymentType>(
                name: 'employmentType',
                decoration: const InputDecoration(labelText: 'Employment Type'),
                items: EmploymentType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                validator: FormBuilderValidators.required(),
              )),
              const SizedBox(width: 16),
              Expanded(child: FormBuilderDropdown<ExperienceLevel>(
                name: 'experienceLevel',
                decoration: const InputDecoration(labelText: 'Experience Level'),
                items: ExperienceLevel.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                validator: FormBuilderValidators.required(),
              )),
            ]),
            const SizedBox(height: 16),
            FormBuilderDropdown<Remote>(
              name: 'remote',
              decoration: const InputDecoration(labelText: 'Remote Policy'),
              items: Remote.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: FormBuilderTextField(
                name: 'minSalary',
                decoration: const InputDecoration(labelText: 'Minimum Salary (KM)'),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.integer(),
              )),
              const SizedBox(width: 16),
              Expanded(child: FormBuilderTextField(
                name: 'maxSalary',
                decoration: const InputDecoration(labelText: 'Maximum Salary (KM)'),
                keyboardType: TextInputType.number,
                 validator: FormBuilderValidators.integer(),
              )),
            ]),
          ]),
          _buildSection("Skills", [
            FormBuilderFilterChips<int>(
              name: 'skillIds',
              decoration: const InputDecoration(labelText: 'Required Skills', border: InputBorder.none),
              options: skills.items?.map((skill) => FormBuilderChipOption(value: skill.id, child: Text(skill.name))).toList() ?? [],
              spacing: 8.0,
            )
          ]),
           _buildSection("Administrative", [
             if (isEditMode) ...[
                FormBuilderDropdown<JobPostingStatus>(
                  name: 'status',
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: JobPostingStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
             ],
            FormBuilderDateTimePicker(
              name: 'applicationDeadline',
              inputType: InputType.date,
              decoration: const InputDecoration(labelText: 'Application Deadline'),
              validator: FormBuilderValidators.required(),
            ),
           ]),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEditMode ? "Save Changes" : "Create Job Posting"),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor)),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      var formValues = Map<String, dynamic>.from(_formKey.currentState!.value);
      
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
            skillIds: List<int>.from(formValues['skillIds'] ?? []),
            locationId: widget.jobPosting!.locationId,
          );
          await _jobPostingProvider.update(widget.jobPosting!.id, request);
        } else {
           final request = JobPostingInsertRequest(
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
            skillIds: List<int>.from(formValues['skillIds'] ?? []),
            employerId: formValues['employerId'],
            locationId: formValues['locationId'],
          );
          await _jobPostingProvider.insert(request);
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(isEditMode ? "Update Failed" : "Create Failed"),
              content: Text(e.toString().replaceFirst("Exception: ", "")),
              actions: [TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop())],
            ),
          );
        }
      } finally {
         if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}