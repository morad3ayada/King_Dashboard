import 'package:flutter/material.dart';
import '../../core/routing/web_router.dart';
import '../../core/routing/web_routes.dart';
import '../pages/admin_info_page.dart';
import '../pages/dns_settings_page.dart';
import '../pages/users_page.dart';
import '../pages/activation_codes_page.dart';
import '../pages/sports_page.dart';

class WebDashboardLayout extends StatefulWidget {
  const WebDashboardLayout({super.key});

  @override
  State<WebDashboardLayout> createState() => _WebDashboardLayoutState();
}

class _WebDashboardLayoutState extends State<WebDashboardLayout> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _currentRoute = WebRoutes.adminInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFFFF8F00), // Dark Amber/Orange
            child: Column(
              children: [
                // Logo/Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildMenuItem(
                        icon: Icons.person,
                        title: 'Admin Info',
                        route: WebRoutes.adminInfo,
                      ),
                      _buildMenuItem(
                        icon: Icons.dns,
                        title: 'DNS Settings',
                        route: WebRoutes.dnsSettings,
                      ),
                      _buildMenuItem(
                        icon: Icons.people,
                        title: 'Users',
                        route: WebRoutes.users,
                      ),
                      _buildMenuItem(
                        icon: Icons.code,
                        title: 'Activation Codes',
                        route: WebRoutes.activationCodes,
                      ),
                      _buildMenuItem(
                        icon: Icons.sports_soccer,
                        title: 'Sport',
                        route: WebRoutes.sportSettings,
                      ),
                    ],
                  ),
                ),
                // Footer
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'King IPTV © 2026 (Dev: Morad3ayada)',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDE7), // Very light yellow
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getPageTitle(_currentRoute),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                        tooltip: 'Notifications',
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        backgroundColor: Color(0xFFFFA000), // Amber
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Page Content (Nested Navigator)
                Expanded(
                  child: Navigator(
                    key: _navigatorKey,
                    initialRoute: WebRoutes.adminInfo,
                    onGenerateRoute: (settings) {
                      Widget page;
                      switch (settings.name) {
                        case WebRoutes.adminInfo:
                          page = const AdminInfoPage();
                          break;
                        case WebRoutes.dnsSettings:
                          page = const DnsSettingsPage();
                          break;
                        case WebRoutes.users:
                          page = const UsersPage();
                          break;
                        case WebRoutes.activationCodes:
                          page = const ActivationCodesPage();
                          break;
                        case WebRoutes.sportSettings:
                          page = const SportsPage();
                          break;
                        default:
                          page = const AdminInfoPage();
                      }
                      
                      // Update title when route changes (simplified)
                      // ideally checking route name from settings
                      
                      return MaterialPageRoute(
                        builder: (_) => Container(
                          padding: const EdgeInsets.all(24),
                          child: page,
                        ),
                        settings: settings,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = _currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? const Color(0xFFFFA000) : Colors.white70, // Amber for active
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        if (_currentRoute != route) {
          setState(() => _currentRoute = route);
          _navigatorKey.currentState!.pushReplacementNamed(route);
        }
      },
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case WebRoutes.adminInfo:
        return 'Admin Account Info';
      case WebRoutes.dnsSettings:
        return 'DNS Settings';
      case WebRoutes.users:
        return 'Current Users';
      case WebRoutes.activationCodes:
        return 'Activation Codes';
      case WebRoutes.sportSettings:
        return 'Sports Settings';
      default:
        return 'Dashboard';
    }
  }
}
