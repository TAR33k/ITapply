import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/search_objects/user_search_object.dart';
import 'package:itapply_desktop/models/user.dart' as app_user;

class AuthProvider with ChangeNotifier {
  static String? _email;
  static String? _password;

  static String? get email => _email;
  static String? get password => _password;

  app_user.User? _currentUser;
  app_user.User? get currentUser => _currentUser;

  final String _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "http://localhost:8080");

  Future<void> login(String email, String password) async {
    _email = email;
    _password = password;

    final searchObject = UserSearchObject(Email: email);
    final queryString = getQueryString(searchObject.toJson());
    final url = Uri.parse("$_baseUrl/User?$queryString");
    final headers = createHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 299) {
        var data = jsonDecode(response.body);

        if (data['items'] != null && (data['items'] as List).isNotEmpty) {
          _currentUser = app_user.User.fromJson(data['items'][0]);
          
          notifyListeners();
        }
      } else {
         throw Exception("Invalid credentials or server error.");
      }
    } catch (e) {
      _email = null;
      _password = null;
      rethrow;
    }
  }

  Map<String, String> createHeaders() {
    String username = _email ?? "";
    String pass = _password ?? "";
    String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$pass'))}";
    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };
    return headers;
  }

  String getQueryString(Map params, {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (value == null) return;

      var encodedKey = Uri.encodeComponent(key.toString());
      var encodedValue = Uri.encodeComponent(value.toString());

      if (query.isNotEmpty) {
        query += '&';
      }

      query += '$encodedKey=$encodedValue';
    });
    return query;
  }

  void logout() {
    _email = null;
    _password = null;
    _currentUser = null;
    notifyListeners();
  }
}