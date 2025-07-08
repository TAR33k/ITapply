import 'package:flutter/material.dart';
import 'package:itapply_desktop/layouts/master_screen.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:itapply_desktop/widgets/stat_card.dart'; // Import the new widget
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return MasterScreen(
      title: "Dashboard",
      selectedRoute: "/dashboard",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back, ${user?.email ?? 'User'}!",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Here's a summary of your portal activity.",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = (constraints.maxWidth / 250).floor();
              return GridView.count(
                crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.0,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: const [
                  StatCard(title: "Active Job Postings", value: "12", icon: Icons.work_outline, color: Colors.blue),
                  StatCard(title: "New Applications", value: "28", icon: Icons.file_copy_outlined, color: Colors.orange),
                  StatCard(title: "Pending Reviews", value: "5", icon: Icons.rate_review_outlined, color: Colors.green),
                  StatCard(title: "Total Candidates", value: "156", icon: Icons.people_outline, color: Colors.purple),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "Performance Analytics",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Container(
              height: 300,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                "Chart Placeholder",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}