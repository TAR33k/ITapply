import 'package:flutter/material.dart';
import 'package:itapply_mobile/layouts/master_screen.dart';
import 'package:itapply_mobile/screens/home_screen.dart';
import 'package:itapply_mobile/screens/job_list_screen.dart';
import 'package:itapply_mobile/screens/employer_list_screen.dart';
import 'package:itapply_mobile/screens/login_screen.dart';
import 'package:itapply_mobile/screens/registration_screen.dart';
import 'package:itapply_mobile/screens/wrong_role_screen.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String wrongRoleRoute = '/wrong-role';
  static const String registrationRoute = '/register';

  static const String homeRoute = '/home';
  static const String jobListRoute = '/job-list';
  static const String jobDetailsRoute = '/job-details';
  static const String employerListRoute = '/employer-list';
  static const String employerDetailsRoute = '/employer-details';
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
      case jobListRoute:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => JobListScreen(
            isGuest: args['isGuest'] ?? false,
            initialSearchQuery: args['searchQuery'],
            initialFilters: args['filters'],
          ),
        );
      case employerListRoute:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => EmployerListScreen(
            isGuest: args['isGuest'] ?? false,
            initialSearchQuery: args['searchQuery'],
            initialFilters: args['filters'],
          ),
        );
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