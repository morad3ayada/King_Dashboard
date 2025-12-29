import 'package:flutter/material.dart';

import '../../core/routing/web_router.dart';
import '../../data/models/activation_code_model.dart';
import '../../data/models/dns_model.dart';
import '../../data/repository/activation_repo.dart';
import '../../data/repository/dns_repo.dart';

class ActivationCodesPage extends StatefulWidget {
  const ActivationCodesPage({super.key});

  @override
  State<ActivationCodesPage> createState() => _ActivationCodesPageState();
}

class _ActivationCodesPageState extends State<ActivationCodesPage> {
  final _repo = ActivationRepository();
  final _dnsRepo = DnsRepository();
  final _searchController = TextEditingController();
  
  List<ActivationCodeModel> _codesList = [];
  List<ActivationCodeModel> _filteredCodes = [];
  List<DnsModel> _dnsList = [];
  bool _isLoading = true;
  
  String? _selectedDnsId;
  String _selectedStatus = 'active';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _codesList = await _repo.getAllCodes();
    _dnsList = await _dnsRepo.getAllDns();
    _filteredCodes = _codesList;
    if (_dnsList.isNotEmpty) {
      _selectedDnsId = _dnsList.first.id;
    }
    setState(() => _isLoading = false);
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCodes = _codesList;
      } else {
        _filteredCodes = _codesList.where((code) {
          return code.code.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deleteCode(String codeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Code'),
        content: const Text('Are you sure you want to delete this activation code?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repo.deleteCode(codeId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code deleted successfully')),
        );
      }
    }
  }

  Future<void> _showAddCodeDialog() async {
    setState(() => _isLoading = true);
    final dnsList = await _dnsRepo.getAllDns();
    setState(() => _isLoading = false);

    final m3uController = TextEditingController();
    final codeController = TextEditingController(text: _repo.generateRandomCodeString());
    final dnsController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    
    String selectedStatus = 'active'; // Default per image/logic (Active or NotUsed which usually means active but not yet redeemed? Model has 'userStatus'. I'll use 'active' default)
    // Image shows "NotUsed" in a box. It might be a status 'inactive' or just 'not_used'. 
    // Existing values in dropdown were: active, inactive, trial.
    // If I look at the image "User status": "NotUsed".
    // I will add "NotUsed" as an option or map 'inactive' to it? 
    // The previous code had 'active', 'inactive', 'trial'.
    // I will stick to these technical values but display them nicely. 
    // Or maybe the user wants a text field?
    // The image shows a grey box "NotUsed", looks disabled?
    // usually activation codes created are "active" (ready to be used) but "not used" yet.
    // The model has `isUsed` boolean and `userStatus` string.
    // I'll keep the Dropdown for flexibility but default to 'active'. 

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: const EdgeInsets.all(24),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // M3U Extractor
                   const Text(
                    'M3U Extractor',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: m3uController,
                          decoration: const InputDecoration(
                            hintText: 'https://example.com/get.php?username=...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          final url = m3uController.text.trim();
                          if (url.isNotEmpty) {
                            try {
                              final uri = Uri.parse(url);
                              final scheme = uri.scheme;
                              final host = uri.host;
                              final port = uri.port;
                              
                              String dns = '$scheme://$host';
                              if (port != 0 && port != 80 && port != 443) {
                                dns += ':$port';
                              }
                              dnsController.text = dns;

                              final params = uri.queryParameters;
                              if (params.containsKey('username')) {
                                usernameController.text = params['username']!;
                              }
                              if (params.containsKey('password')) {
                                passwordController.text = params['password']!;
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid URL format')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Extract'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activation code
                  const Text('Activation code', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter code',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DNS
                  const Text('DNS', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dnsController,
                    decoration: const InputDecoration(
                      hintText: 'http://domain.com:port',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Username
                  const Text('Username', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter username',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  const Text('Password', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Enter password',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Status
                  const Text('User status', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                          DropdownMenuItem(value: 'trial', child: Text('Trial')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedStatus = val);
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                         if (codeController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code is required')),
                          );
                          return;
                        }
                        if (dnsController.text.trim().isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('DNS is required')),
                          );
                          return;
                        }

                        // DNS Logic
                        String finalDnsId = '';
                        final dnsUrl = dnsController.text.trim();
                        try {
                          final existingDns = dnsList.firstWhere(
                            (d) => d.dnsAddress == dnsUrl,
                            orElse: () => DnsModel(id: '', dnsAddress: '', username: '', password: ''),
                          );

                          if (existingDns.id.isNotEmpty) {
                            finalDnsId = existingDns.id;
                          } else {
                            final newDnsId = DateTime.now().millisecondsSinceEpoch.toString();
                            final newDns = DnsModel(
                              id: newDnsId,
                              title: Uri.tryParse(dnsUrl)?.host ?? 'Auto Created',
                              dnsAddress: dnsUrl,
                              username: '',
                              password: '',
                            );
                            await _dnsRepo.addDns(newDns);
                            finalDnsId = newDnsId;
                          }
                        } catch (e) {
                          print('DNS Error: $e');
                          return;
                        }

                        final newCode = ActivationCodeModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: Uri.tryParse(dnsUrl)?.host ?? 'My Playlist', // Fallback title
                          code: codeController.text.trim(),
                          dnsId: finalDnsId,
                          username: usernameController.text.trim(),
                          password: passwordController.text.trim(),
                          userStatus: selectedStatus,
                        );

                        final addedCode = await _repo.addCode(newCode);
                        if (addedCode != null) {
                          _loadData(); // Reload list
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Code added: ${newCode.code}')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
             TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search codes...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _search,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddCodeDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Code')),
                          DataColumn(label: Text('M3U Extractor')),
                          DataColumn(label: Text('DNS')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Used')),
                          DataColumn(label: Text('Created')),
                          DataColumn(label: Text('Used At')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _filteredCodes.map((code) {
                          final dns = _dnsList.firstWhere(
                            (d) => d.id == code.dnsId,
                            orElse: () => DnsModel(
                              id: '',
                              dnsAddress: 'Unknown',
                              username: '',
                              password: '',
                            ),
                          );
                          
                          return DataRow(cells: [
                            DataCell(
                              SelectableText(
                                code.code,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text(code.title.isEmpty ? 'N/A' : code.title)),
                            DataCell(Text(dns.dnsAddress)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: code.userStatus == 'active'
                                      ? Colors.green[100]
                                      : code.userStatus == 'trial'
                                          ? Colors.orange[100]
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  code.userStatus.toUpperCase(),
                                  style: TextStyle(
                                    color: code.userStatus == 'active'
                                        ? Colors.green[900]
                                        : code.userStatus == 'trial'
                                            ? Colors.orange[900]
                                            : Colors.grey[900],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Icon(
                                code.isUsed ? Icons.check_circle : Icons.cancel,
                                color: code.isUsed ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                            ),
                            DataCell(Text(
                              '${code.createdAt.day}/${code.createdAt.month}/${code.createdAt.year}',
                            )),
                            DataCell(Text(
                              code.usedAt != null
                                  ? '${code.usedAt!.day}/${code.usedAt!.month}/${code.usedAt!.year}'
                                  : 'N/A',
                            )),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _deleteCode(code.id),
                                tooltip: 'Delete',
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
