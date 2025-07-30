import 'package:itapply_desktop/models/requests/user_role_insert_request.dart';
import 'package:itapply_desktop/models/requests/user_role_update_request.dart';
import 'package:itapply_desktop/models/search_objects/user_role_search_object.dart';
import 'package:itapply_desktop/models/user_role.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class UserRoleProvider extends BaseProvider<UserRole, 
    UserRoleSearchObject, UserRoleInsertRequest, UserRoleUpdateRequest> {
  UserRoleProvider() : super("UserRole");

  @override
  UserRole fromJson(data) {
    return UserRole.fromJson(data);
  }
}