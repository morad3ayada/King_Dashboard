import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repository/app_settings_repo.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AppSettingsRepository();
  
  // Backgrounds
  final _backgroundLiveController = TextEditingController();
  final _homeBackgroundController = TextEditingController();
  
  // Contact Us
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qrController = TextEditingController();
  final _webController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _linkedinController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update previews
    _backgroundLiveController.addListener(() => setState(() {}));
    _homeBackgroundController.addListener(() => setState(() {}));
    _qrController.addListener(() => setState(() {}));
    _whatsappController.addListener(() => setState(() {}));
    _linkedinController.addListener(() => setState(() {}));
    _webController.addListener(() => setState(() {}));
    
    _loadSettings();
  }

  @override
  void dispose() {
    _backgroundLiveController.dispose();
    _homeBackgroundController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qrController.dispose();
    _webController.dispose();
    _whatsappController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final general = await _repo.getGeneralSettings();
      final contact = await _repo.getContactSettings();
      final homeBg = await _repo.getHomeBackground();

      if (general != null) {
        _backgroundLiveController.text = general['Background_Live'] ?? '';
      }
      
      if (contact != null) {
        _emailController.text = contact['Email'] ?? '';
        _phoneController.text = contact['Phone'] ?? '';
        _qrController.text = contact['QR'] ?? '';
        _webController.text = contact['Web'] ?? '';
        _whatsappController.text = contact['Whatsapp'] ?? '';
        _linkedinController.text = contact['linkdin'] ?? '';
      }

      _homeBackgroundController.text = homeBg ?? '';
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    try {
      await _repo.updateGeneralSettings({
        'Background_Live': _backgroundLiveController.text.trim(),
      });

      await _repo.updateContactSettings({
        'Email': _emailController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'QR': _qrController.text.trim(),
        'Web': _webController.text.trim(),
        'Whatsapp': _whatsappController.text.trim(),
        'linkdin': _linkedinController.text.trim(),
      });

      await _repo.updateHomeBackground(_homeBackgroundController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openLink(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'App Configuration',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  icon: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save All Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // 1. Contact Us Card
            _buildSectionCard(
              title: 'Contact Us',
              icon: Icons.contact_support,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _whatsappController,
                            label: 'WhatsApp URL / Image',
                            icon: Icons.chat,
                          ),
                          const SizedBox(height: 8),
                          _buildSmallPreview(_whatsappController.text),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _linkedinController,
                            label: 'LinkedIn URL / Image',
                            icon: Icons.link,
                          ),
                          const SizedBox(height: 8),
                          _buildSmallPreview(_linkedinController.text),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _webController,
                            label: 'Web URL',
                            icon: Icons.language,
                          ),
                          const SizedBox(height: 8),
                          _buildSmallPreview(_webController.text),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _qrController,
                            label: 'QR Code URL / Image',
                            icon: Icons.qr_code,
                          ),
                          const SizedBox(height: 8),
                          _buildSmallPreview(_qrController.text),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 2. Backgrounds Section
            const Text(
              'App Backgrounds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSectionCard(
                    title: 'Background Live',
                    icon: Icons.live_tv,
                    children: [
                      _buildTextField(
                        controller: _backgroundLiveController,
                        label: 'Live Background URL',
                        icon: Icons.link,
                      ),
                      const SizedBox(height: 16),
                      _buildImagePreview(_backgroundLiveController.text),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSectionCard(
                    title: 'Background Home',
                    icon: Icons.home_filled,
                    children: [
                      _buildTextField(
                        controller: _homeBackgroundController,
                        label: 'Home Background URL',
                        icon: Icons.image,
                      ),
                      const SizedBox(height: 16),
                      _buildImagePreview(_homeBackgroundController.text),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFF8F00), size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF8F00), size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 2),
        ),
      ),
    );
  }

  Widget _buildSmallPreview(String url) {
    if (url.isEmpty || !url.startsWith('http')) return const SizedBox.shrink();
    
    return InkWell(
      onTap: () => _openLink(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.link, color: Colors.grey, size: 20),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 1));
                  },
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Icon(Icons.open_in_new, size: 14, color: Colors.grey.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(String url) {
    return InkWell(
      onTap: () => _openLink(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: url.isEmpty
            ? const Center(child: Text('No Image URL', style: TextStyle(color: Colors.grey, fontSize: 12)))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image_outlined, color: Colors.red, size: 24),
                            const SizedBox(height: 4),
                            const Text('Failed to load image', style: TextStyle(color: Colors.red, fontSize: 10)),
                            if (Uri.tryParse(url)?.isAbsolute ?? false)
                               const Text('Check CORS or URL', style: TextStyle(color: Colors.grey, fontSize: 8)),
                          ],
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
