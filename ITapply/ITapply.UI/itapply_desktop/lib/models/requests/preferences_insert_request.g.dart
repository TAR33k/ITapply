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
