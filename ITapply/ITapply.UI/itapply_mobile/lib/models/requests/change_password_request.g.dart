// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) => ChangePasswordRequest(
  oldPassword: json['OldPassword'] as String,
  newPassword: json['NewPassword'] as String,
  confirmPassword: json['ConfirmPassword'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestToJson(
  ChangePasswordRequest instance,
) => <String, dynamic>{
  'OldPassword': instance.oldPassword,
  'NewPassword': instance.newPassword,
  'ConfirmPassword': instance.confirmPassword,
};
