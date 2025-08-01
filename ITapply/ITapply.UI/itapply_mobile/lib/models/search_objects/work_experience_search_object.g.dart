// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_experience_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
WorkExperienceSearchObject _$WorkExperienceSearchObjectFromJson(
  Map<String, dynamic> json,
) => WorkExperienceSearchObject(
  CandidateId: (json['CandidateId'] as num?)?.toInt(),
  CompanyName: json['CompanyName'] as String?,
  Position: json['Position'] as String?,
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

Map<String, dynamic> _$WorkExperienceSearchObjectToJson(
  WorkExperienceSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'CandidateId': instance.CandidateId,
  'CompanyName': instance.CompanyName,
  'Position': instance.Position,
  'IsCurrent': instance.IsCurrent,
  'StartDateFrom': instance.StartDateFrom?.toIso8601String(),
  'StartDateTo': instance.StartDateTo?.toIso8601String(),
  'EndDateFrom': instance.EndDateFrom?.toIso8601String(),
  'EndDateTo': instance.EndDateTo?.toIso8601String(),
};
