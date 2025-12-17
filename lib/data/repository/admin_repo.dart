import '../models/admin_model.dart';
import '../services/web_api_service.dart';

class AdminRepository {
  final _api = WebApiService();
  
  // Dummy data
  AdminModel _adminData = AdminModel(
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

  Future<AdminModel> getAdminInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _adminData;
  }

  Future<bool> updateAdminInfo(AdminModel admin) async {
    try {
      await _api.post('/admin/update', admin.toJson());
      _adminData = admin;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadLogo(String filePath) async {
    try {
      final uploadedPath = await _api.uploadFile('/admin/upload-logo', filePath);
      return uploadedPath;
    } catch (e) {
      return null;
    }
  }
}
