// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  id: (json['id'] as num).toInt(),
  candidateId: (json['candidateId'] as num).toInt(),
  candidateName: json['candidateName'] as String?,
  candidateEmail: json['candidateEmail'] as String?,
  jobPostingId: (json['jobPostingId'] as num).toInt(),
  jobTitle: json['jobTitle'] as String?,
  companyName: json['companyName'] as String?,
  applicationDate: DateTime.parse(json['applicationDate'] as String),
  status: $enumDecode(
    _$ApplicationStatusEnumMap,
    json['status'],
    unknownValue: ApplicationStatus.pending,
  ),
  coverLetter: json['coverLetter'] as String?,
  cvDocumentId: (json['cvDocumentId'] as num).toInt(),
  cvDocumentName: json['cvDocumentName'] as String?,
  availability: json['availability'] as String?,
  internalNotes: json['internalNotes'] as String?,
  employerMessage: json['employerMessage'] as String?,
  receiveNotifications: json['receiveNotifications'] as bool,
);

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'id': instance.id,
      'candidateId': instance.candidateId,
      'candidateName': instance.candidateName,
      'candidateEmail': instance.candidateEmail,
      'jobPostingId': instance.jobPostingId,
      'jobTitle': instance.jobTitle,
      'companyName': instance.companyName,
      'applicationDate': instance.applicationDate.toIso8601String(),
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'coverLetter': instance.coverLetter,
      'cvDocumentId': instance.cvDocumentId,
      'cvDocumentName': instance.cvDocumentName,
      'availability': instance.availability,
      'internalNotes': instance.internalNotes,
      'employerMessage': instance.employerMessage,
      'receiveNotifications': instance.receiveNotifications,
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.applied: 'applied',
  ApplicationStatus.inConsideration: 'inConsideration',
  ApplicationStatus.interviewScheduled: 'interviewScheduled',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.pending: 'pending',
};
