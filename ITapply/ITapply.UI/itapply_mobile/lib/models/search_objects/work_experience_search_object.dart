import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'work_experience_search_object.g.dart';

@JsonSerializable()
class WorkExperienceSearchObject extends BaseSearchObject {
  int? CandidateId;
  String? CompanyName;
  String? Position;
  bool? IsCurrent;
  DateTime? StartDateFrom;
  DateTime? StartDateTo;
  DateTime? EndDateFrom;
  DateTime? EndDateTo;

  WorkExperienceSearchObject({
    this.CandidateId,
    this.CompanyName,
    this.Position,
    this.IsCurrent,
    this.StartDateFrom,
    this.StartDateTo,
    this.EndDateFrom,
    this.EndDateTo,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$WorkExperienceSearchObjectToJson(this);
}
