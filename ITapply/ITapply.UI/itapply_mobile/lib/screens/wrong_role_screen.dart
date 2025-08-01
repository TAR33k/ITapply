import 'package:flutter/material.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class WrongRoleScreen extends StatelessWidget {
  const WrongRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(context),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContent(context),
                ),
              ),
              const SizedBox(height: 20),
              _buildActions(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.account_circle_outlined,
            size: 60,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Account Type Mismatch',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This account is not compatible with the mobile app',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          icon: Icons.desktop_windows_outlined,
          iconColor: AppTheme.primaryColor,
          title: 'Desktop App Account',
          description: 'You\'ve logged in with an account designed for the ITapply Desktop application. This account type (Administrator or Employer) is not supported on the mobile app.',
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          context,
          icon: Icons.phone_android_outlined,
          iconColor: AppTheme.confirmColor,
          title: 'Mobile App Requirements',
          description: 'The ITapply mobile app is designed for job seekers and candidates. To use this app, you need a personal candidate account.',
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          context,
          icon: Icons.person_add_outlined,
          iconColor: AppTheme.accentColor,
          title: 'Create a Candidate Account',
          description: 'Sign up for a new personal account to access job listings, apply for positions, and manage your career profile on mobile.',
        ),
        const SizedBox(height: 30),
        _buildFeaturesList(context),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grayColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      'Browse hundreds of IT job opportunities',
      'Apply to positions with one tap',
      'Track your application status',
      'Build and manage your professional profile',
      'Get personalized job recommendations',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you can do with a candidate account:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkColor,
              ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.confirmColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textColor,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            _logout(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.registrationRoute,
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: AppTheme.primaryColor.withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 20),
              const SizedBox(width: 8),
              Text(
                'Create Candidate Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            _logout(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.loginRoute,
              (route) => false,
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.secondaryColor,
            side: BorderSide(color: AppTheme.grayColor),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Back to Login',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.homeRoute,
              (route) => false,
              arguments: {'isGuest': true},
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.explore_outlined,
                size: 18,
                color: AppTheme.confirmColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Continue as Guest',
                style: TextStyle(
                  color: AppTheme.confirmColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context) {
    try {
      context.read<AuthProvider>().logout();
    } catch (e) {
      //
    }
  }
}
