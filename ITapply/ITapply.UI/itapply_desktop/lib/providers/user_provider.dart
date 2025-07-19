import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/requests/change_password_request.dart';
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

  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await get(filter: UserSearchObject(Email: email));
      return result.items!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> changePassword(int userId, ChangePasswordRequest request) async {
    var url = "$baseUrl$endpoint/$userId/change-password";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode(request.toJson());

    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (!isValidResponse(response)) {
      throw Exception("Failed to change password");
    }
  }
}