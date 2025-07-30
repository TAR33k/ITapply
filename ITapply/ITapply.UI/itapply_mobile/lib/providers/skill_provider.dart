import 'package:itapply_mobile/models/requests/skill_insert_request.dart';
import 'package:itapply_mobile/models/requests/skill_update_request.dart';
import 'package:itapply_mobile/models/search_objects/skill_search_object.dart';
import 'package:itapply_mobile/models/skill.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class SkillProvider extends BaseProvider<Skill, 
    SkillSearchObject, SkillInsertRequest, SkillUpdateRequest> {
  SkillProvider() : super("Skill");

  @override
  Skill fromJson(data) {
    return Skill.fromJson(data);
  }
}
