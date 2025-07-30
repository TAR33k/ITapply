import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_search_object.g.dart';

@JsonSerializable()
class PreferencesSearchObject extends BaseSearchObject {
  int? CandidateId;
  int? LocationId;
  @JsonKey(name: 'EmploymentType',toJson: _employmentTypeToJson)
  EmploymentType? employmentType;
  @JsonKey(name: 'Remote',toJson: _remoteToJson)
  Remote? remote;

  PreferencesSearchObject({
    this.CandidateId,
    this.LocationId,
    this.employmentType,
    this.remote,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$PreferencesSearchObjectToJson(this);
}

int? _employmentTypeToJson(EmploymentType? type) => type?.index;
int? _remoteToJson(Remote? remote) => remote?.index;
