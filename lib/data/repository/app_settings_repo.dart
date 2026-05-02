import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettingsRepository {
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'app_settings';

  // 1. General Settings
  Future<Map<String, dynamic>?> getGeneralSettings() async {
    try {
      final doc = await _firestore.collection(_collection).doc('General').get();
      return doc.data();
    } catch (e) {
      print('Error fetching General settings: $e');
      return null;
    }
  }

  Future<void> updateGeneralSettings(Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc('General').set(data, SetOptions(merge: true));
  }

  // 2. Contact Us Settings
  Future<Map<String, dynamic>?> getContactSettings() async {
    try {
      final doc = await _firestore.collection(_collection).doc('Contact Us').get();
      return doc.data();
    } catch (e) {
      print('Error fetching Contact Us settings: $e');
      return null;
    }
  }

  Future<void> updateContactSettings(Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc('Contact Us').set(data, SetOptions(merge: true));
  }

  // 3. Background Home
  Future<String?> getHomeBackground() async {
    try {
      final doc = await _firestore.collection(_collection).doc('BACKGROUND HOME').get();
      return doc.data()?['Background'] as String?;
    } catch (e) {
      print('Error fetching Home background: $e');
      return null;
    }
  }

  Future<void> updateHomeBackground(String url) async {
    await _firestore.collection(_collection).doc('BACKGROUND HOME').set({'Background': url}, SetOptions(merge: true));
  }

  // 4. Background Screen
  Future<String?> getScreenBackground() async {
    try {
      final doc = await _firestore.collection(_collection).doc('SettingsScreen').get();
      return doc.data()?['Background'] as String?;
    } catch (e) {
      print('Error fetching Screen background: $e');
      return null;
    }
  }

  Future<void> updateScreenBackground(String url) async {
    await _firestore.collection(_collection).doc('SettingsScreen').set({'Background': url}, SetOptions(merge: true));
  }

  // 5. Sport Screen Settings
  Future<Map<String, dynamic>?> getSportScreenSettings() async {
    try {
      final doc = await _firestore.collection(_collection).doc('SportScreen').get();
      return doc.data();
    } catch (e) {
      print('Error fetching Sport Screen settings: $e');
      return null;
    }
  }

  Future<void> updateSportScreenSettings(Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc('SportScreen').set(data, SetOptions(merge: true));
  }

  // 6. App Wide Colors
  Future<Map<String, dynamic>?> getAppColors() async {
    try {
      final doc = await _firestore.collection(_collection).doc('Colors').get();
      return doc.data();
    } catch (e) {
      print('Error fetching App Colors: $e');
      return null;
    }
  }

  Future<void> updateAppColors(Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc('Colors').set(data, SetOptions(merge: true));
  }

  // 7. Settings Screen Colors
  Future<Map<String, dynamic>?> getSettingsScreenColors() async {
    try {
      final doc = await _firestore.collection(_collection).doc('SettingsScreen').get();
      return doc.data();
    } catch (e) {
      print('Error fetching Settings Screen Colors: $e');
      return null;
    }
  }

  Future<void> updateSettingsScreenColors(Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc('SettingsScreen').set(data, SetOptions(merge: true));
  }

  // 8. Home Screen Colors
  Future<Map<String, dynamic>?> getHomeScreenColors() async {
    try {
      final doc = await _firestore.collection(_collection).doc('Home').get();
      return doc.data();
    } catch (e) {
      print('Error fetching Home Screen Colors: $e');
      return null;
    }
  }

  Future<void> updateHomeScreenColors(Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc('Home').set(data, SetOptions(merge: true));
  }

  // 9. Playlist Screen Settings
  Future<Map<String, dynamic>?> getPlaylistScreenSettings() async {
    try {
      final doc = await _firestore.collection(_collection).doc('PlaylistScreen').get();
      return doc.data();
    } catch (e) {
      print('Error fetching Playlist Screen settings: $e');
      return null;
    }
  }

  Future<void> updatePlaylistScreenSettings(Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc('PlaylistScreen').set(data, SetOptions(merge: true));
  }
}
