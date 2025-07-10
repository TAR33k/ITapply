import 'package:itapply_desktop/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application.g.dart';
@JsonSerializable(explicitToJson: true)
class Application {
  final int id;
  final int candidateId;
  final String? candidateName;
  final String? candidateEmail;
  final int jobPostingId;
  final String? jobTitle;
  final String? companyName;
  final DateTime applicationDate;
  @JsonKey(unknownEnumValue: ApplicationStatus.pending)
  final ApplicationStatus status;
  final String? coverLetter;
  final int cvDocumentId;
  final String? cvDocumentName;
  final String? availability;
  final String? internalNotes;
  final String? employerMessage;
  final bool receiveNotifications;
  
  Application({
    required this.id,
    required this.candidateId,
    this.candidateName,
    this.candidateEmail,
    required this.jobPostingId,
    this.jobTitle,
    this.companyName,
    required this.applicationDate,
    required this.status,
    this.coverLetter,
    required this.cvDocumentId,
    this.cvDocumentName,
    this.availability,
    this.internalNotes,
    this.employerMessage,
    required this.receiveNotifications,
  });

  factory Application.fromJson(Map<String, dynamic> json) => _$ApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}