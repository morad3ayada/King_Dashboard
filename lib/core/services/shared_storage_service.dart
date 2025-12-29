import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../data/models/admin_user_model.dart';

class SharedStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ==================== ACTIVATION CODES ====================
  
  Future<List<Map<String, dynamic>>> getActivationCodes() async {
    try {
      final snapshot = await _firestore.collection('activation_codes').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting activation codes: $e');
      return [];
    }
  }

  Future<void> saveActivationCode(Map<String, dynamic> codeData) async {
    try {
      final docId = codeData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore.collection('activation_codes').doc(docId).set(codeData);
    } catch (e) {
      print('Error saving activation code: $e');
      rethrow;
    }
  }

  Future<void> deleteActivationCode(String id) async {
    try {
      await _firestore.collection('activation_codes').doc(id).delete();
    } catch (e) {
      print('Error deleting activation code: $e');
      rethrow;
    }
  }

  // ==================== USERS ====================
  
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final docId = userData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore.collection('users').doc(docId).set(userData);
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  Future<void> updateUserProtection(String userId, bool isProtected) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'is_protected': isProtected,
      });
    } catch (e) {
      print('Error updating user protection: $e');
      rethrow;
    }
  }

  Future<void> addUserTrial(String userId, DateTime expiryDate) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'expiry_date': expiryDate.toIso8601String(),
      });
    } catch (e) {
      print('Error adding user trial: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // ==================== ADMINS ====================
  
  Future<Map<String, dynamic>?> getAdminByUsername(String username) async {
    try {
      final snapshot = await _firestore
          .collection('admins')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data();
    } catch (e) {
      print('Error getting admin: $e');
      return null;
    }
  }

  Future<AdminUser?> loginAdmin(String username, String password) async {
    try {
      final snapshot = await _firestore
          .collection('admins')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final data = snapshot.docs.first.data();
      final hashedPassword = _hashPassword(password);
      
      if (data['password'] == hashedPassword) {
        return AdminUser.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error logging in admin: $e');
      return null;
    }
  }

  Future<void> createDefaultAdmin() async {
    try {
      // Check if admin already exists
      final existingAdmin = await getAdminByUsername('admin');
      if (existingAdmin != null) {
        print('Default admin already exists');
        return;
      }

      // Create default admin
      final adminData = {
        'id': 'admin_001',
        'name': 'Super Admin',
        'username': 'admin',
        'password': _hashPassword('admin123'),
        'email': 'admin@kingiptv.com',
        'permissions': [], // Super admin doesn't need explicit permissions
        'is_super_admin': true,
        'created_at': DateTime.now().toIso8601String(),
        'last_login': null,
      };

      await _firestore.collection('admins').doc('admin_001').set(adminData);
      print('Default admin created successfully');
    } catch (e) {
      print('Error creating default admin: $e');
      rethrow;
    }
  }

  Future<void> updateAdminLastLogin(String username) async {
    try {
      final admin = await getAdminByUsername(username);
      if (admin == null) return;

      await _firestore.collection('admins').doc(admin['id']).update({
        'last_login': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating admin last login: $e');
    }
  }
  // ==================== SPORTS ====================

  Future<String?> getSportLink() async {
    try {
      final doc = await _firestore.collection('app_settings').doc('sports').get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['link'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting sport link: $e');
      return null;
    }
  }

  Future<void> saveSportLink(String link) async {
    try {
      await _firestore.collection('app_settings').doc('sports').set({
        'link': link,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving sport link: $e');
      rethrow;
    }
  }
}

