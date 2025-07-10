// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferencesInsertRequest _$PreferencesInsertRequestFromJson(
  Map<String, dynamic> json,
) => PreferencesInsertRequest(
  candidateId: (json['candidateId'] as num).toInt(),
  locationId: (json['locationId'] as num?)?.toInt(),
  employmentType: $enumDecodeNullable(
    _$EmploymentTypeEnumMap,
    json['employmentType'],
  ),
  remote: $enumDecodeNullable(_$RemoteEnumMap, json['remote']),
);

Map<String, dynamic> _$PreferencesInsertRequestToJson(
  PreferencesInsertRequest instance,
) => <String, dynamic>{
  'candidateId': instance.candidateId,
  'locationId': instance.locationId,
  'employmentType': _employmentTypeToJson(instance.employmentType),
  'remote': _remoteToJson(instance.remote),
};

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 0,
  EmploymentType.partTime: 1,
  EmploymentType.contract: 2,
  EmploymentType.internship: 3,
};

const _$RemoteEnumMap = {Remote.yes: 0, Remote.no: 1, Remote.hybrid: 2};
