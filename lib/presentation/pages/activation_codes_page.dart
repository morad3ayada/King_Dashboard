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

    if (dnsList.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a DNS server first in DNS Settings')),
        );
      }
      return;
    }

    final titleController = TextEditingController();
    final codeController = TextEditingController(text: _repo.generateRandomCodeString());
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    
    String selectedDnsId = dnsList.first.id;
    String selectedStatus = 'active';

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Activation Code'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. M3U Extractor (Title)
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'M3U Extractor',
                      hintText: 'Enter title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Activation Code
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Activation Code',
                      hintText: 'Enter or generate code',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          codeController.text = _repo.generateRandomCodeString();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. DNS (Dropdown)
                  DropdownButtonFormField<String>(
                    value: selectedDnsId,
                    decoration: const InputDecoration(
                      labelText: 'DNS',
                      border: OutlineInputBorder(),
                    ),
                    items: dnsList.map((dns) {
                      return DropdownMenuItem(
                        value: dns.id,
                        child: Text(dns.dnsAddress),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDnsId = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Username
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Password
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // User Status
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'trial', child: Text('Trial')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedStatus = val);
                    },
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
            ElevatedButton(
              onPressed: () async {
                 if (codeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code is required')),
                  );
                  return;
                }

                final newCode = ActivationCodeModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  code: codeController.text.trim(),
                  dnsId: selectedDnsId,
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
              child: const Text('Add Code'),
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
