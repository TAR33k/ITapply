import 'package:itapply_desktop/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employer_skill_search_object.g.dart';

@JsonSerializable()
class EmployerSkillSearchObject extends BaseSearchObject {
  int? EmployerId;
  int? SkillId;

  EmployerSkillSearchObject({
    this.EmployerId,
    this.SkillId,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$EmployerSkillSearchObjectToJson(this);
}