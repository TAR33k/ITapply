import 'package:flutter/material.dart';
import 'package:itapply_mobile/config/app_router.dart';
import 'package:itapply_mobile/config/app_theme.dart';
import 'package:itapply_mobile/models/candidate.dart';
import 'package:itapply_mobile/models/user.dart' as app_user;
import 'package:itapply_mobile/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MasterScreen extends StatelessWidget {
  final Widget child;
  final String title;
  final int selectedIndex;
  final bool showBackButton;
  final VoidCallback? onScroll;

  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    required this.selectedIndex,
    this.showBackButton = false,
    this.onScroll,
  });

  @override
  Widget build(BuildContext context) {
    app_user.User? user = context.watch<AuthProvider>().currentUser;
    bool isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      appBar: _buildAppBar(context, isLoggedIn),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (onScroll != null && 
              scrollInfo is ScrollUpdateNotification &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            onScroll!();
          }
          return false;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: child,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, isLoggedIn),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isLoggedIn) {
    List<Widget> actions = [];

    actions.add(Image.asset('assets/logo.png', width: 50, height: 50));
    actions.add(Text("IT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)));
    actions.add(Text("apply", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)));
    actions.add(Spacer());

    if (isLoggedIn) {
      Candidate? candidate = context.watch<AuthProvider>().currentCandidate;
      actions.add(
        PopupMenuButton<String>(
          onSelected: (String value) {
            switch (value) {
              case 'profile':
                if (candidate != null) {
                  Navigator.pushNamed(context, AppRouter.profileRoute);
                } else {
                  Navigator.pushNamed(context, AppRouter.wrongRoleRoute);
                }
                break;
              case 'logout':
                _handleLogout(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                candidate != null ? candidate.firstName.substring(0, 1).toUpperCase() + candidate.lastName.substring(0, 1).toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )
      );
    } else {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.loginRoute),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text("Login"),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: showBackButton,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      actions: actions,
    );
  }

  void _handleLogout(BuildContext context) {
    try {
      context.read<AuthProvider>().logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.loginRoute,
        (route) => false,
      );
    } catch (e) {
      //
    }
  }

  Widget _buildBottomNav(BuildContext context, bool isLoggedIn) {
    void onTabTapped(int index) {
      if (index == selectedIndex) return;
      
      String route;
      Map<String, dynamic>? arguments;
      
      if (isLoggedIn) {
        switch (index) {
          case 0:
            route = AppRouter.homeRoute;
            arguments = {'isGuest': false};
            break;
          case 1:
            route = AppRouter.jobListRoute;
            arguments = {'isGuest': false};
            break;
          case 2:
            route = AppRouter.companiesRoute;
            break;
          case 3:
            route = AppRouter.profileRoute;
            break;
          default:
            route = AppRouter.homeRoute;
            arguments = {'isGuest': false};
        }
      } else {
        switch (index) {
          case 0:
            route = AppRouter.homeRoute;
            arguments = {'isGuest': true};
            break;
          case 1:
            route = AppRouter.jobListRoute;
            arguments = {'isGuest': true};
            break;
          case 2:
            route = AppRouter.companiesRoute;
            break;
          case 3:
            route = AppRouter.loginRoute;
            break;
          default:
            route = AppRouter.homeRoute;
            arguments = {'isGuest': true};
        }
      }
      Navigator.pushReplacementNamed(context, route, arguments: arguments);
    }

    final items = _getCandidateNavItems(isLoggedIn);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTabTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.secondaryColor,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      items: items,
    );
  }

  List<BottomNavigationBarItem> _getCandidateNavItems(bool isLoggedIn) {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business_outlined),
        activeIcon: Icon(Icons.business),
        label: 'Companies',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }
}