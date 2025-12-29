import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/admin_model.dart';
import '../models/admin_user_model.dart';

class AdminRepository {
  final _firestore = FirebaseFirestore.instance;
  final String _settingsCollection = 'settings';
  final String _settingsDocId = 'config';
  final String _adminsCollection = 'admins';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Fetch Global Settings (AdminModel)
  Future<AdminModel> getAdminInfo() async {
    try {
      final doc = await _firestore.collection(_settingsCollection).doc(_settingsDocId).get();
      if (doc.exists && doc.data() != null) {
        return AdminModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Error fetching admin info: $e');
    }
    
    // Default fallback
    return AdminModel(
      id: '1',
      username: 'admin',
      password: 'admin123',
      panelName: 'King IPTV Admin Panel',
      brandName: 'King Player',
      contactUrl: 'https://example.com/contact',
      loginFooterUrl: 'https://example.com',
      loginFooterText: 'Powered by King Player',
      logoImagePath: null,
    );
  }

  // Update Global Settings & Master Admin Credentials
  Future<bool> updateAdminInfo(AdminModel admin) async {
    try {
      // 1. Save config/branding to settings
      await _firestore.collection(_settingsCollection).doc(_settingsDocId).set(admin.toJson());

      // 2. Sync Master Credentials to admins collection
      // Assuming 'admin_001' is the reserved ID for Master Admin
      final hashedPassword = _hashPassword(admin.password);
      
      final masterAdminData = {
        'id': 'admin_001',
        'name': 'Super Admin', // Display name for master admin
        'username': admin.username,
        'email': 'admin@kingiptv.com', // fallback or add email to AdminModel if needed
        'password': hashedPassword,
        'permissions': [], // Super admin doesn't need explicit permissions list usually
        'is_super_admin': true,
      };

      await _firestore.collection(_adminsCollection).doc('admin_001').set(masterAdminData);

      return true;
    } catch (e) {
      print('Error updating admin info: $e');
      return false;
    }
  }

  // --- Admin User Management ---

  Future<List<AdminUser>> getAllAdmins() async {
    try {
      final snapshot = await _firestore.collection(_adminsCollection).get();
      return snapshot.docs.map((doc) => AdminUser.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching admins: $e');
      return [];
    }
  }

  Future<bool> addAdmin(AdminUser user) async {
    try {
      // Hash password before saving
      final hashedPassword = _hashPassword(user.password);
      final userToSave = user.copyWith(password: hashedPassword);
      
      await _firestore.collection(_adminsCollection).doc(userToSave.id).set(userToSave.toJson());
      return true;
    } catch (e) {
      print('Error adding admin: $e');
      return false;
    }
  }

  Future<bool> updateAdmin(AdminUser user) async {
    try {
      // Hash password before saving (it might be already hashed if not changed, but we hash again for safety)
      final hashedPassword = _hashPassword(user.password);
      final userToSave = user.copyWith(password: hashedPassword);
      
      await _firestore.collection(_adminsCollection).doc(userToSave.id).update(userToSave.toJson());
      return true;
    } catch (e) {
      print('Error updating admin: $e');
      return false;
    }
  }

  Future<bool> deleteAdmin(String id) async {
    try {
      await _firestore.collection(_adminsCollection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting admin: $e');
      return false;
    }
  }

  Future<String?> uploadLogo(String filePath) async {
    // Simulation
    await Future.delayed(const Duration(milliseconds: 500));
    return filePath; // In real app, upload to storage and return URL
  }
}
