import 'package:flutter/material.dart';

import '../../core/routing/web_router.dart';
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
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dns == null ? 'Add New DNS' : 'Edit DNS'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'My DNS Server',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dnsController,
                  decoration: const InputDecoration(
                    labelText: 'DNS Address',
                    hintText: 'http://example.com:8080',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
              if (formKey.currentState!.validate()) {
                final newDns = DnsModel(
                  id: dns?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  dnsAddress: dnsController.text,
                  username: '',
                  password: '',
                );

                bool success;
                if (dns == null) {
                  success = await _repo.addDns(newDns);
                } else {
                  success = await _repo.updateDns(newDns);
                }

                if (success) {
                  _loadData();
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDns(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this DNS?'),
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

    if (confirm == true) {
      final success = await _repo.deleteDns(id);
      if (success) _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DNS Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add New DNS'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Title')),
                          DataColumn(label: Text('DNS Address')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Created')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _dnsList.map((dns) {
                          return DataRow(cells: [
                            DataCell(Text(dns.title.isNotEmpty ? dns.title : '-')),
                            DataCell(Text(dns.dnsAddress)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: dns.isActive ? Colors.green[100] : Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  dns.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: dns.isActive ? Colors.green[900] : Colors.red[900],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(
                              '${dns.createdAt.day}/${dns.createdAt.month}/${dns.createdAt.year}',
                            )),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showAddEditDialog(dns: dns),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                    onPressed: () => _deleteDns(dns.id),
                                    tooltip: 'Delete',
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
        ],
      );
  }
}
