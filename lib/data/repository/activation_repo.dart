import 'dart:math';
import '../models/activation_code_model.dart';
import '../services/web_api_service.dart';
import '../../../core/services/shared_storage_service.dart';

class ActivationRepository {
  final _api = WebApiService();
  final _sharedStorage = SharedStorageService();

  Future<List<ActivationCodeModel>> getAllCodes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Get codes from shared storage
    final codesData = await _sharedStorage.getActivationCodes();
    
    return codesData.map((codeData) {
      return ActivationCodeModel(
        id: codeData['id'] ?? '',
        code: codeData['code'] ?? '',
        dnsId: codeData['dns_id'] ?? '',
        userStatus: codeData['user_status'] ?? 'inactive',
        isUsed: codeData['is_used'] ?? false,
        createdAt: codeData['created_at'] != null
            ? DateTime.parse(codeData['created_at'])
            : DateTime.now(),
        usedAt: codeData['used_at'] != null
            ? DateTime.parse(codeData['used_at'])
            : null,
        usedByUserId: codeData['used_by_user_id'],
      );
    }).toList();
  }

  Future<List<ActivationCodeModel>> searchCodes(String query) async {
    final allCodes = await getAllCodes();
    await Future.delayed(const Duration(milliseconds: 200));
    
    return allCodes.where((code) {
      return code.code.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<ActivationCodeModel?> addCode(ActivationCodeModel code) async {
    try {
      await _api.post('/activation/generate', code.toJson());
      await _sharedStorage.saveActivationCode(code.toJson());
      
      return code;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteCode(String id) async {
    try {
      await _api.delete('/activation/delete/$id');
      await _sharedStorage.deleteActivationCode(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  String generateRandomCodeString() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final year = DateTime.now().year;
    final randomPart = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    return 'KING-$year-$randomPart';
  }
}
