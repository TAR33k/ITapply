// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateInsertRequest _$CandidateInsertRequestFromJson(
  Map<String, dynamic> json,
) => CandidateInsertRequest(
  userId: (json['userId'] as num).toInt(),
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

Map<String, dynamic> _$CandidateInsertRequestToJson(
  CandidateInsertRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
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
  ExperienceLevel.entryLevel: 0,
  ExperienceLevel.junior: 1,
  ExperienceLevel.mid: 2,
  ExperienceLevel.senior: 3,
  ExperienceLevel.lead: 4,
};
