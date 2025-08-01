// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
PreferencesSearchObject _$PreferencesSearchObjectFromJson(
  Map<String, dynamic> json,
) => PreferencesSearchObject(
  CandidateId: (json['CandidateId'] as num?)?.toInt(),
  LocationId: (json['LocationId'] as num?)?.toInt(),
  employmentType: $enumDecodeNullable(
    _$EmploymentTypeEnumMap,
    json['EmploymentType'],
  ),
  remote: $enumDecodeNullable(_$RemoteEnumMap, json['Remote']),
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$PreferencesSearchObjectToJson(
  PreferencesSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'CandidateId': instance.CandidateId,
  'LocationId': instance.LocationId,
  'EmploymentType': _employmentTypeToJson(instance.employmentType),
  'Remote': _remoteToJson(instance.remote),
};

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 0,
  EmploymentType.partTime: 1,
  EmploymentType.contract: 2,
  EmploymentType.internship: 3,
};

const _$RemoteEnumMap = {Remote.yes: 0, Remote.no: 1, Remote.hybrid: 2};
