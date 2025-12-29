import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activation_code_model.dart';

class ActivationRepository {
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'activation_codes';

  Future<List<ActivationCodeModel>> getAllCodes() async {
    try {
      final snapshot = await _firestore.collection(_collection).orderBy('created_at', descending: true).get();
      return snapshot.docs.map((doc) => ActivationCodeModel.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching codes: $e');
      return [];
    }
  }

  Future<ActivationCodeModel?> addCode(ActivationCodeModel code) async {
    try {
      await _firestore.collection(_collection).doc(code.id).set(code.toJson());
      return code;
    } catch (e) {
      print('Error adding code: $e');
      return null;
    }
  }

  Future<bool> deleteCode(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting code: $e');
      return false;
    }
  }

  String generateRandomCodeString() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final year = DateTime.now().year;
    // Generate 8 random characters to match the style in image "980376a8" or keep "KING-YYYY-XXXXXX" if user prefers. 
    // The user image shows "980376a8". Let's generate a hex-like string of 8 chars.
    // Or just hex string.
    // I will stick to a random hex string of length 8 as shown in the placeholder/example.
    // Example in image: "980376a8" => 8 chars hex.
    const hexChars = '0123456789abcdef';
    return List.generate(8, (index) => hexChars[random.nextInt(hexChars.length)]).join();
  }
}
