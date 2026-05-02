import 'package:flutter/material.dart';
import '../../data/repository/app_settings_repo.dart';

class SportsPage extends StatefulWidget {
  const SportsPage({super.key});

  @override
  State<SportsPage> createState() => _SportsPageState();
}

class _SportsPageState extends State<SportsPage> {
  final _repo = AppSettingsRepository();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for text fields
  final _apiKeyController = TextEditingController();
  final _v1UrlController = TextEditingController();
  final _v2UrlController = TextEditingController();

  // Color values (stored as hex strings)
  Map<String, String> _colors = {
    'bg_color': '#0A0A0A',
    'card_focus_bg': '#FFD700',
    'card_focus_border': '#FFFFFF',
    'card_focus_text': '#000000',
    'card_idle_bg': '#1A1A1A',
    'primary_accent': '#FFD700',
    'ray_color': '#FFD700',
    'text_primary': '#FFFFFF',
    'text_secondary': '#AAAAAA',
    'title_color': '#FFD700',
    'back_btn_bg': '#333333',
    'back_btn_icon': '#FFFFFF',
  };

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _repo.getSportScreenSettings();
    if (data != null) {
      _apiKeyController.text = data['api_key'] ?? '';
      _v1UrlController.text = data['v1_api_url'] ?? '';
      _v2UrlController.text = data['v2_api_url'] ?? '';
      
      // Load colors if they exist in Firestore
      _colors.keys.forEach((key) {
        if (data.containsKey(key)) {
          _colors[key] = data[key];
        }
      });
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> data = {
        'api_key': _apiKeyController.text.trim(),
        'v1_api_url': _v1UrlController.text.trim(),
        'v2_api_url': _v2UrlController.text.trim(),
        ..._colors,
      };
      
      await _repo.updateSportScreenSettings(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sports settings saved successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _pickColor(String key) {
    final currentColor = _parseHexColor(_colors[key]!);
    final hexController = TextEditingController(text: _colors[key]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick Color for $key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple Color Grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.black, Colors.white, Colors.red, Colors.green, 
                Colors.blue, Colors.yellow, Colors.orange, Colors.purple,
                Colors.grey, Colors.amber, Colors.cyan, Colors.teal,
              ].map((color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _colors[key] = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Or enter Hex Code:'),
            const SizedBox(height: 8),
            TextField(
              controller: hexController,
              decoration: const InputDecoration(
                hintText: '#RRGGBB',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                if (val.length == 7 && val.startsWith('#')) {
                  // Valid hex format
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = hexController.text.trim().toUpperCase();
              if (val.startsWith('#') && (val.length == 7 || val.length == 9)) {
                setState(() {
                  _colors[key] = val;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid Hex Code')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _parseHexColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sports Screen Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveData,
                  icon: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // API Config Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('API Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildTextField(controller: _apiKeyController, label: 'API Key', icon: Icons.key),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _v1UrlController, label: 'V1 API URL', icon: Icons.link),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _v2UrlController, label: 'V2 API URL', icon: Icons.link),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Colors Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Design & Colors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _colors.length,
                      itemBuilder: (context, index) {
                        final key = _colors.keys.elementAt(index);
                        return _buildColorTile(key);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTile(String key) {
    final hexValue = _colors[key]!;
    final color = _parseHexColor(hexValue);
    
    return InkWell(
      onTap: () => _pickColor(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hexValue,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.colorize, size: 16, color: Colors.grey),
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
        prefixIcon: Icon(icon, color: const Color(0xFFFF8F00), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
