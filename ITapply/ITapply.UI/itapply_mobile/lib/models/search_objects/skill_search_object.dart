import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'skill_search_object.g.dart';

@JsonSerializable()
class SkillSearchObject extends BaseSearchObject {
  String? Name;

  SkillSearchObject({
    this.Name,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$SkillSearchObjectToJson(this);
}
