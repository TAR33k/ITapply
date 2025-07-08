import 'package:flutter/material.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/providers/job_posting_provider.dart';
import 'package:itapply_desktop/providers/skill_provider.dart';
import 'package:itapply_desktop/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobPostingProvider()),
        ChangeNotifierProvider(create: (_) => SkillProvider()),
      ],
      child: const ITapplyDesktopApp(),
    ),
  );
}

class ITapplyDesktopApp extends StatelessWidget {
  const ITapplyDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITapply Desktop',
      theme: AppTheme.getTheme(),
      home: LoginScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}