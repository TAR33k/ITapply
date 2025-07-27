import 'package:flutter/material.dart';
import 'package:itapply_desktop/models/application.dart';
import 'package:itapply_desktop/models/candidate.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/job_posting.dart';
import 'package:itapply_desktop/models/review.dart';
import 'package:itapply_desktop/screens/admin_application_details_screen.dart';
import 'package:itapply_desktop/screens/admin_application_list_screen.dart';
import 'package:itapply_desktop/screens/admin_candidate_details_screen.dart';
import 'package:itapply_desktop/screens/admin_dashboard_screen.dart';
import 'package:itapply_desktop/screens/admin_employer_details_screen.dart';
import 'package:itapply_desktop/screens/admin_entities_screen.dart';
import 'package:itapply_desktop/screens/admin_job_posting_details_screen.dart';
import 'package:itapply_desktop/screens/admin_job_posting_list_screen.dart';
import 'package:itapply_desktop/screens/admin_reports_screen.dart';
import 'package:itapply_desktop/screens/admin_reviews_screen.dart';
import 'package:itapply_desktop/screens/admin_user_management_screen.dart';
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
  static const String adminUserManagementRoute = '/admin-users';
  static const String adminCandidateDetailsRoute = '/admin-candidate-details';
  static const String adminEmployerDetailsRoute = '/admin-employer-details';
  static const String adminEntitiesRoute = '/admin-entities';
  static const String adminJobPostingsRoute = '/admin-job-postings';
  static const String adminJobPostingDetailsRoute = '/admin-job-posting-details';
  static const String adminApplicationsRoute = '/admin-applications';
  static const String adminApplicationDetailsRoute = '/admin-application-details';
  static const String adminReviewsRoute = '/admin-reviews';
  static const String adminReportsRoute = '/admin-reports';

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
      case adminUserManagementRoute:
        return MaterialPageRoute(builder: (_) => const AdminUserManagementScreen());
      case adminCandidateDetailsRoute:
        final candidate = settings.arguments as Candidate?;
        return MaterialPageRoute(builder: (_) => AdminCandidateDetailsScreen(candidate: candidate));
      case adminEmployerDetailsRoute:
        final employer = settings.arguments as Employer?;
        return MaterialPageRoute(builder: (_) => AdminEmployerDetailsScreen(employer: employer));
      case adminJobPostingsRoute:
        final employerName = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => AdminJobPostingListScreen(
          employerName: employerName,
        ));
      case adminJobPostingDetailsRoute:
        final jobPosting = settings.arguments as JobPosting?;
        return MaterialPageRoute(
          builder: (_) => AdminJobPostingDetailsScreen(jobPosting: jobPosting),
          settings: settings,
        );
      case adminApplicationsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final candidate = args?['candidate'] as Candidate?;
        final jobPosting = args?['jobPosting'] as JobPosting?;
        return MaterialPageRoute(builder: (_) => AdminApplicationListScreen(initialCandidateFilter: candidate, initialJobPostingFilter: jobPosting));
      case adminApplicationDetailsRoute:
        final application = settings.arguments as Application?;
        return MaterialPageRoute(
          builder: (_) => AdminApplicationDetailsScreen(application: application),
          settings: settings,
        );
      case adminEntitiesRoute:
        return MaterialPageRoute(builder: (_) => const AdminEntitiesScreen());
      case adminReviewsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final candidate = args?['candidate'] as Candidate?;
        final employer = args?['employer'] as Employer?;
        final review = args?['review'] as Review?;

        String? candidateName;
        String? employerName;
        if (review != null) {
          candidateName = review.candidateName;
          employerName = review.companyName;
        } else {
          candidateName = candidate != null ? "${candidate.firstName} ${candidate.lastName}" : null;
          employerName = employer?.companyName;
        }
        return MaterialPageRoute(builder: (_) => AdminReviewsScreen(candidateName: candidateName, employerName: employerName));
      case adminReportsRoute:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
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