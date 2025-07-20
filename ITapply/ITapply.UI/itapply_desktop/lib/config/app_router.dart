import 'package:flutter/material.dart';
import 'package:itapply_desktop/models/application.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/screens/admin_dashboard_screen.dart';
import 'package:itapply_desktop/screens/admin_job_posting_details_screen.dart';
import 'package:itapply_desktop/screens/admin_job_posting_list_screen.dart';
import 'package:itapply_desktop/screens/employer_application_details_screen.dart';
import 'package:itapply_desktop/screens/employer_application_list_screen.dart';
import 'package:itapply_desktop/screens/employer_dashboard_screen.dart';
import 'package:itapply_desktop/screens/employer_job_posting_details_screen.dart';
import 'package:itapply_desktop/screens/employer_job_posting_list_screen.dart';
import 'package:itapply_desktop/screens/employer_profile_screen.dart';
import 'package:itapply_desktop/screens/employer_reports_screen.dart';
import 'package:itapply_desktop/screens/login_screen.dart';
import 'package:itapply_desktop/screens/registration_screen.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String registrationRoute = '/register';

  static const String employerDashboardRoute = '/employer-dashboard';
  static const String employerProfileRoute = '/employer-profile';
  static const String employerJobPostingsRoute = '/employer-job-postings';
  static const String employerJobPostingDetailsRoute = '/job-posting-details';
  static const String employerApplicationsRoute = '/employer-applications';
  static const String employerApplicationDetailsRoute = '/employer-application-details';
  static const String employerReportsRoute = '/employer-reports';

  static const String adminDashboardRoute = '/admin-dashboard';
  static const String adminUserManagementRoute = '/admin-user-management';
  static const String adminCompanyManagementRoute = '/admin-company-management';
  static const String adminEntitiesRoute = '/admin-entities';
  static const String adminJobPostingsRoute = '/admin-job-postings';
  static const String adminJobPostingDetailsRoute = '/admin-job-posting-details';
  static const String adminReviewsRoute = '/admin-reviews';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case registrationRoute:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case employerDashboardRoute:
        return MaterialPageRoute(builder: (_) => const EmployerDashboardScreen());
      case employerJobPostingsRoute:
        return MaterialPageRoute(builder: (_) => const EmployerJobPostingListScreen());
      case employerJobPostingDetailsRoute:
        final jobPosting = settings.arguments as JobPosting?;
        return MaterialPageRoute(
            builder: (_) => EmployerJobPostingDetailsScreen(jobPosting: jobPosting));
      case employerApplicationsRoute:
        final jobPosting = settings.arguments as JobPosting?;
        return MaterialPageRoute(builder: (_) => EmployerApplicationListScreen(initialJobPostingFilter: jobPosting));
      case employerApplicationDetailsRoute:
        final application = settings.arguments as Application?;
        return MaterialPageRoute(
            builder: (_) => EmployerApplicationDetailsScreen(application: application));
      case employerProfileRoute:
        return MaterialPageRoute(builder: (_) => const EmployerProfileScreen());
      case employerReportsRoute:
        return MaterialPageRoute(builder: (_) => const EmployerReportsScreen());
      case adminDashboardRoute:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminJobPostingsRoute:
        return MaterialPageRoute(builder: (_) => const AdminJobPostingListScreen());
      case AppRouter.adminJobPostingDetailsRoute:
        final jobPosting = settings.arguments as JobPosting?;
        return MaterialPageRoute(
          builder: (_) => AdminJobPostingDetailsScreen(jobPosting: jobPosting),
          settings: settings,
        );
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