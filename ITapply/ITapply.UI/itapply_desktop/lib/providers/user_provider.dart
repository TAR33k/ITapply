import 'package:itapply_desktop/models/requests/user_insert_request.dart';
import 'package:itapply_desktop/models/requests/user_update_request.dart';
import 'package:itapply_desktop/models/search_objects/user_search_object.dart';
import 'package:itapply_desktop/models/user.dart';
import 'package:itapply_desktop/providers/base_provider.dart';

class UserProvider extends BaseProvider<User, UserSearchObject, UserInsertRequest, UserUpdateRequest> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}