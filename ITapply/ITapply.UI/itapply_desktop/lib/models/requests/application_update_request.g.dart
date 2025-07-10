// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationUpdateRequest _$ApplicationUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ApplicationUpdateRequest(
  status: $enumDecode(_$ApplicationStatusEnumMap, json['status']),
  internalNotes: json['internalNotes'] as String?,
  employerMessage: json['employerMessage'] as String?,
);

Map<String, dynamic> _$ApplicationUpdateRequestToJson(
  ApplicationUpdateRequest instance,
) => <String, dynamic>{
  'status': _applicationStatusToJson(instance.status),
  'internalNotes': instance.internalNotes,
  'employerMessage': instance.employerMessage,
};

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.applied: 0,
  ApplicationStatus.inConsideration: 1,
  ApplicationStatus.interviewScheduled: 2,
  ApplicationStatus.accepted: 3,
  ApplicationStatus.rejected: 4,
};
