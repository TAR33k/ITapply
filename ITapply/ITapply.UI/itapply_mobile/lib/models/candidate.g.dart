// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Candidate _$CandidateFromJson(Map<String, dynamic> json) => Candidate(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  title: json['title'] as String?,
  bio: json['bio'] as String?,
  locationId: (json['locationId'] as num?)?.toInt(),
  locationName: json['locationName'] as String?,
  experienceYears: (json['experienceYears'] as num).toInt(),
  experienceLevel: $enumDecode(
    _$ExperienceLevelEnumMap,
    json['experienceLevel'],
    unknownValue: ExperienceLevel.entryLevel,
  ),
  registrationDate: DateTime.parse(json['registrationDate'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$CandidateToJson(Candidate instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'title': instance.title,
  'bio': instance.bio,
  'locationId': instance.locationId,
  'locationName': instance.locationName,
  'experienceYears': instance.experienceYears,
  'experienceLevel': _$ExperienceLevelEnumMap[instance.experienceLevel]!,
  'registrationDate': instance.registrationDate.toIso8601String(),
  'isActive': instance.isActive,
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.entryLevel: 0,
  ExperienceLevel.junior: 1,
  ExperienceLevel.mid: 2,
  ExperienceLevel.senior: 3,
  ExperienceLevel.lead: 4,
};
