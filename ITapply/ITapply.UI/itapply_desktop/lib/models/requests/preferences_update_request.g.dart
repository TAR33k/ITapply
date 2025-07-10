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
  EmploymentType.fullTime: 0,
  EmploymentType.partTime: 1,
  EmploymentType.contract: 2,
  EmploymentType.internship: 3,
};

const _$RemoteEnumMap = {Remote.yes: 0, Remote.no: 1, Remote.hybrid: 2};
