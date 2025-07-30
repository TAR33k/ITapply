import 'package:itapply_mobile/models/requests/role_insert_request.dart';
import 'package:itapply_mobile/models/requests/role_update_request.dart';
import 'package:itapply_mobile/models/role.dart';
import 'package:itapply_mobile/models/search_objects/role_search_object.dart';
import 'package:itapply_mobile/providers/base_provider.dart';

class RoleProvider extends BaseProvider<Role, RoleSearchObject, RoleInsertRequest, RoleUpdateRequest> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(data) {
    return Role.fromJson(data);
  }
}
