import 'package:flutter/material.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MasterScreen extends StatelessWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    required this.selectedRoute,
  });

  final Widget child;
  final String title;
  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(selectedRoute: selectedRoute),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  title: Text(title),
                  elevation: 1,
                  automaticallyImplyLeading: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedRoute});
  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Image.asset('assets/logo.png', height: 60),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                _SidebarItem(
                  title: "Dashboard",
                  icon: Icons.dashboard_outlined,
                  route: AppRouter.dashboardRoute,
                  isSelected: selectedRoute == AppRouter.dashboardRoute,
                ),
                _SidebarItem(
                  title: "Job Postings",
                  icon: Icons.work_outline,
                  route: AppRouter.jobPostingsRoute,
                  isSelected: selectedRoute == AppRouter.jobPostingsRoute,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.loginRoute,
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isSelected = false,
  });

  final String title;
  final IconData icon;
  final String route;
  final bool isSelected;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.isSelected;
    final color = isSelected
        ? theme.primaryColor
        : theme.textTheme.bodyLarge?.color;
    final bgColor = isSelected
        ? theme.primaryColor.withOpacity(0.1)
        : (_isHovered ? theme.hoverColor : Colors.transparent);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              Navigator.pushReplacementNamed(context, widget.route);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: color),
                const SizedBox(width: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: color,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}