// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerSkill _$EmployerSkillFromJson(Map<String, dynamic> json) =>
    EmployerSkill(
      id: (json['id'] as num).toInt(),
      employerId: (json['employerId'] as num).toInt(),
      employerName: json['employerName'] as String?,
      skillId: (json['skillId'] as num).toInt(),
      skillName: json['skillName'] as String?,
    );

Map<String, dynamic> _$EmployerSkillToJson(EmployerSkill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employerId': instance.employerId,
      'employerName': instance.employerName,
      'skillId': instance.skillId,
      'skillName': instance.skillName,
    };
