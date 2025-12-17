import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../core/services/shared_storage_service.dart';

/// Script to create default admin in Firestore
/// Run this once to initialize the admin user
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔥 Firebase initialized successfully');
  print('📝 Creating default admin...');
  
  try {
    final storageService = SharedStorageService();
    await storageService.createDefaultAdmin();
    
    print('✅ Default admin created successfully!');
    print('');
    print('📋 Admin Details:');
    print('   Username: admin');
    print('   Password: admin123');
    print('   Email: admin@kingiptv.com');
    print('   Role: super_admin');
    print('');
    print('🎉 You can now login to the dashboard!');
  } catch (e) {
    print('❌ Error creating admin: $e');
  }
}
