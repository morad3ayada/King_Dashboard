import 'package:flutter/material.dart';

import '../../core/routing/web_routes.dart';
import '../../data/models/admin_model.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/repository/admin_repo.dart';

class AdminInfoPage extends StatefulWidget {
  final AdminUser? currentUser;
  const AdminInfoPage({super.key, this.currentUser});

  @override
  State<AdminInfoPage> createState() => _AdminInfoPageState();
}

class _AdminInfoPageState extends State<AdminInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AdminRepository();
  
  // Settings Controllers
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

  List<AdminUser> _admins = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final admin = await _repo.getAdminInfo();
    final adminsList = await _repo.getAllAdmins();
    
    _usernameController.text = admin.username;
    _passwordController.text = admin.password;
    _panelNameController.text = admin.panelName;
    _brandNameController.text = admin.brandName;
    _contactUrlController.text = admin.contactUrl;
    _footerUrlController.text = admin.loginFooterUrl;
    _footerTextController.text = admin.loginFooterText;
    _logoPath = admin.logoImagePath;
    
    _admins = adminsList;

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

  // Check if current user has full admin access (can manage other admins)
  bool _hasFullAdminAccess() {
    if (widget.currentUser == null) return true; // Fallback for dev/testing
    if (widget.currentUser!.isSuperAdmin) return true;
    return widget.currentUser!.permissions.contains('access_admin');
  }

  // --- Sub-Admin Management ---

  Future<void> _showAddAdminDialog() async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    // Permissions state
    // Maps technical key to display label
    final Map<String, String> availablePermissions = {
      'access_users': 'Manage Users',
      'access_codes': 'Activation Codes',
      'access_dns': 'DNS Settings',
      'access_admin': 'Admin Settings',
    };
    final Set<String> selectedPermissions = {};

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Admin'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                   TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username (Login)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedPermissions.length == availablePermissions.length) {
                              selectedPermissions.clear();
                            } else {
                              selectedPermissions.addAll(availablePermissions.keys);
                            }
                          });
                        },
                        child: Text(
                          selectedPermissions.length == availablePermissions.length 
                              ? 'Deselect All' 
                              : 'Full Permissions'
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...availablePermissions.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedPermissions.contains(entry.key),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedPermissions.add(entry.key);
                          } else {
                            selectedPermissions.remove(entry.key);
                          }
                        });
                      },
                      dense: true,
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final newAdmin = AdminUser(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  username: usernameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  permissions: selectedPermissions.toList(),
                );

                final success = await _repo.addAdmin(newAdmin);
                if (success) {
                  _loadData(); // reload list
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Admin added successfully')),
                    );
                  }
                }
              },
              child: const Text('Add Admin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditAdminDialog(AdminUser admin) async {
    final nameController = TextEditingController(text: admin.name);
    final usernameController = TextEditingController(text: admin.username);
    final emailController = TextEditingController(text: admin.email);
    final passwordController = TextEditingController(); // Leave empty, only update if filled
    
    // Permissions state
    final Map<String, String> availablePermissions = {
      'access_users': 'Manage Users',
      'access_codes': 'Activation Codes',
      'access_dns': 'DNS Settings',
      'access_admin': 'Admin Settings',
    };
    final Set<String> selectedPermissions = Set.from(admin.permissions);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Admin'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                   TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username (Login)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password (leave empty to keep current)', 
                      border: OutlineInputBorder()
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedPermissions.length == availablePermissions.length) {
                              selectedPermissions.clear();
                            } else {
                              selectedPermissions.addAll(availablePermissions.keys);
                            }
                          });
                        },
                        child: Text(
                          selectedPermissions.length == availablePermissions.length 
                              ? 'Deselect All' 
                              : 'Full Permissions'
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...availablePermissions.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedPermissions.contains(entry.key),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedPermissions.add(entry.key);
                          } else {
                            selectedPermissions.remove(entry.key);
                          }
                        });
                      },
                      dense: true,
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || usernameController.text.isEmpty || emailController.text.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final updatedAdmin = admin.copyWith(
                  name: nameController.text.trim(),
                  username: usernameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.isNotEmpty ? passwordController.text.trim() : admin.password,
                  permissions: selectedPermissions.toList(),
                );

                final success = await _repo.updateAdmin(updatedAdmin);
                if (success) {
                  _loadData(); // reload list
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Admin updated successfully')),
                    );
                  }
                }
              },
              child: const Text('Update Admin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAdmin(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this admin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repo.deleteAdmin(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Global Settings Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Global Configuration & Master Admin',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            // Existing Rows...
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                        controller: _usernameController,
                                        label: 'Master Username',
                                        icon: Icons.person,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _passwordController,
                                        label: 'Master Password',
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
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.save),
                                  label: Text(_isSaving ? 'Saving...' : 'Save Configuration'),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(context, WebRoutes.login, (route) => false);
                                  },
                                  icon: const Icon(Icons.logout, color: Colors.red),
                                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Admins Management Card
                  if (_hasFullAdminAccess()) // Only show if user has admin management permission
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Manage Admins',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showAddAdminDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Admin'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, 
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_admins.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No additional admins found. Use "Add Admin" to create one.'),
                              )
                            else
                              DataTable(
                                columns: const [
                                  DataColumn(label: Text('Full Name')),
                                  DataColumn(label: Text('Username')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Permissions')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _admins.map((admin) {
                                  return DataRow(cells: [
                                    DataCell(Text(admin.name)),
                                    DataCell(Text(admin.username)),
                                    DataCell(Text(admin.email)),
                                    DataCell(Text(admin.permissions.join(', '))),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showEditAdminDialog(admin),
                                            tooltip: 'Edit Admin',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteAdmin(admin.id),
                                            tooltip: 'Delete Admin',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
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
