// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
  id: (json['id'] as num).toInt(),
  candidateId: (json['candidateId'] as num).toInt(),
  candidateName: json['candidateName'] as String?,
  institution: json['institution'] as String,
  degree: json['degree'] as String,
  fieldOfStudy: json['fieldOfStudy'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  description: json['description'] as String?,
  isCurrent: json['isCurrent'] as bool,
  duration: json['duration'] as String?,
);

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
  'id': instance.id,
  'candidateId': instance.candidateId,
  'candidateName': instance.candidateName,
  'institution': instance.institution,
  'degree': instance.degree,
  'fieldOfStudy': instance.fieldOfStudy,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'description': instance.description,
  'isCurrent': instance.isCurrent,
  'duration': instance.duration,
};
