import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UsersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'users';

  // Get users stream
  Stream<List<WebUserModel>> getUsersStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => WebUserModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      })).toList();
    });
  }

  // Get all users
  Future<List<WebUserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => WebUserModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      })).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Search users
  Future<List<WebUserModel>> searchUsers(String query) async {
    final allUsers = await getAllUsers();
    return allUsers.where((user) {
      return user.email.toLowerCase().contains(query.toLowerCase()) ||
             user.macAddress.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Add new user
  Future<bool> addUser(WebUserModel user) async {
    try {
      // Create user in Firebase Authentication if email and password are provided
      if (user.email.isNotEmpty && 
          user.password != null && user.password!.isNotEmpty) {
        try {
          print('Attempting to create auth user with email: ${user.email}');
          
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: user.email,
            password: user.password!,
          );
          
          print('✅ Auth user created successfully with UID: ${userCredential.user!.uid}');
        } catch (authError) {
          print('⚠️ Auth creation failed (user might already exist): $authError');
        }
      }

      await _firestore.collection(_collection).doc(user.id).set(user.toJson());
      return true;
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

  // Delete user with cascade delete for DNS settings
  Future<bool> deleteUser(String id) async {
    try {
      // 1. Get user document to find linked DNS IDs
      final userDoc = await _firestore.collection(_collection).doc(id).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final dnsIds = data?['dns_id'];
        
        if (dnsIds is List) {
          // 2. Delete all linked DNS settings from 'dns_settings' collection
          for (var dnsId in dnsIds) {
            await _firestore.collection('dns_settings').doc(dnsId.toString()).delete();
          }
        }
      }

      // 3. Delete user document from Firestore
      await _firestore.collection(_collection).doc(id).delete();
      
      return true;
    } catch (e) {
      print('Error deleting user and their DNS settings: $e');
      return false;
    }
  }
}
