import 'package:flutter/material.dart';
import '../../presentation/pages/web_login_page.dart';
import '../../presentation/layout/web_dashboard_layout.dart';
import 'web_routes.dart';

class WebRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case WebRoutes.login:
        return MaterialPageRoute(builder: (_) => const WebLoginPage());
      case WebRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const WebDashboardLayout());
      // For now, redirect specific dashboard internal routes to the dashboard shell
      // This allows basic "deep linking" where the user lands on the dashboard default page
      // To support true deep linking, we would need to pass the route to WebDashboardLayout
      case WebRoutes.adminInfo:
      case WebRoutes.dnsSettings:
      case WebRoutes.users:
      case WebRoutes.activationCodes:
      case WebRoutes.sportSettings:
        return MaterialPageRoute(builder: (_) => const WebDashboardLayout());
      default:
        return MaterialPageRoute(builder: (_) => const WebLoginPage());
    }
  }
}
