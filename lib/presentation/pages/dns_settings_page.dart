import 'package:flutter/material.dart';

import '../../data/models/dns_model.dart';
import '../../data/repository/dns_repo.dart';

class DnsSettingsPage extends StatefulWidget {
  const DnsSettingsPage({super.key});

  @override
  State<DnsSettingsPage> createState() => _DnsSettingsPageState();
}

class _DnsSettingsPageState extends State<DnsSettingsPage> {
  final _repo = DnsRepository();
  List<DnsModel> _dnsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _dnsList = await _repo.getAllDns();
    setState(() => _isLoading = false);
  }

  Future<void> _showAddEditDialog({DnsModel? dns}) async {
    final titleController = TextEditingController(text: dns?.title ?? '');
    final dnsController = TextEditingController(text: dns?.dnsAddress ?? '');
    final usernameController = TextEditingController(text: dns?.username ?? '');
    final passwordController = TextEditingController(text: dns?.password ?? '');
    final typeController = TextEditingController(text: dns?.type ?? 'xtream');
    final activeCodeController = TextEditingController(text: dns?.activeCode ?? '');
    final expiryController = TextEditingController(text: dns?.expiryDate ?? '');
    
    bool isActive = dns?.isActive ?? true;
    bool permissions = dns?.permissions ?? false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(dns == null ? 'Add New DNS Setting' : 'Edit DNS: ${dns.title}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: dnsController, decoration: const InputDecoration(labelText: 'DNS Address', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: activeCodeController, decoration: const InputDecoration(labelText: 'Active Code', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: expiryController,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date (YYYY-MM-DD)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                          );
                          if (date != null) {
                            expiryController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  CheckboxListTile(
                    title: const Text('Is Active'),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text('Permissions'),
                    value: permissions,
                    onChanged: (v) => setDialogState(() => permissions = v ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newDns = DnsModel(
                  id: dns?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  dnsAddress: dnsController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                  isActive: isActive,
                  type: typeController.text,
                  activeCode: activeCodeController.text,
                  permissions: permissions,
                  expiryDate: expiryController.text.isEmpty ? null : expiryController.text,
                  createdAt: dns?.createdAt,
                  updatedAt: DateTime.now(),
                );

                if (dns == null) {
                  await _repo.addDns(newDns);
                } else {
                  await _repo.updateDns(newDns);
                }
                
                _loadData();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save DNS'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Global DNS Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add New DNS Line'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('DNS Address', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Active', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Expiry', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _dnsList.map((dns) {
                            return DataRow(cells: [
                              DataCell(Text(dns.title)),
                              DataCell(Text(dns.dnsAddress)),
                              DataCell(Text(dns.username)),
                              DataCell(Text(dns.password)),
                              DataCell(Text(dns.type)),
                              DataCell(
                                Icon(
                                  dns.isActive ? Icons.check_circle : Icons.cancel,
                                  color: dns.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                              DataCell(Text(dns.expiryDate ?? 'N/A')),
                              DataCell(Text(dns.permissions.toString())),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _showAddEditDialog(dns: dns),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete DNS'),
                                            content: const Text('Are you sure? This will affect users linked to this DNS.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                              ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await _repo.deleteDns(dns.id);
                                          _loadData();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
