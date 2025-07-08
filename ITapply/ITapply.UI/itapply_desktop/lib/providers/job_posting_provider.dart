import 'package:itapply_desktop/model/job_posting.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class JobPostingProvider extends BaseProvider<JobPosting> {
  JobPostingProvider() : super("JobPosting");

  @override
  JobPosting fromJson(dynamic data) {
    return JobPosting.fromJson(data);
  }
}