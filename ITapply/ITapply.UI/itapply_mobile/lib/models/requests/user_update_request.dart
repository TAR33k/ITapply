import 'package:json_annotation/json_annotation.dart';

part 'user_update_request.g.dart';

@JsonSerializable()
class UserUpdateRequest {
  final String email;
  final String? password;
  final bool? isActive;

  UserUpdateRequest({
    required this.email,
    this.password,
    this.isActive,
  });

  factory UserUpdateRequest.fromJson(Map<String, dynamic> json) => _$UserUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateRequestToJson(this);
}