import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application_update_request.g.dart';

@JsonSerializable()
class ApplicationUpdateRequest {
  @JsonKey(toJson: _applicationStatusToJson)
  final ApplicationStatus? status;
  final String? internalNotes;
  final String? employerMessage;

  ApplicationUpdateRequest({
    required this.status,
    this.internalNotes,
    this.employerMessage,
  });

  factory ApplicationUpdateRequest.fromJson(Map<String, dynamic> json) => _$ApplicationUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationUpdateRequestToJson(this);
}

int? _applicationStatusToJson(ApplicationStatus? status) => status?.index;
