import 'package:json_annotation/json_annotation.dart';

part 'application_insert_request.g.dart';

@JsonSerializable()
class ApplicationInsertRequest {
  final int candidateId;
  final int jobPostingId;
  final String? coverLetter;
  final int cvDocumentId;
  final String availability;
  final bool? receiveNotifications;

  ApplicationInsertRequest({
    required this.candidateId,
    required this.jobPostingId,
    this.coverLetter,
    required this.cvDocumentId,
    required this.availability,
    this.receiveNotifications,
  });

  factory ApplicationInsertRequest.fromJson(Map<String, dynamic> json) => _$ApplicationInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationInsertRequestToJson(this);
}