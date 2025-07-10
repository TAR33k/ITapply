import 'package:itapply_desktop/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_role_search_object.g.dart';

@JsonSerializable()
class UserRoleSearchObject extends BaseSearchObject {
  int? UserId;
  int? RoleId;
  String? RoleName;

  UserRoleSearchObject({
    this.UserId,
    this.RoleId,
    this.RoleName,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$UserRoleSearchObjectToJson(this);
}