import 'package:json_annotation/json_annotation.dart';

part 'role_update_request.g.dart';

@JsonSerializable()
class RoleUpdateRequest {
  final String name;

  RoleUpdateRequest({required this.name});

  factory RoleUpdateRequest.fromJson(Map<String, dynamic> json) => _$RoleUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RoleUpdateRequestToJson(this);
}