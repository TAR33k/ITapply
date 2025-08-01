import 'package:flutter/material.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/providers/application_provider.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:itapply_mobile/providers/candidate_provider.dart';
import 'package:itapply_mobile/providers/candidate_skill_provider.dart';
import 'package:itapply_mobile/providers/cv_document_provider.dart';
import 'package:itapply_mobile/providers/education_provider.dart';
import 'package:itapply_mobile/providers/employer_provider.dart';
import 'package:itapply_mobile/providers/candidate_registration_provider.dart';
import 'package:itapply_mobile/providers/employer_skill_provider.dart';
import 'package:itapply_mobile/providers/job_posting_provider.dart';
import 'package:itapply_mobile/providers/job_posting_skill_provider.dart';
import 'package:itapply_mobile/providers/location_provider.dart';
import 'package:itapply_mobile/providers/preferences_provider.dart';
import 'package:itapply_mobile/providers/review_provider.dart';
import 'package:itapply_mobile/providers/role_provider.dart';
import 'package:itapply_mobile/providers/skill_provider.dart';
import 'package:itapply_mobile/providers/user_provider.dart';
import 'package:itapply_mobile/providers/user_role_provider.dart';
import 'package:itapply_mobile/providers/work_experience_provider.dart';
import 'package:itapply_mobile/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => CandidateProvider()),
        ChangeNotifierProvider(create: (_) => CandidateSkillProvider()),
        ChangeNotifierProvider(create: (_) => CVDocumentProvider()),
        ChangeNotifierProvider(create: (_) => EducationProvider()),
        ChangeNotifierProvider(create: (_) => EmployerProvider()),
        ChangeNotifierProvider(create: (_) => EmployerSkillProvider()),
        ChangeNotifierProvider(create: (_) => JobPostingProvider()),
        ChangeNotifierProvider(create: (_) => JobPostingSkillProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => SkillProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
        ChangeNotifierProvider(create: (_) => WorkExperienceProvider()),

        ChangeNotifierProxyProvider<CandidateProvider, AuthProvider>(
          create: (context) => AuthProvider(context.read<CandidateProvider>()),
          update: (context, candidateProvider, previous) => AuthProvider(candidateProvider),
        ),

        ChangeNotifierProxyProvider3<UserProvider, CandidateProvider, RoleProvider, CandidateRegistrationProvider>(
          create: (context) => CandidateRegistrationProvider(
            context.read<UserProvider>(),
            context.read<CandidateProvider>(),
            context.read<RoleProvider>(),
          ),
          update: (context, userProvider, candidateProvider, roleProvider, previous) => 
                  CandidateRegistrationProvider(userProvider, candidateProvider, roleProvider),
        ),
      ],
      child: const ITapplyMobileApp(),
    ),
  );
}

class ITapplyMobileApp extends StatelessWidget {
  const ITapplyMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITapply Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      home: LoginScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
