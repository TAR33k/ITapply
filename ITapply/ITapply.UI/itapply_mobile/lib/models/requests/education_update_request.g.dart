// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationUpdateRequest _$EducationUpdateRequestFromJson(
  Map<String, dynamic> json,
) => EducationUpdateRequest(
  institution: json['institution'] as String?,
  degree: json['degree'] as String?,
  fieldOfStudy: json['fieldOfStudy'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  description: json['description'] as String?,
);

Map<String, dynamic> _$EducationUpdateRequestToJson(
  EducationUpdateRequest instance,
) => <String, dynamic>{
  'institution': instance.institution,
  'degree': instance.degree,
  'fieldOfStudy': instance.fieldOfStudy,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'description': instance.description,
};
