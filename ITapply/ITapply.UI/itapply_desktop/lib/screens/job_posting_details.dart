import 'package:flutter/material.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/model/job_posting.dart';

class JobPostingDetailsScreen extends StatelessWidget {
  final JobPosting jobPosting;
  const JobPostingDetailsScreen({super.key, required this.jobPosting});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Job Posting Details",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(jobPosting.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildDetailRow("Employer Name", jobPosting.employerName),
            _buildDetailRow("Description", jobPosting.description),
            if (jobPosting.requirements != null && jobPosting.requirements!.isNotEmpty)
              _buildDetailRow("Requirements", jobPosting.requirements!),
            if (jobPosting.benefits != null && jobPosting.benefits!.isNotEmpty)
              _buildDetailRow("Benefits", jobPosting.benefits!),
            _buildDetailRow("Employment Type", jobPosting.employmentType.toString()),
            _buildDetailRow("Experience Level", jobPosting.experienceLevel.toString()),
            if (jobPosting.locationName != null && jobPosting.locationName!.isNotEmpty)
              _buildDetailRow("Location", jobPosting.locationName!),
            _buildDetailRow("Remote", jobPosting.remote.toString()),
            _buildDetailRow("Minimum Salary", jobPosting.minSalary.toString()),
            _buildDetailRow("Maximum Salary", jobPosting.maxSalary.toString()),
            _buildDetailRow("Application Deadline", jobPosting.applicationDeadline.toLocal().toString()),
            _buildDetailRow("Posted Date", jobPosting.postedDate.toLocal().toString()),
            _buildDetailRow("Status", jobPosting.status.toString()),
            _buildDetailRow("Application Count", jobPosting.applicationCount.toString()),
            const SizedBox(height: 16),
            Text("Skills Required:", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (jobPosting.skills.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: jobPosting.skills.map((skill) => Chip(label: Text(skill.name))).toList(),
              )
            else
              const Text("No skills listed."),
          ],
        ),
      ),
    );
  }
}
