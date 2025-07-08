import 'package:itapply_desktop/model/job_posting_skill.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class JobPostingSkillProvider extends BaseProvider<JobPostingSkill> {
  JobPostingSkillProvider() : super("JobPostingSkill");

  @override
  JobPostingSkill fromJson(dynamic data) {
    return JobPostingSkill.fromJson(data);
  }
}