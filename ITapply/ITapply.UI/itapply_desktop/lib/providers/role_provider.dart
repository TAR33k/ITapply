import 'package:itapply_desktop/models/requests/role_insert_request.dart';
import 'package:itapply_desktop/models/requests/role_update_request.dart';
import 'package:itapply_desktop/models/role.dart';
import 'package:itapply_desktop/models/search_objects/role_search_object.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class RoleProvider extends BaseProvider<Role, RoleSearchObject, RoleInsertRequest, RoleUpdateRequest> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(data) {
    return Role.fromJson(data);
  }
}