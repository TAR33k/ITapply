import 'package:itapply_desktop/model/skill.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class SkillProvider extends BaseProvider<Skill> {
  SkillProvider() : super("Skill");

  @override
  Skill fromJson(dynamic json) {
    return Skill.fromJson(json);
  }
}