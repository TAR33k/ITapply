import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_insert_request.g.dart';

@JsonSerializable()
class PreferencesInsertRequest {
  final int candidateId;
  final int? locationId;
  @JsonKey(toJson: _employmentTypeToJson)
  final EmploymentType? employmentType;
  @JsonKey(toJson: _remoteToJson)
  final Remote? remote;

  PreferencesInsertRequest({
    required this.candidateId,
    this.locationId,
    this.employmentType,
    this.remote,
  });

  factory PreferencesInsertRequest.fromJson(Map<String, dynamic> json) => _$PreferencesInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PreferencesInsertRequestToJson(this);
}

int? _employmentTypeToJson(EmploymentType? type) => type?.index;
int? _remoteToJson(Remote? remote) => remote?.index;
