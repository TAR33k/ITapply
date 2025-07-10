import 'package:flutter/material.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/models/employer.dart';
import 'package:itapply_desktop/models/enums.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AwaitingApprovalScreen extends StatelessWidget {
  final Employer employer;
  const AwaitingApprovalScreen({super.key, required this.employer});

  @override
  Widget build(BuildContext context) {
    bool isRejected = employer.verificationStatus == VerificationStatus.rejected;

    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRejected ? Icons.highlight_off_rounded : Icons.hourglass_top_rounded,
              size: 80,
              color: isRejected ? AppTheme.accentColor : AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              isRejected ? "Account Rejected" : "Pending Approval",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                isRejected
                    ? "Your company profile could not be verified by our administrators at this time. Please contact support for more information."
                    : "Your company profile has been submitted and is awaiting verification by an administrator.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text("LOGOUT"),
            ),
          ],
        ),
      ),
    );
  }
}