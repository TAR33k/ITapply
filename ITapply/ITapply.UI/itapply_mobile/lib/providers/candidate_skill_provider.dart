import 'package:itapply_desktop/models/candidate_skill.dart';
import 'package:itapply_desktop/models/requests/candidate_skill_insert_request.dart';
import 'package:itapply_desktop/models/requests/candidate_skill_update_request.dart';
import 'package:itapply_desktop/models/search_objects/candidate_skill_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class CandidateSkillProvider extends BaseProvider<CandidateSkill, CandidateSkillSearchObject, CandidateSkillInsertRequest, CandidateSkillUpdateRequest> {
  CandidateSkillProvider() : super("CandidateSkill");

  @override
  CandidateSkill fromJson(data) {
    return CandidateSkill.fromJson(data);
  }
}