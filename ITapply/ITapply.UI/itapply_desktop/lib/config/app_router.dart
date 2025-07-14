import 'package:flutter/material.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/screens/admin_dashboard_screen.dart';
import 'package:itapply_desktop/screens/employer_dashboard_screen.dart';
import 'package:itapply_desktop/screens/job_posting_details.dart';
import 'package:itapply_desktop/screens/job_posting_list.dart';
import 'package:itapply_desktop/screens/login_screen.dart';
import 'package:itapply_desktop/screens/registration_screen.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String registrationRoute = '/register';

  static const String employerDashboardRoute = '/employer-dashboard';
  static const String employerProfileRoute = '/employer-profile';
  static const String employerJobPostingsRoute = '/employer-job-postings';
  static const String employerApplicationsRoute = '/employer-applications';
  static const String employerReviewsRoute = '/employer-reviews';

  static const String adminDashboardRoute = '/admin-dashboard';
  static const String adminUserManagementRoute = '/admin-user-management';
  static const String adminCompanyManagementRoute = '/admin-company-management';
  static const String adminEntitiesRoute = '/admin-entities';
  static const String adminJobPostingsRoute = '/admin-job-postings';
  static const String adminReviewsRoute = '/admin-reviews';

  static const String jobPostingDetailsRoute = '/job-posting-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case registrationRoute:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case employerDashboardRoute:
        return MaterialPageRoute(builder: (_) => const EmployerDashboardScreen());
      case adminDashboardRoute:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case employerApplicationsRoute:
        return MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: Text("Applications"))));
      case adminJobPostingsRoute:
        return MaterialPageRoute(builder: (_) => const JobPostingList());
      case jobPostingDetailsRoute:
        final jobPosting = settings.arguments as JobPosting?;
        return MaterialPageRoute(
            builder: (_) => JobPostingDetailsScreen(jobPosting: jobPosting));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}