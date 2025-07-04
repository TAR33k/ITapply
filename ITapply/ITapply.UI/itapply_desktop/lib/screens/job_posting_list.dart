import 'package:flutter/material.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';

class JobPostingList extends StatefulWidget {
  const JobPostingList({super.key});

  @override
  State<JobPostingList> createState() => _JobPostingListState();
}

class _JobPostingListState extends State<JobPostingList> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Job Posting List",
      child: Center(child: Text("Jobs")),
    );
  }
}
