// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Preferences _$PreferencesFromJson(Map<String, dynamic> json) => Preferences(
  id: (json['id'] as num).toInt(),
  candidateId: (json['candidateId'] as num).toInt(),
  locationId: (json['locationId'] as num?)?.toInt(),
  locationName: json['locationName'] as String?,
  employmentType: $enumDecodeNullable(
    _$EmploymentTypeEnumMap,
    json['employmentType'],
    unknownValue: EmploymentType.fullTime,
  ),
  remote: $enumDecodeNullable(
    _$RemoteEnumMap,
    json['remote'],
    unknownValue: Remote.no,
  ),
);

Map<String, dynamic> _$PreferencesToJson(Preferences instance) =>
    <String, dynamic>{
      'id': instance.id,
      'candidateId': instance.candidateId,
      'locationId': instance.locationId,
      'locationName': instance.locationName,
      'employmentType': _$EmploymentTypeEnumMap[instance.employmentType],
      'remote': _$RemoteEnumMap[instance.remote],
    };

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 0,
  EmploymentType.partTime: 1,
  EmploymentType.contract: 2,
  EmploymentType.internship: 3,
};

const _$RemoteEnumMap = {Remote.yes: 0, Remote.no: 1, Remote.hybrid: 2};
