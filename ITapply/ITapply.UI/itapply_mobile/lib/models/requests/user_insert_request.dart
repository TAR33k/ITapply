import 'package:json_annotation/json_annotation.dart';

part 'user_insert_request.g.dart';

@JsonSerializable()
class UserInsertRequest {
  final String email;
  final String password;
  final List<int> roleIds;

  UserInsertRequest({
    required this.email,
    required this.password,
    required this.roleIds,
  });

  factory UserInsertRequest.fromJson(Map<String, dynamic> json) => _$UserInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserInsertRequestToJson(this);
}
