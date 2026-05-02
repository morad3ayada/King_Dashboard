import 'package:flutter/material.dart';
import '../../data/repository/app_settings_repo.dart';

class ColorsPage extends StatefulWidget {
  const ColorsPage({super.key});

  @override
  State<ColorsPage> createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> {
  final _repo = AppSettingsRepository();
  
  // Sectioned data
  Map<String, String> _generalColors = {};
  Map<String, String> _homeScreenColors = {};
  Map<String, String> _settingsScreenColors = {};
  Map<String, String> _playlistColors = {};
  Map<String, String> _playlistTexts = {};
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAllColors();
  }

  Future<void> _loadAllColors() async {
    setState(() => _isLoading = true);
    
    try {
      final generalData = await _repo.getAppColors();
      final homeData = await _repo.getHomeScreenColors();
      final settingsData = await _repo.getSettingsScreenColors();
      final playlistData = await _repo.getPlaylistScreenSettings();

      if (generalData != null) {
        _generalColors = {};
        generalData.forEach((k, v) => _generalColors[k] = v.toString());
      }
      
      if (homeData != null) {
        _homeScreenColors = {};
        homeData.forEach((k, v) => _homeScreenColors[k] = v.toString());
      }
      
      if (settingsData != null) {
        _settingsScreenColors = {};
        settingsData.forEach((k, v) {
          if (k.contains('color')) {
            _settingsScreenColors[k] = v.toString();
          }
        });
      }

      if (playlistData != null) {
        _playlistColors = {};
        _playlistTexts = {};
        playlistData.forEach((k, v) {
          final value = v.toString();
          if (value.startsWith('#')) {
            _playlistColors[k] = value;
          } else {
            _playlistTexts[k] = value;
          }
        });
      }
    } catch (e) {
      print('Error loading colors: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveAllColors() async {
    setState(() => _isSaving = true);
    try {
      await _repo.updateAppColors(_generalColors);
      await _repo.updateHomeScreenColors(_homeScreenColors);
      await _repo.updateSettingsScreenColors(_settingsScreenColors);
      await _repo.updatePlaylistScreenSettings({..._playlistColors, ..._playlistTexts});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All settings saved successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving colors: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _pickColor(String key, Map<String, String> sectionMap) {
    final hexController = TextEditingController(text: sectionMap[key]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Color: ${key.replaceAll('_', ' ').toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.black, Colors.white, Colors.red, Colors.green, 
                Colors.blue, Colors.yellow, Colors.orange, Colors.purple,
                Colors.grey, Colors.amber, Colors.cyan, Colors.teal,
                const Color(0xFFFF8F00),
              ].map((color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      sectionMap[key] = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
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
            TextField(
              controller: hexController,
              decoration: const InputDecoration(
                labelText: 'Hex Code',
                hintText: '#RRGGBB',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = hexController.text.trim().toUpperCase();
              if (val.startsWith('#') && (val.length == 7 || val.length == 9)) {
                setState(() {
                  sectionMap[key] = val;
                });
                Navigator.pop(context);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Screens Configuration',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveAllColors,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save All Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8F00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildColorSection(title: 'General Theme Colors', icon: Icons.palette_outlined, colorMap: _generalColors),
          const SizedBox(height: 24),

          _buildColorSection(title: 'Home Screen Colors', icon: Icons.home_outlined, colorMap: _homeScreenColors),
          const SizedBox(height: 24),

          _buildPlaylistSection(),
          const SizedBox(height: 24),
          
          _buildColorSection(title: 'Settings Screen Colors', icon: Icons.settings_display_outlined, colorMap: _settingsScreenColors),
        ],
      ),
    );
  }

  Widget _buildPlaylistSection() {
    if (_playlistColors.isEmpty && _playlistTexts.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt_outlined, color: Color(0xFFFF8F00), size: 24),
                const SizedBox(width: 12),
                Text('Playlist Screen Config', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            
            // Labels/Texts
            const Text('Labels & Titles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _playlistTexts.keys.map((key) {
                return SizedBox(
                  width: 300,
                  child: TextFormField(
                    initialValue: _playlistTexts[key],
                    onChanged: (v) => _playlistTexts[key] = v,
                    decoration: InputDecoration(
                      labelText: key.replaceAll('_', ' ').toUpperCase(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Colors
            const Text('Colors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _playlistColors.length,
              itemBuilder: (context, index) {
                final key = _playlistColors.keys.elementAt(index);
                return _buildColorTile(key, _playlistColors);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection({
    required String title,
    required IconData icon,
    required Map<String, String> colorMap,
  }) {
    if (colorMap.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFF8F00), size: 24),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: colorMap.length,
              itemBuilder: (context, index) {
                final key = colorMap.keys.elementAt(index);
                return _buildColorTile(key, colorMap);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTile(String key, Map<String, String> sectionMap) {
    final hexValue = sectionMap[key]!;
    final color = _parseHexColor(hexValue);
    
    return InkWell(
      onTap: () => _pickColor(key, sectionMap),
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
}
