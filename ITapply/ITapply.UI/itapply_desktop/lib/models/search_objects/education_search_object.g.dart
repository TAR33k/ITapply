// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationSearchObject _$EducationSearchObjectFromJson(
  Map<String, dynamic> json,
) => EducationSearchObject(
  CandidateId: (json['CandidateId'] as num?)?.toInt(),
  Institution: json['Institution'] as String?,
  Degree: json['Degree'] as String?,
  FieldOfStudy: json['FieldOfStudy'] as String?,
  IsCurrent: json['IsCurrent'] as bool?,
  StartDateFrom: json['StartDateFrom'] == null
      ? null
      : DateTime.parse(json['StartDateFrom'] as String),
  StartDateTo: json['StartDateTo'] == null
      ? null
      : DateTime.parse(json['StartDateTo'] as String),
  EndDateFrom: json['EndDateFrom'] == null
      ? null
      : DateTime.parse(json['EndDateFrom'] as String),
  EndDateTo: json['EndDateTo'] == null
      ? null
      : DateTime.parse(json['EndDateTo'] as String),
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$EducationSearchObjectToJson(
  EducationSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'CandidateId': instance.CandidateId,
  'Institution': instance.Institution,
  'Degree': instance.Degree,
  'FieldOfStudy': instance.FieldOfStudy,
  'IsCurrent': instance.IsCurrent,
  'StartDateFrom': instance.StartDateFrom?.toIso8601String(),
  'StartDateTo': instance.StartDateTo?.toIso8601String(),
  'EndDateFrom': instance.EndDateFrom?.toIso8601String(),
  'EndDateTo': instance.EndDateTo?.toIso8601String(),
};
