import 'package:flutter/material.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';

class JobPostingDetailsScreen extends StatefulWidget {
  const JobPostingDetailsScreen({super.key});

  @override
  State<JobPostingDetailsScreen> createState() =>
      _JobPostingDetailsScreenState();
}

class _JobPostingDetailsScreenState extends State<JobPostingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return const MasterScreen(
      title: "Job Posting Details",
      child: Center(child: Text("Job Details")),
    );
  }
}
