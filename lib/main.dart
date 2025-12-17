import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/web_theme.dart';
import 'core/routing/web_router.dart';
import 'core/routing/web_routes.dart';
import 'core/services/shared_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: defaultTargetPlatform == TargetPlatform.windows
        ? DefaultFirebaseOptions.web
        : DefaultFirebaseOptions.currentPlatform,
  );
  
  // Create default admin if not exists
  try {
    final storageService = SharedStorageService();
    await storageService.createDefaultAdmin();
  } catch (e) {
    print('Error creating default admin: $e');
  }
  
  runApp(const WebAdminApp());
}

class WebAdminApp extends StatelessWidget {
  const WebAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'King IPTV - Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: WebTheme.lightTheme,
      initialRoute: WebRoutes.login,
      onGenerateRoute: WebRouter.generateRoute,
    );
  }
}