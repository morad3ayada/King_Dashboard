import 'package:flutter/material.dart';
import '../../presentation/pages/web_login_page.dart';
import '../../presentation/layout/web_dashboard_layout.dart';
import '../../data/models/admin_user_model.dart';
import 'web_routes.dart';

class WebRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case WebRoutes.login:
        return MaterialPageRoute(builder: (_) => const WebLoginPage());
      case WebRoutes.dashboard:
        final adminUser = settings.arguments as AdminUser?;
        return MaterialPageRoute(builder: (_) => WebDashboardLayout(currentUser: adminUser));
      // For now, redirect specific dashboard internal routes to the dashboard shell
      // This allows basic "deep linking" where the user lands on the dashboard default page
      // To support true deep linking, we would need to pass the route to WebDashboardLayout
      case WebRoutes.adminInfo:
      case WebRoutes.dnsSettings:
      case WebRoutes.users:
      case WebRoutes.activationCodes:
      case WebRoutes.sportSettings:
      case WebRoutes.imageList:
        // Note: Deep linking with args needs state management or query params in web.
        // For simple usage, we redirect to login if no user arg is present, or dashboard default.
        return MaterialPageRoute(builder: (_) => const WebDashboardLayout());
      default:
        return MaterialPageRoute(builder: (_) => const WebLoginPage());
    }
  }
}
