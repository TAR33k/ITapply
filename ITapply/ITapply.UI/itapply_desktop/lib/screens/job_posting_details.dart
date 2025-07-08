import 'package:flutter/material.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/model/job_posting.dart';
import 'package:itapply_desktop/model/search_result.dart';
import 'package:itapply_desktop/model/skill.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class JobPostingDetailsScreen extends StatefulWidget {
  final JobPosting? jobPosting;
  const JobPostingDetailsScreen({super.key, this.jobPosting});

  @override
  State<JobPostingDetailsScreen> createState() => _JobPostingDetailsScreenState();
}

class _JobPostingDetailsScreenState extends State<JobPostingDetailsScreen> {
  late Future<SearchResult<Skill>?> _skillsFuture;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late SkillProvider _skillProvider;
  late JobPostingProvider _jobPostingProvider;

  final employmentTypes = {0: 'Full-time', 1: 'Part-time', 2: 'Contract', 3: 'Internship'};
  final experienceLevels = {0: 'EntryLevel', 1: 'Junior', 2: 'Mid', 3: 'Senior', 4: 'Lead'};
  final remoteOptions = {0: 'On-site', 1: 'Hybrid', 2: 'Remote'};
  final statusOptions = {0: 'Active', 1: 'Inactive', 2: 'Closed', 3: 'Draft'};

  bool get isEditMode => widget.jobPosting != null;

