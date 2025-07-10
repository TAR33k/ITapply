import 'package:itapply_desktop/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'education_search_object.g.dart';

@JsonSerializable()
class EducationSearchObject extends BaseSearchObject {
  int? CandidateId;
  String? Institution;
  String? Degree;
  String? FieldOfStudy;
  bool? IsCurrent;
  DateTime? StartDateFrom;
  DateTime? StartDateTo;
  DateTime? EndDateFrom;
  DateTime? EndDateTo;

  EducationSearchObject({
    this.CandidateId,
    this.Institution,
    this.Degree,
    this.FieldOfStudy,
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
  Map<String, dynamic> toJson() => _$EducationSearchObjectToJson(this);
}