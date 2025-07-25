import 'package:itapply_desktop/models/job_posting_skill.dart';
import 'package:itapply_desktop/models/requests/job_posting_skill_insert_request.dart';
import 'package:itapply_desktop/models/requests/job_posting_skill_update_request.dart';
import 'package:itapply_desktop/models/search_objects/job_posting_skill_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class JobPostingSkillProvider extends BaseProvider<JobPostingSkill, 
    JobPostingSkillSearchObject, JobPostingSkillInsertRequest, JobPostingSkillUpdateRequest> {
  JobPostingSkillProvider() : super("JobPostingSkill");

  @override
  JobPostingSkill fromJson(data) {
    return JobPostingSkill.fromJson(data);
  }
}