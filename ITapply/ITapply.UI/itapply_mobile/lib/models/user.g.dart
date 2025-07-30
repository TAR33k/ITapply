// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  registrationDate: DateTime.parse(json['registrationDate'] as String),
  isActive: json['isActive'] as bool,
  roles: (json['roles'] as List<dynamic>)
      .map((e) => Role.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'registrationDate': instance.registrationDate.toIso8601String(),
  'isActive': instance.isActive,
  'roles': instance.roles.map((e) => e.toJson()).toList(),
};
