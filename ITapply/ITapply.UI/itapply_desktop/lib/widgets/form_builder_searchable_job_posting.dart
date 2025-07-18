import 'package:flutter/material.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:itapply_desktop/models/job_posting.dart';

class FormBuilderSearchableJobPosting extends StatelessWidget {
  final List<JobPosting> jobPostings;
  final JobPosting? selectedJobPosting;
  final Function(JobPosting?) onChanged;
  final String labelText;
  final bool enabled;

  const FormBuilderSearchableJobPosting({
    super.key,
    required this.jobPostings,
    required this.selectedJobPosting,
    required this.onChanged,
    this.labelText = "Job posting",
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTypeAhead<JobPosting?>(
      name: 'job_posting_filter',
      decoration: InputDecoration(labelText: labelText, border: const OutlineInputBorder()),
      enabled: enabled,
      initialValue: selectedJobPosting,
      itemBuilder: (context, jobPosting) {
        if (jobPosting == null) {
          return const ListTile(
            title: Text("All job postings"),
            leading: Icon(Icons.clear_all),
          );
        }
        return ListTile(
          title: Text(jobPosting.title),
          subtitle: Text("Posted: ${jobPosting.postedDate.toString().split(' ')[0]}"),
        );
      },
      suggestionsCallback: (pattern) async {
        final allOption = [null]; 
        final filtered = jobPostings
            .where((job) =>
                job.title.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
        return [...allOption, ...filtered];
      },
      selectionToTextTransformer: (jobPosting) =>
          jobPosting != null ? jobPosting.title : "All job postings",
      onChanged: (jobPosting) => onChanged(jobPosting),
    );
  }
}