  @override
  void initState() {
    super.initState();
    _skillProvider = context.read<SkillProvider>();
    _jobPostingProvider = context.read<JobPostingProvider>();
    var filter = {"RetrieveAll": true};
    _skillsFuture = _skillProvider.get(filter: filter);

    if (isEditMode) {
      _initialValue = {
        "title": widget.jobPosting!.title,
        "description": widget.jobPosting!.description,
        "requirements": widget.jobPosting!.requirements,
        "benefits": widget.jobPosting!.benefits,
        "employmentType": widget.jobPosting!.employmentType,
        "experienceLevel": widget.jobPosting!.experienceLevel,
        "remote": widget.jobPosting!.remote,
        "minSalary": formatNumber(widget.jobPosting!.minSalary?.toString()),
        "maxSalary": formatNumber(widget.jobPosting!.maxSalary?.toString()),
        "applicationDeadline": widget.jobPosting!.applicationDeadline,
        "status": widget.jobPosting!.status,
        "skillIds": widget.jobPosting!.skills.map((skill) => skill.skillId).toList(),
        "employerName": widget.jobPosting!.employerName,
        "locationName": widget.jobPosting!.locationName,
        "postedDate": widget.jobPosting!.postedDate,
        "applicationCount": widget.jobPosting!.applicationCount.toString(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: isEditMode ? "Details - ${widget.jobPosting!.title}" : "Create New Job Posting",
      selectedRoute: '/job-posting',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<SearchResult<Skill>?>(
          future: _skillsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error fetching data: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data?.items == null) {
              return const Center(child: Text("No skills data available."));
            }
            return _buildForm(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildForm(SearchResult<Skill> skills) {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isEditMode) ...[
              _buildSectionHeader("Company & Location"),
              FormBuilderTextField(
                  name: "employerId",
                  decoration: const InputDecoration(labelText: "Employer ID"),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              FormBuilderTextField(
                  name: "locationId",
                  decoration: const InputDecoration(labelText: "Location ID (Optional)"),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 24),
            ],
            _buildSectionHeader("Job Information"),
            FormBuilderTextField(
              name: "title",
              decoration: const InputDecoration(labelText: "Job Title"),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: "description",
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 5,
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
            const SizedBox(height: 24),
            _buildSectionHeader("Details & Salary"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormBuilderDropdown(
                    name: "employmentType",
                    decoration: const InputDecoration(labelText: "Employment Type"),
                    items: employmentTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormBuilderDropdown(
                    name: "experienceLevel",
                    decoration: const InputDecoration(labelText: "Experience Level"),
                    items: experienceLevels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormBuilderDropdown(
                    name: "remote",
                    decoration: const InputDecoration(labelText: "Remote Policy"),
                    items: remoteOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  ),
             const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: "minSalary",
                    decoration: const InputDecoration(labelText: "Minimum Salary", prefixText: "\$ "),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormBuilderTextField(
                    name: "maxSalary",
                    decoration: const InputDecoration(labelText: "Maximum Salary", prefixText: "\$ "),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Skills"),
             FormBuilderFilterChips(
              name: 'skillIds',
              decoration: const InputDecoration(labelText: 'Required Skills', border: InputBorder.none),
              options: skills.items!.map((skill) => FormBuilderChipOption(value: skill.id, child: Text(skill.name))).toList(),
              spacing: 8.0,
              runSpacing: 6.0,
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            _buildSectionHeader("Administrative"),
            if (isEditMode) ...[ 
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDropdown(
                      name: "status",
                      decoration: const InputDecoration(labelText: "Status"),
                      items: statusOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderTextField(
                      name: "applicationCount",
                      decoration: const InputDecoration(labelText: "Application Count"),
                      enabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
             Row(
              children: [
                if (isEditMode)
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: "postedDate",
                      inputType: InputType.date,
                      decoration: const InputDecoration(labelText: "Posted Date"),
                      enabled: false,
                    ),
                  ),
                if (isEditMode) const SizedBox(width: 16),
                Expanded(
                  child: FormBuilderDateTimePicker(
                    name: "applicationDeadline",
                    inputType: InputType.date,
                    decoration: const InputDecoration(labelText: "Application Deadline"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(isEditMode ? "Save Changes" : "Create Job Posting"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor)),
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      var formValues = Map<String, dynamic>.from(_formKey.currentState!.value);

      if (formValues['applicationDeadline'] is DateTime) {
        formValues['applicationDeadline'] = (formValues['applicationDeadline'] as DateTime).toIso8601String();
      }
      formValues['minSalary'] = int.tryParse(formValues['minSalary'] ?? '0') ?? 0;
      formValues['maxSalary'] = int.tryParse(formValues['maxSalary'] ?? '0') ?? 0;
      
      try {
        if (isEditMode) {
          var request = {
            "title": formValues['title'],
            "description": formValues['description'],
            "requirements": formValues['requirements'],
            "benefits": formValues['benefits'],
            "employmentType": formValues['employmentType'],
            "experienceLevel": formValues['experienceLevel'],
            "remote": formValues['remote'],
            "minSalary": formValues['minSalary'],
            "maxSalary": formValues['maxSalary'],
            "applicationDeadline": formValues['applicationDeadline'],
            "status": formValues['status'],
            "skillIds": List<int>.from(formValues['skillIds'] ?? []),
            "locationId": widget.jobPosting!.locationId,
          };
          await _jobPostingProvider.update(widget.jobPosting!.id, request);
        } else {
          var request = {
            "title": formValues['title'],
            "description": formValues['description'],
            "requirements": formValues['requirements'],
            "benefits": formValues['benefits'],
            "employmentType": formValues['employmentType'],
            "experienceLevel": formValues['experienceLevel'],
            "remote": formValues['remote'],
            "minSalary": formValues['minSalary'],
            "maxSalary": formValues['maxSalary'],
            "applicationDeadline": formValues['applicationDeadline'],
            "skillIds": List<int>.from(formValues['skillIds'] ?? []),
            "employerId": int.tryParse(formValues['employerId'] ?? ''),
            "locationId": int.tryParse(formValues['locationId'] ?? ''),
          };
          await _jobPostingProvider.insert(request);
        }

        if (mounted) {
          final message = isEditMode ? 'Job Posting updated successfully!' : 'Job Posting created successfully!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(isEditMode ? "Update Failed" : "Create Failed"),
              content: Text(e.toString()),
              actions: [TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop())],
            ),
          );
        }
      }
    }
  }
}