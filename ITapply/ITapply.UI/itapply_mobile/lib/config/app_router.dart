import 'package:flutter/material.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/screens/home_screen.dart';
import 'package:itapply_mobile/screens/login_screen.dart';
import 'package:itapply_mobile/screens/registration_screen.dart';
import 'package:itapply_mobile/screens/wrong_role_screen.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String wrongRoleRoute = '/wrong-role';
  static const String registrationRoute = '/register';

  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String jobDetailsRoute = '/job-details';
  static const String companiesRoute = '/companies';
  static const String profileRoute = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case wrongRoleRoute:
        return MaterialPageRoute(builder: (_) => WrongRoleScreen());
      case registrationRoute:
        return MaterialPageRoute(builder: (_) => RegistrationScreen());
      case homeRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] ?? false;
        return MaterialPageRoute(builder: (_) => MasterScreen(
          title: "Home", 
          selectedIndex: 0, 
          showBackButton: false, 
          child: HomeScreen(isGuest: isGuest),
        ));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No route defined for ${settings.name}'),
                ],
              ),
            ),
          ),
        );
    }
  }
}