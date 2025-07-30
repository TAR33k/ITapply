import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/requests/user_login_request.dart';
import 'package:itapply_desktop/models/user.dart' as app_user;
import 'package:itapply_desktop/providers/employer_provider.dart';

class AuthProvider with ChangeNotifier {
  static String? _email;
  static String? _password;

  static String? get email => _email;
  static String? get password => _password;

  app_user.User? _currentUser;
  app_user.User? get currentUser => _currentUser;

  Employer? _currentEmployer;
  Employer? get currentEmployer => _currentEmployer;

  final EmployerProvider _employerProvider;

  AuthProvider(this._employerProvider);

  final String _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "http://localhost:8080");

  Future<void> login(String email, String password) async {
    _email = email;
    _password = password;

    final loginRequest = UserLoginRequest(email: email, password: password);
    final url = Uri.parse("$_baseUrl/User/login");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode(loginRequest.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        _email = email;
        _password = password;

        var data = jsonDecode(response.body);
        _currentUser = app_user.User.fromJson(data);

        if (_currentUser!.roles.any((r) => r.name == 'Employer')) {
          final employerResult = await _employerProvider.getById(_currentUser!.id);
          _currentEmployer = employerResult;
        }
        
        notifyListeners();
      } else {
        throw Exception("Invalid credentials");
      }
    } catch (e) {
      logout();
      rethrow;
    }
  }

  void logout() {
    _email = null;
    _password = null;
    _currentUser = null;
    _currentEmployer = null;
    notifyListeners();
  }

  void setCurrentEmployer(Employer updatedEmployer) {
    _currentEmployer = updatedEmployer;
    notifyListeners();
  }

  void setCurrentUser(app_user.User updatedUser) {
    if (updatedUser.email != _currentUser?.email) {
      _email = updatedUser.email;
    }
    
    _currentUser = updatedUser;
    notifyListeners();
  }
}