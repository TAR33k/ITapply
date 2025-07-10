// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationSearchObject _$ApplicationSearchObjectFromJson(
  Map<String, dynamic> json,
) => ApplicationSearchObject(
  CandidateId: (json['CandidateId'] as num?)?.toInt(),
  JobPostingId: (json['JobPostingId'] as num?)?.toInt(),
  EmployerId: (json['EmployerId'] as num?)?.toInt(),
  JobTitle: json['JobTitle'] as String?,
  CandidateName: json['CandidateName'] as String?,
  Status: $enumDecodeNullable(_$ApplicationStatusEnumMap, json['Status']),
  ApplicationDateFrom: json['ApplicationDateFrom'] == null
      ? null
      : DateTime.parse(json['ApplicationDateFrom'] as String),
  ApplicationDateTo: json['ApplicationDateTo'] == null
      ? null
      : DateTime.parse(json['ApplicationDateTo'] as String),
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$ApplicationSearchObjectToJson(
  ApplicationSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'CandidateId': instance.CandidateId,
  'JobPostingId': instance.JobPostingId,
  'EmployerId': instance.EmployerId,
  'JobTitle': instance.JobTitle,
  'CandidateName': instance.CandidateName,
  'Status': _applicationStatusToJson(instance.Status),
  'ApplicationDateFrom': instance.ApplicationDateFrom?.toIso8601String(),
  'ApplicationDateTo': instance.ApplicationDateTo?.toIso8601String(),
};

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.applied: 'applied',
  ApplicationStatus.inConsideration: 'inConsideration',
  ApplicationStatus.interviewScheduled: 'interviewScheduled',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.pending: 'pending',
};
