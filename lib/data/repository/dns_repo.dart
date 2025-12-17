import '../models/dns_model.dart';
import '../services/web_api_service.dart';

class DnsRepository {
  final _api = WebApiService();
  
  // Dummy data
  final List<DnsModel> _dnsList = [
    DnsModel(
      id: '1',
      dnsAddress: 'http://example.com:8080',
      username: 'user1',
      password: 'pass1',
      isActive: true,
    ),
    DnsModel(
      id: '2',
      dnsAddress: 'http://example2.com:8080',
      username: 'user2',
      password: 'pass2',
      isActive: true,
    ),
  ];

  Future<List<DnsModel>> getAllDns() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_dnsList);
  }

  Future<bool> addDns(DnsModel dns) async {
    try {
      await _api.post('/dns/add', dns.toJson());
      _dnsList.add(dns);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDns(DnsModel dns) async {
    try {
      await _api.put('/dns/update/${dns.id}', dns.toJson());
      final index = _dnsList.indexWhere((d) => d.id == dns.id);
      if (index != -1) {
        _dnsList[index] = dns;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDns(String id) async {
    try {
      await _api.delete('/dns/delete/$id');
      _dnsList.removeWhere((d) => d.id == id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
