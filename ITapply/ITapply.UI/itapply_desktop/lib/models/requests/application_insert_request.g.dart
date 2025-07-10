// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationInsertRequest _$ApplicationInsertRequestFromJson(
  Map<String, dynamic> json,
) => ApplicationInsertRequest(
  candidateId: (json['candidateId'] as num).toInt(),
  jobPostingId: (json['jobPostingId'] as num).toInt(),
  coverLetter: json['coverLetter'] as String?,
  cvDocumentId: (json['cvDocumentId'] as num).toInt(),
  availability: json['availability'] as String,
  receiveNotifications: json['receiveNotifications'] as bool?,
);

Map<String, dynamic> _$ApplicationInsertRequestToJson(
  ApplicationInsertRequest instance,
) => <String, dynamic>{
  'candidateId': instance.candidateId,
  'jobPostingId': instance.jobPostingId,
  'coverLetter': instance.coverLetter,
  'cvDocumentId': instance.cvDocumentId,
  'availability': instance.availability,
  'receiveNotifications': instance.receiveNotifications,
};
