// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationInsertRequest _$EducationInsertRequestFromJson(
  Map<String, dynamic> json,
) => EducationInsertRequest(
  candidateId: (json['candidateId'] as num).toInt(),
  institution: json['institution'] as String,
  degree: json['degree'] as String,
  fieldOfStudy: json['fieldOfStudy'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  description: json['description'] as String?,
);

Map<String, dynamic> _$EducationInsertRequestToJson(
  EducationInsertRequest instance,
) => <String, dynamic>{
  'candidateId': instance.candidateId,
  'institution': instance.institution,
  'degree': instance.degree,
  'fieldOfStudy': instance.fieldOfStudy,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'description': instance.description,
};
