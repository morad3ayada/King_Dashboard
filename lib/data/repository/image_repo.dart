import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/image_model.dart';

class ImageRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final String _collection = 'images';
  final String _storagePath = 'images';

  // Get all images
  Future<List<ImageModel>> getAllImages() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => ImageModel.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  // Upload image to Firebase Storage and save metadata to Firestore
  Future<ImageModel?> uploadImage(String fileName, Uint8List fileBytes) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final storagePath = '$_storagePath/$id-$fileName';
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      // Create image model
      final image = ImageModel(
        id: id,
        name: fileName,
        url: downloadUrl,
        storagePath: storagePath,
        sizeInBytes: fileBytes.length,
      );
      
      // Save metadata to Firestore
      await _firestore.collection(_collection).doc(id).set(image.toJson());
      
      return image;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Update image name
  Future<bool> updateImageName(String id, String newName) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'name': newName,
      });
      return true;
    } catch (e) {
      print('Error updating image: $e');
      return false;
    }
  }

  // Delete image from Storage and Firestore
  Future<bool> deleteImage(ImageModel image) async {
    try {
      // Delete from Storage
      final ref = _storage.ref().child(image.storagePath);
      await ref.delete();
      
      // Delete from Firestore
      await _firestore.collection(_collection).doc(image.id).delete();
      
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get image file size in readable format
  String getReadableFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
