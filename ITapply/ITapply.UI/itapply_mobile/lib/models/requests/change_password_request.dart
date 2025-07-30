import 'package:json_annotation/json_annotation.dart';

part 'change_password_request.g.dart';

@JsonSerializable()
class ChangePasswordRequest {
  @JsonKey(name: 'OldPassword')
  final String oldPassword;
  @JsonKey(name: 'NewPassword')
  final String newPassword;
  @JsonKey(name: 'ConfirmPassword')
  final String confirmPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}
