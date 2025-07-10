import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidate_search_object.g.dart';

@JsonSerializable()
class CandidateSearchObject extends BaseSearchObject {
  String? FirstName;
  String? LastName;
  String? Title;
  int? LocationId;
  int? MinExperienceYears;
  int? MaxExperienceYears;
  @JsonKey(name: 'ExperienceLevel', toJson: _experienceLevelToJson)
  ExperienceLevel? experienceLevel;
  String? Email;
  bool? IsActive;

  CandidateSearchObject({
    this.FirstName,
    this.LastName,
    this.Title,
    this.LocationId,
    this.MinExperienceYears,
    this.MaxExperienceYears,
    this.experienceLevel,
    this.Email,
    this.IsActive,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$CandidateSearchObjectToJson(this);
}

int? _experienceLevelToJson(ExperienceLevel? level) => level?.index;