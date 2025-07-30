// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_experience.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkExperience _$WorkExperienceFromJson(Map<String, dynamic> json) =>
    WorkExperience(
      id: (json['id'] as num).toInt(),
      candidateId: (json['candidateId'] as num).toInt(),
      candidateName: json['candidateName'] as String?,
      companyName: json['companyName'] as String,
      position: json['position'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      description: json['description'] as String?,
      isCurrent: json['isCurrent'] as bool,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$WorkExperienceToJson(WorkExperience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'candidateId': instance.candidateId,
      'candidateName': instance.candidateName,
      'companyName': instance.companyName,
      'position': instance.position,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'description': instance.description,
      'isCurrent': instance.isCurrent,
      'duration': instance.duration,
    };
