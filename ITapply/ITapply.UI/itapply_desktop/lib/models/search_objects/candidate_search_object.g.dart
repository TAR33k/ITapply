// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
CandidateSearchObject _$CandidateSearchObjectFromJson(
  Map<String, dynamic> json,
) => CandidateSearchObject(
  FirstName: json['FirstName'] as String?,
  LastName: json['LastName'] as String?,
  Title: json['Title'] as String?,
  LocationId: (json['LocationId'] as num?)?.toInt(),
  MinExperienceYears: (json['MinExperienceYears'] as num?)?.toInt(),
  MaxExperienceYears: (json['MaxExperienceYears'] as num?)?.toInt(),
  experienceLevel: $enumDecodeNullable(
    _$ExperienceLevelEnumMap,
    json['ExperienceLevel'],
  ),
  Email: json['Email'] as String?,
  IsActive: json['IsActive'] as bool?,
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$CandidateSearchObjectToJson(
  CandidateSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'FirstName': instance.FirstName,
  'LastName': instance.LastName,
  'Title': instance.Title,
  'LocationId': instance.LocationId,
  'MinExperienceYears': instance.MinExperienceYears,
  'MaxExperienceYears': instance.MaxExperienceYears,
  'ExperienceLevel': _experienceLevelToJson(instance.experienceLevel),
  'Email': instance.Email,
  'IsActive': instance.IsActive,
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.entryLevel: 0,
  ExperienceLevel.junior: 1,
  ExperienceLevel.mid: 2,
  ExperienceLevel.senior: 3,
  ExperienceLevel.lead: 4,
};
