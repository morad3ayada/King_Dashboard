import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UsersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'users';

  // Stream for real-time updates
  Stream<List<WebUserModel>> getUsersStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return WebUserModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          macAddress: data['mac_address'] ?? '',
          username: data['username'] ?? '',
          email: data['email'],
          password: data['password'],
          isProtected: data['is_protected'] ?? false,
          dnsId: data['dns_id'] ?? '1',
          deviceManager: data['device_key'],
          subscriptionType: data['subscription_type'],
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
          expiryDate: data['expiry_date'] != null
              ? DateTime.parse(data['expiry_date'])
              : null,
        );
      }).toList();
    });
  }

  // Get all users (one-time fetch)
  Future<List<WebUserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return WebUserModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          macAddress: data['mac_address'] ?? '',
          username: data['username'] ?? '',
          email: data['email'],
          password: data['password'],
          isProtected: data['is_protected'] ?? false,
          dnsId: data['dns_id'] ?? '1',
          deviceManager: data['device_key'],
          subscriptionType: data['subscription_type'],
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
          expiryDate: data['expiry_date'] != null
              ? DateTime.parse(data['expiry_date'])
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Search users
  Future<List<WebUserModel>> searchUsers(String query) async {
    final allUsers = await getAllUsers();
    return allUsers.where((user) {
      return user.title.toLowerCase().contains(query.toLowerCase()) ||
             user.username.toLowerCase().contains(query.toLowerCase()) ||
             user.macAddress.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Add new user
  Future<bool> addUser(WebUserModel user) async {
    try {
      // Create user in Firebase Authentication if email and password are provided
      if (user.email != null && user.email!.isNotEmpty && 
          user.password != null && user.password!.isNotEmpty) {
        try {
          print('Attempting to create auth user with email: ${user.email}');
          
          // Create auth user
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: user.email!,
            password: user.password!,
          );
          
          print('✅ Auth user created successfully with UID: ${userCredential.user!.uid}');
          
          // Update the user model with the Firebase Auth UID
          final updatedUser = user.copyWith(
            id: userCredential.user!.uid,
          );
          
          // Save to Firestore with the Auth UID
          await _firestore.collection(_collection).doc(updatedUser.id).set(updatedUser.toJson());
          
          print('✅ User saved to Firestore with UID: ${userCredential.user!.uid}');
          return true;
        } on FirebaseAuthException catch (authError) {
          print('❌ Firebase Auth Error: ${authError.code} - ${authError.message}');
          // If auth creation fails, still save to Firestore with generated ID
          await _firestore.collection(_collection).doc(user.id).set(user.toJson());
          print('⚠️ User saved to Firestore only (Auth failed): ${user.id}');
          return true;
        } catch (authError) {
          print('❌ Unknown Auth Error: $authError');
          // If auth creation fails, still save to Firestore with generated ID
          await _firestore.collection(_collection).doc(user.id).set(user.toJson());
          return true;
        }
      } else {
        print('ℹ️ No email/password provided, saving to Firestore only');
        // No email/password, just save to Firestore
        await _firestore.collection(_collection).doc(user.id).set(user.toJson());
        return true;
      }
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(WebUserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).update(user.toJson());
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Toggle protect status
  Future<bool> toggleProtect(String userId, bool isProtected) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'is_protected': isProtected,
      });
      return true;
    } catch (e) {
      print('Error toggling protect: $e');
      return false;
    }
  }

  // Add trial period
  Future<bool> addTrial(String userId, int days) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: days));
      await _firestore.collection(_collection).doc(userId).update({
        'expiry_date': expiryDate.toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding trial: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    try {
      // Delete from Firestore
      await _firestore.collection(_collection).doc(id).delete();
      
      // Try to delete from Firebase Auth
      // Note: This requires admin SDK or the user to be currently signed in
      // For now, we'll just delete from Firestore
      // To delete from Auth, you'd need Firebase Admin SDK or Cloud Functions
      
      print('User deleted from Firestore: $id');
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
