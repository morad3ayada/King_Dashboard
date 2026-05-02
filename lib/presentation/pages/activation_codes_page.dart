import 'package:flutter/material.dart';

import '../../core/services/shared_storage_service.dart';
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
  final _storage = SharedStorageService();
  final _searchController = TextEditingController();
  final _baseDomainController = TextEditingController();
  
  List<ActivationCodeModel> _codesList = [];
  List<ActivationCodeModel> _filteredCodes = [];
  List<DnsModel> _dnsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load Base Domain
    final baseDomain = await _storage.getBaseDomain();
    if (baseDomain != null) {
      _baseDomainController.text = baseDomain;
    }

    final codes = await _repo.getAllCodes();
    final dns = await _dnsRepo.getAllDns();
    
    if (!mounted) return;
    setState(() {
      _codesList = codes;
      _filteredCodes = codes;
      _dnsList = dns;
      _isLoading = false;
    });
  }

  Future<void> _saveBaseDomain() async {
    try {
      await _storage.saveBaseDomain(_baseDomainController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Base Domain saved successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving Base Domain: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _search(String query) {
    setState(() {
      _filteredCodes = _codesList.where((code) {
        final codeMatch = code.code.toLowerCase().contains(query.toLowerCase());
        final usernameMatch = code.username.toLowerCase().contains(query.toLowerCase());
        final emailMatch = code.email?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return codeMatch || usernameMatch || emailMatch;
      }).toList();
    });
  }

  void _showAddCodeDialog() {
    final codeController = TextEditingController();
    final dnsController = TextEditingController(text: _baseDomainController.text.trim());
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final m3uUrlController = TextEditingController();
    String selectedStatus = 'active';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Activation Code'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // M3U Extractor
                  const Text('M3U URL Extractor', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: m3uUrlController,
                          decoration: const InputDecoration(
                            hintText: 'Paste M3U URL here...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          final url = m3uUrlController.text.trim();
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
                  const Divider(),
                  const SizedBox(height: 16),

                  // Activation code
                  const Text('Activation code', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  const Text('DNS', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  const Text('Username', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  const Text('Password', style: TextStyle(color: Colors.grey, fontSize: 12)),
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

                  // Email
                  const Text('Email (Optional)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter email',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Status
                  const Text('User status', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                        final enteredDns = dnsController.text.trim();
                        
                        final existingDnsList = _dnsList.where((d) => d.dnsAddress == enteredDns);
                        if (existingDnsList.isNotEmpty) {
                          finalDnsId = existingDnsList.first.id;
                        } else {
                          // Create new DNS
                          final newDns = DnsModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            dnsAddress: enteredDns,
                            username: usernameController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                          await _dnsRepo.addDns(newDns);
                          finalDnsId = newDns.id;
                        }

                        final newCode = ActivationCodeModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          code: codeController.text.trim(),
                          dnsId: finalDnsId,
                          username: usernameController.text.trim(),
                          password: passwordController.text.trim(),
                          email: emailController.text.trim(),
                          userStatus: selectedStatus,
                          isUsed: false,
                          createdAt: DateTime.now(),
                        );

                        try {
                          await _repo.addCode(newCode);
                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code added successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR: Base Domain & Search
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Base Domain
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              const Icon(Icons.domain, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _baseDomainController,
                                  decoration: const InputDecoration(
                                    labelText: 'Base Domain (Default DNS)',
                                    hintText: 'http://example.com:8080',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _saveBaseDomain,
                                icon: const Icon(Icons.save),
                                label: const Text('Save Base Domain'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Actions
                        ElevatedButton.icon(
                          onPressed: _showAddCodeDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search codes by code, username or email...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: _search,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // TABLE
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
                            DataColumn(label: Text('Username/Email')),
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
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(code.username),
                                  if (code.email != null && code.email!.isNotEmpty)
                                    Text(
                                      code.email!,
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                ],
                              )),
                              DataCell(_buildStatusBadge(code.userStatus)),
                              DataCell(Icon(
                                code.isUsed ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: code.isUsed ? Colors.green : Colors.grey,
                                size: 16,
                              )),
                              DataCell(Text(code.createdAt.toString().substring(0, 16))),
                              DataCell(Text(code.usedAt != null ? code.usedAt.toString().substring(0, 16) : '-')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _deleteCode(code.id),
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.red;
        break;
      case 'trial':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _deleteCode(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Code'),
        content: const Text('Are you sure you want to delete this activation code?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await _repo.deleteCode(id);
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _baseDomainController.dispose();
    super.dispose();
  }
}
