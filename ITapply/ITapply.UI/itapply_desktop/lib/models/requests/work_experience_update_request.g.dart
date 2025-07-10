// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_experience_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkExperienceUpdateRequest _$WorkExperienceUpdateRequestFromJson(
  Map<String, dynamic> json,
) => WorkExperienceUpdateRequest(
  companyName: json['companyName'] as String?,
  position: json['position'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  description: json['description'] as String?,
);

Map<String, dynamic> _$WorkExperienceUpdateRequestToJson(
  WorkExperienceUpdateRequest instance,
) => <String, dynamic>{
  'companyName': instance.companyName,
  'position': instance.position,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'description': instance.description,
};
