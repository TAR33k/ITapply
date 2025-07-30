import 'package:itapply_mobile/models/employer_skill.dart';
import 'package:itapply_mobile/models/requests/employer_skill_insert_request.dart';
import 'package:itapply_mobile/models/requests/employer_skill_update_request.dart';
import 'package:itapply_mobile/models/search_objects/employer_skill_search_object.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class EmployerSkillProvider extends BaseProvider<EmployerSkill, EmployerSkillSearchObject, EmployerSkillInsertRequest, EmployerSkillUpdateRequest> {
  EmployerSkillProvider() : super("EmployerSkill");

  @override
  EmployerSkill fromJson(data) {
    return EmployerSkill.fromJson(data);
  }
}
