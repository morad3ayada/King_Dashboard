import 'package:flutter/material.dart';
import '../../core/routing/web_router.dart';
import '../../core/routing/web_routes.dart';
import '../../data/models/admin_user_model.dart';
import '../pages/admin_info_page.dart';
import '../pages/dns_settings_page.dart';
import '../pages/users_page.dart';
import '../pages/activation_codes_page.dart';
import '../pages/sports_page.dart';
import '../pages/images_page.dart';

class WebDashboardLayout extends StatefulWidget {
  final AdminUser? currentUser;
  const WebDashboardLayout({super.key, this.currentUser});

  @override
  State<WebDashboardLayout> createState() => _WebDashboardLayoutState();
}

class _WebDashboardLayoutState extends State<WebDashboardLayout> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = _getFirstAccessibleRoute();
  }

  bool _hasPermission(String permission) {
    if (widget.currentUser == null) return true; // Default/Fallback to super access if null (e.g. dev mode) OR handle strict. 
    // Assuming null means simple test or super admin for now as per previous logic.
    // If we want strict, we should redirect to login. But let's assume super admin if null for dev friendliness or legacy.
    // Better: check isSuperAdmin.
    if (widget.currentUser!.isSuperAdmin) return true;
    return widget.currentUser!.permissions.contains(permission);
  }
  
  String _getFirstAccessibleRoute() {
    if (_hasPermission('access_admin')) return WebRoutes.adminInfo;
    if (_hasPermission('access_dns')) return WebRoutes.dnsSettings;
    if (_hasPermission('access_users')) return WebRoutes.users;
    if (_hasPermission('access_codes')) return WebRoutes.activationCodes;
    // Images accessible to all
    return WebRoutes.imageList; 
  }

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
                      if (_hasPermission('access_admin'))
                        _buildMenuItem(
                          icon: Icons.person,
                          title: 'Admin Info',
                          route: WebRoutes.adminInfo,
                        ),
                      if (_hasPermission('access_dns'))
                        _buildMenuItem(
                          icon: Icons.dns,
                          title: 'DNS Settings',
                          route: WebRoutes.dnsSettings,
                        ),
                      if (_hasPermission('access_users'))
                        _buildMenuItem(
                          icon: Icons.people,
                          title: 'MAC Users',
                          route: WebRoutes.users,
                        ),
                      if (_hasPermission('access_codes'))
                        _buildMenuItem(
                          icon: Icons.code,
                          title: 'Activation Codes',
                          route: WebRoutes.activationCodes,
                        ),
                      if (_hasPermission('access_admin')) // Using admin permission for sport for now
                        _buildMenuItem(
                          icon: Icons.sports_soccer,
                          title: 'Sport',
                          route: WebRoutes.sportSettings,
                        ),
                      
                      // Image List - accessible to all
                      _buildMenuItem(
                        icon: Icons.image,
                        title: 'Image List',
                        route: WebRoutes.imageList,
                      ),
                        
                      const Divider(color: Colors.white24, height: 24),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: Colors.white70),
                          title: const Text('Logout', style: TextStyle(color: Colors.white70)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onTap: () {
                             Navigator.pushNamedAndRemoveUntil(context, WebRoutes.login, (route) => false);
                          },
                        ),
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
                      if (widget.currentUser != null)
                        Text(
                          'Welcome, ${widget.currentUser!.username}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(width: 16),
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
                    initialRoute: _currentRoute, // Use computed accessible route
                    onGenerateRoute: (settings) {
                      Widget page;
                      // Fallback logic in case _currentRoute is set to something forbidden (shouldn't happen with UI logic but good for safety)
                      // We can re-check permissions here if needed.
                      
                      switch (settings.name) {
                        case WebRoutes.adminInfo:
                          page = AdminInfoPage(currentUser: widget.currentUser);
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
                        case WebRoutes.imageList:
                          page = const ImagesPage();
                          break;
                        default:
                          page = AdminInfoPage(currentUser: widget.currentUser);
                      }
                      
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
// ... keep existing methods _buildMenuItem and _getPageTitle ...
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
      case WebRoutes.imageList:
        return 'Image Gallery';
      default:
        return 'Dashboard';
    }
  }
}
