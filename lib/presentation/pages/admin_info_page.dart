import 'package:flutter/material.dart';

import '../../core/routing/web_routes.dart';
import '../../data/models/admin_model.dart';
import '../../data/repository/admin_repo.dart';

class AdminInfoPage extends StatefulWidget {
  const AdminInfoPage({super.key});

  @override
  State<AdminInfoPage> createState() => _AdminInfoPageState();
}

class _AdminInfoPageState extends State<AdminInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AdminRepository();
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _panelNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _contactUrlController = TextEditingController();
  final _footerUrlController = TextEditingController();
  final _footerTextController = TextEditingController();
  
  String? _logoPath;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final admin = await _repo.getAdminInfo();
    
    _usernameController.text = admin.username;
    _passwordController.text = admin.password;
    _panelNameController.text = admin.panelName;
    _brandNameController.text = admin.brandName;
    _contactUrlController.text = admin.contactUrl;
    _footerUrlController.text = admin.loginFooterUrl;
    _footerTextController.text = admin.loginFooterText;
    _logoPath = admin.logoImagePath;
    
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final admin = AdminModel(
      id: '1',
      username: _usernameController.text,
      password: _passwordController.text,
      panelName: _panelNameController.text,
      brandName: _brandNameController.text,
      contactUrl: _contactUrlController.text,
      loginFooterUrl: _footerUrlController.text,
      loginFooterText: _footerTextController.text,
      logoImagePath: _logoPath,
    );
    
    final success = await _repo.updateAdminInfo(admin);
    
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Saved successfully!' : 'Failed to save'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadLogo() async {
    // Simulate file picker
    // In real app, use file_picker package
    await Future.delayed(const Duration(milliseconds: 500));
    
    final uploadedPath = await _repo.uploadLogo('dummy_path.png');
    if (uploadedPath != null) {
      setState(() => _logoPath = uploadedPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo uploaded successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Account Information',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _usernameController,
                                    label: 'Username',
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _panelNameController,
                                    label: 'Panel Name',
                                    icon: Icons.dashboard,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _brandNameController,
                                    label: 'Brand Name',
                                    icon: Icons.branding_watermark,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _contactUrlController,
                                    label: 'Contact URL',
                                    icon: Icons.link,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _footerUrlController,
                                    label: 'Login Footer URL',
                                    icon: Icons.link,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _footerTextController,
                                    label: 'Login Footer Text',
                                    icon: Icons.text_fields,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLogoUpload(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isSaving ? null : _save,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  WebRoutes.login,
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.logout, color: Colors.red),
                              label: const Text('Logout', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildLogoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Logo Image (PNG only)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _logoPath != null
              ? Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(_logoPath!, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _logoPath = null),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: ElevatedButton.icon(
                    onPressed: _uploadLogo,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload PNG'),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _panelNameController.dispose();
    _brandNameController.dispose();
    _contactUrlController.dispose();
    _footerUrlController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }
}
