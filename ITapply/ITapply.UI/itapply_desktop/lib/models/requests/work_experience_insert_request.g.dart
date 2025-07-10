// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_experience_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkExperienceInsertRequest _$WorkExperienceInsertRequestFromJson(
  Map<String, dynamic> json,
) => WorkExperienceInsertRequest(
  candidateId: (json['candidateId'] as num).toInt(),
  companyName: json['companyName'] as String,
  position: json['position'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  description: json['description'] as String?,
);

Map<String, dynamic> _$WorkExperienceInsertRequestToJson(
  WorkExperienceInsertRequest instance,
) => <String, dynamic>{
  'candidateId': instance.candidateId,
  'companyName': instance.companyName,
  'position': instance.position,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'description': instance.description,
};
