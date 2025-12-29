import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dns_model.dart';

class DnsRepository {
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'dns_settings';

  Future<List<DnsModel>> getAllDns() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => DnsModel.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching DNS: $e');
      return [];
    }
  }

  Future<bool> addDns(DnsModel dns) async {
    try {
      await _firestore.collection(_collection).doc(dns.id).set(dns.toJson());
      return true;
    } catch (e) {
      print('Error adding DNS: $e');
      return false;
    }
  }

  Future<bool> updateDns(DnsModel dns) async {
    try {
      await _firestore.collection(_collection).doc(dns.id).update(dns.toJson());
      return true;
    } catch (e) {
      print('Error updating DNS: $e');
      return false;
    }
  }

  Future<bool> deleteDns(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting DNS: $e');
      return false;
    }
  }
}
