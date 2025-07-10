// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferencesUpdateRequest _$PreferencesUpdateRequestFromJson(
  Map<String, dynamic> json,
) => PreferencesUpdateRequest(
  locationId: (json['locationId'] as num?)?.toInt(),
  employmentType: $enumDecodeNullable(
    _$EmploymentTypeEnumMap,
    json['employmentType'],
  ),
  remote: $enumDecodeNullable(_$RemoteEnumMap, json['remote']),
);

Map<String, dynamic> _$PreferencesUpdateRequestToJson(
  PreferencesUpdateRequest instance,
) => <String, dynamic>{
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
