import 'package:flutter/material.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/model/job_posting.dart';
import 'package:itapply_desktop/model/search_result.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/utils.dart';
import 'package:itapply_desktop/screens/job_posting_details.dart';
import 'package:provider/provider.dart';

class JobPostingList extends StatefulWidget {
  const JobPostingList({super.key});

  @override
  State<JobPostingList> createState() => _JobPostingListState();
}

class _JobPostingListState extends State<JobPostingList> {

  late JobPostingProvider jobPostingProvider;
  TextEditingController searchController = TextEditingController();

  SearchResult<JobPosting>? jobPostings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    jobPostingProvider = context.read<JobPostingProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Job Posting List",
      child: Column(
        children: [
          _buildSearch(),
          _buildJobPostingList(),
        ],
      )
    );
  }

  Widget _buildSearch() {
    return Padding(padding: EdgeInsets.all(15), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            var filter;
            if (searchController.text.trim().isNotEmpty) {
              filter = {"Title": searchController.text.trim()};
            } else {
              filter = null;
            }
            var jobs = await jobPostingProvider.get(filter);
            jobPostings = jobs;
            print("Job Postings: ${jobPostings?.items?.firstOrNull?.title}");
            setState(() {});
          },
          child: Text("Search"),
        ),
      ],
    ));
  }

  Widget _buildJobPostingList() {
    return Expanded(child: Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: DataTable(columns: [
        DataColumn(label: Text("Title")),
        DataColumn(label: Text("Description")),
        DataColumn(label: Text("Employer Name")),
        DataColumn(label: Text("Minimum Salary"))
      ], rows: jobPostings?.items?.map((job) => DataRow (
        onSelectChanged: (value) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => JobPostingDetailsScreen(jobPosting: job)
          ));
        },
        cells: [
          DataCell(Text(job.title)),
          DataCell(Text(job.description.substring(0, 50) + "...")),
          DataCell(Text(job.employerName)),
          DataCell(Text(formatNumber(job.minSalary))),
        ])
      ).toList() ?? []),
      )
    ));
  }
}
