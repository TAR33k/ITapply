import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidate_skill_search_object.g.dart';

@JsonSerializable()
class CandidateSkillSearchObject extends BaseSearchObject {
  int? CandidateId;
  int? SkillId;
  int? MinLevel;
  int? MaxLevel;

  CandidateSkillSearchObject({
    this.CandidateId,
    this.SkillId,
    this.MinLevel,
    this.MaxLevel,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$CandidateSkillSearchObjectToJson(this);
}
