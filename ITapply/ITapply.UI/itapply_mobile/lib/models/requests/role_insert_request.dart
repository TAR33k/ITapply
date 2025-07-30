import 'package:json_annotation/json_annotation.dart';

part 'role_insert_request.g.dart';

@JsonSerializable()
class RoleInsertRequest {
  final String name;

  RoleInsertRequest({required this.name});

  factory RoleInsertRequest.fromJson(Map<String, dynamic> json) => _$RoleInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RoleInsertRequestToJson(this);
}