import 'package:itapply_desktop/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_posting_skill_search_object.g.dart';

@JsonSerializable()
class JobPostingSkillSearchObject extends BaseSearchObject {
  int? JobPostingId;
  int? SkillId;

  JobPostingSkillSearchObject({
    this.JobPostingId,
    this.SkillId,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$JobPostingSkillSearchObjectToJson(this);
}