import 'package:flutter/material.dart';

class User {
  final int id;
  final String email;
  final String role;

  User({required this.id, required this.email, required this.role});
}

class AuthProvider with ChangeNotifier {
  static String? _email;
  static String? _password;

  static String? get email => _email;
  static String? get password => _password;

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    _email = email;
    _password = password;

    // In a real app, you would make an API call here to authenticate
    // and get user details. For now, we simulate a successful login.
    // This simulates a network delay.
    await Future.delayed(const Duration(seconds: 1)); 

    // Example of a failed login check
    if (password == "wrong") {
      throw Exception("Invalid credentials. Please try again.");
    }
    
    // On success, create a user object and notify listeners.
    _currentUser = User(
      id: 1, // Placeholder ID
      email: email,
      role: email.contains("admin") ? "Administrator" : "Employer", // Simple logic for example
    );
    
    notifyListeners();
  }

  void logout() {
    _email = null;
    _password = null;
    _currentUser = null;
    notifyListeners();
  }
}