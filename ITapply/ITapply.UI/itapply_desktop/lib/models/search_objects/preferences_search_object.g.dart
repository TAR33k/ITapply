// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
  EmploymentType.fullTime: 'fullTime',
  EmploymentType.partTime: 'partTime',
  EmploymentType.contract: 'contract',
  EmploymentType.internship: 'internship',
};

const _$RemoteEnumMap = {
  Remote.yes: 'yes',
  Remote.no: 'no',
  Remote.hybrid: 'hybrid',
};
