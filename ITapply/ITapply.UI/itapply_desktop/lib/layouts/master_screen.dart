import 'package:flutter/material.dart';
import 'package:itapply_desktop/config/app_router.dart';
import 'package:itapply_desktop/config/app_theme.dart';
import 'package:itapply_desktop/models/user.dart' as app_user;
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
      backgroundColor: AppTheme.lightColor,
      body: Row(
        children: [
          _Sidebar(selectedRoute: selectedRoute),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    app_user.User? user = context.select<AuthProvider, app_user.User?>((auth) => auth.currentUser);

    if (user == null && AuthProvider.email != null && AuthProvider.password != null) {
      context.read<AuthProvider>().login(AuthProvider.email!, AuthProvider.password!);
      user = context.select<AuthProvider, app_user.User?>((auth) => auth.currentUser);
    }

    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          _buildLogo(context),
          const Divider(height: 1, color: AppTheme.grayColor),
          Expanded(
            child: (user == null)
                ? const Center(child: CircularProgressIndicator())
                : _buildMenuList(context, user),
          ),
          const Divider(height: 1, color: AppTheme.grayColor),
          _UserProfileTile(user: user),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, app_user.User user) {
    final role = user.roles.isNotEmpty ? user.roles.first.name : "Employer";
    List<Widget> menuItems;

    switch (role) {
      case "Administrator":
        menuItems = _buildAdminItems(context, selectedRoute);
        break;
      case "Employer":
        menuItems = _buildEmployerItems(context, selectedRoute);
        break;
      default:
        menuItems = [const Center(child: Text("No permissions."))];
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: menuItems,
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 50),
          const SizedBox(width: 8),
          RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'IT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      TextSpan(
                        text: 'apply',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                          fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdminItems(BuildContext context, String selectedRoute) {
    return [
      _SidebarItem(
        title: "Dashboard",
        icon: Icons.dashboard_outlined,
        route: AppRouter.adminDashboardRoute,
        isSelected: selectedRoute == AppRouter.adminDashboardRoute,
      ),
      _SidebarItem(
        title: "Users",
        icon: Icons.people_alt_outlined,
        route: AppRouter.adminUserManagementRoute,
        isSelected: selectedRoute == AppRouter.adminUserManagementRoute,
      ),
       _SidebarItem(
        title: "Job Postings",
        icon: Icons.work_outline,
        route: AppRouter.adminJobPostingsRoute,
        isSelected: selectedRoute == AppRouter.adminJobPostingsRoute,
      ),
       _SidebarItem(
        title: "Applications",
        icon: Icons.file_copy_outlined,
        route: AppRouter.adminApplicationsRoute,
        isSelected: selectedRoute == AppRouter.adminApplicationsRoute,
      ),
       _SidebarItem(
        title: "Reviews",
        icon: Icons.rate_review_outlined,
        route: AppRouter.adminReviewsRoute,
        isSelected: selectedRoute == AppRouter.adminReviewsRoute,
      ),
      _SidebarItem(
        title: "Platform Entities",
        icon: Icons.category_outlined,
        route: AppRouter.adminEntitiesRoute,
        isSelected: selectedRoute == AppRouter.adminEntitiesRoute,
      ),
    ];
  }

  List<Widget> _buildEmployerItems(BuildContext context, String selectedRoute) {
    return [
      _SidebarItem(
        title: "Dashboard",
        icon: Icons.dashboard_outlined,
        route: AppRouter.employerDashboardRoute,
        isSelected: selectedRoute == AppRouter.employerDashboardRoute,
      ),
      _SidebarItem(
        title: "Job Postings",
        icon: Icons.work_outline,
        route: AppRouter.employerJobPostingsRoute,
        isSelected: selectedRoute == AppRouter.employerJobPostingsRoute,
      ),
      _SidebarItem(
        title: "Applications",
        icon: Icons.file_copy_outlined,
        route: AppRouter.employerApplicationsRoute,
        isSelected: selectedRoute == AppRouter.employerApplicationsRoute,
      ),
      _SidebarItem(
        title: "Reports",
        icon: Icons.bar_chart_outlined,
        route: AppRouter.employerReportsRoute,
        isSelected: selectedRoute == AppRouter.employerReportsRoute,
      ),
      _SidebarItem(
        title: "Company Profile",
        icon: Icons.store_outlined,
        route: AppRouter.employerProfileRoute,
        isSelected: selectedRoute == AppRouter.employerProfileRoute,
      ),
    ];
  }
}

class _UserProfileTile extends StatelessWidget {
  final app_user.User? user;
  const _UserProfileTile({this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user!.email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user!.roles.isNotEmpty ? user!.roles.first.name : "User",
                  style: const TextStyle(color: AppTheme.secondaryColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.secondaryColor),
            tooltip: "Logout",
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (route) => false);
            },
          )
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
    
    final color = isSelected ? theme.primaryColor : AppTheme.secondaryColor;
    final bgColor = isSelected ? theme.primaryColor.withOpacity(0.1) : (_isHovered ? Colors.grey.withOpacity(0.1) : Colors.transparent);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (!isSelected) {
              Navigator.pushReplacementNamed(context, widget.route);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 24,
                  width: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(widget.icon, color: color, size: 22),
                const SizedBox(width: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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