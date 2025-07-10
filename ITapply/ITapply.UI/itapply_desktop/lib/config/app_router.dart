import 'package:flutter/material.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/screens/dashboard_screen.dart';
import 'package:itapply_desktop/screens/job_posting_details.dart';
import 'package:itapply_desktop/screens/job_posting_list.dart';
import 'package:itapply_desktop/screens/login_screen.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String jobPostingsRoute = '/job-postings';
  static const String jobPostingDetailsRoute = '/job-posting-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case dashboardRoute:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case jobPostingsRoute:
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