// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateUpdateRequest _$CandidateUpdateRequestFromJson(
  Map<String, dynamic> json,
) => CandidateUpdateRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  title: json['title'] as String?,
  bio: json['bio'] as String?,
  locationId: (json['locationId'] as num?)?.toInt(),
  experienceYears: (json['experienceYears'] as num?)?.toInt(),
  experienceLevel: $enumDecodeNullable(
    _$ExperienceLevelEnumMap,
    json['experienceLevel'],
  ),
);

Map<String, dynamic> _$CandidateUpdateRequestToJson(
  CandidateUpdateRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'title': instance.title,
  'bio': instance.bio,
  'locationId': instance.locationId,
  'experienceYears': instance.experienceYears,
  'experienceLevel': _experienceLevelToJson(instance.experienceLevel),
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.entryLevel: 'entryLevel',
  ExperienceLevel.junior: 'junior',
  ExperienceLevel.mid: 'mid',
  ExperienceLevel.senior: 'senior',
  ExperienceLevel.lead: 'lead',
};
