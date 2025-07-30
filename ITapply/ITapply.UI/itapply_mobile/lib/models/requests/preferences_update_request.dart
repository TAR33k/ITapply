import 'package:itapply_desktop/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_update_request.g.dart';

@JsonSerializable()
class PreferencesUpdateRequest {
  final int? locationId;
  @JsonKey(toJson: _employmentTypeToJson)
  final EmploymentType? employmentType;
  @JsonKey(toJson: _remoteToJson)
  final Remote? remote;

  PreferencesUpdateRequest({
    this.locationId,
    this.employmentType,
    this.remote,
  });

  factory PreferencesUpdateRequest.fromJson(Map<String, dynamic> json) => _$PreferencesUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PreferencesUpdateRequestToJson(this);
}

int? _employmentTypeToJson(EmploymentType? type) => type?.index;
int? _remoteToJson(Remote? remote) => remote?.index;