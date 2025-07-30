// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_skill_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerSkillInsertRequest _$EmployerSkillInsertRequestFromJson(
  Map<String, dynamic> json,
) => EmployerSkillInsertRequest(
  employerId: (json['employerId'] as num).toInt(),
  skillId: (json['skillId'] as num).toInt(),
);

Map<String, dynamic> _$EmployerSkillInsertRequestToJson(
  EmployerSkillInsertRequest instance,
) => <String, dynamic>{
  'employerId': instance.employerId,
  'skillId': instance.skillId,
};
