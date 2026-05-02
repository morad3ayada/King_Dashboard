import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/models/user_model.dart';
import '../../data/models/dns_model.dart';
import '../../data/repository/users_repo.dart';
import '../../data/repository/dns_repo.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _repo = UsersRepository();
  final _dnsRepo = DnsRepository();
  final _searchController = TextEditingController();
  
  String _searchQuery = '';
  List<DnsModel> _dnsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDnsList();
  }

  Future<void> _loadDnsList() async {
    final dns = await _dnsRepo.getAllDns();
    if (mounted) {
      setState(() {
        _dnsList = dns;
      });
    }
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<WebUserModel> _filterUsers(List<WebUserModel> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      return user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.macAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (user.deviceManager ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<String?> _fetchExpiryFromApi(String dnsAddress, String username, String password) async {
    try {
      String baseUrl = dnsAddress.endsWith('/') ? dnsAddress.substring(0, dnsAddress.length - 1) : dnsAddress;
      final url = Uri.parse('$baseUrl/player_api.php?username=$username&password=$password');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['user_info'] != null) {
          final expDateStr = data['user_info']['exp_date'];
          if (expDateStr != null && expDateStr != "" && expDateStr != "null") {
            final timestamp = int.tryParse(expDateStr.toString());
            if (timestamp != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
              return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching expiry: $e');
    }
    return null;
  }

  Future<void> _toggleProtect(WebUserModel user) async {
    final newValue = !user.isProtected;
    final success = await _repo.toggleProtect(user.id, newValue);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Protection ${newValue ? "enabled" : "disabled"}')),
      );
    }
  }

  Future<void> _showAddDnsDialog(WebUserModel user) async {
    final m3uController = TextEditingController();
    final dnsController = TextEditingController();
    final usernameController = TextEditingController(); 
    final passwordController = TextEditingController(); 
    final titleController = TextEditingController();
    String? currentExpiry;
    bool isFetching = false;
    bool dnsPermissions = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add DNS Line to ${user.email}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Extract from M3U', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: m3uController,
                          decoration: const InputDecoration(hintText: 'Paste M3U link'),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final url = m3uController.text.trim();
                          if (url.isNotEmpty) {
                            try {
                              final uri = Uri.parse(url);
                              dnsController.text = '${uri.scheme}://${uri.host}${uri.port != 0 ? ":${uri.port}" : ""}';
                              final params = uri.queryParameters;
                              if (params.containsKey('username')) usernameController.text = params['username']!;
                              if (params.containsKey('password')) passwordController.text = params['password']!;
                              titleController.text = uri.host;
                              setState(() => isFetching = true);
                              final expiry = await _fetchExpiryFromApi(dnsController.text, usernameController.text, passwordController.text);
                              setState(() {
                                currentExpiry = expiry;
                                isFetching = false;
                              });
                            } catch (_) {}
                          }
                        },
                        icon: const Icon(Icons.download),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Playlist Title / Name')),
                  TextField(controller: dnsController, decoration: const InputDecoration(labelText: 'DNS Address')),
                  TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Playlist Username')),
                  TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Playlist Password')),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Playlist Permissions', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Enable special permissions for this line', style: TextStyle(fontSize: 10)),
                    value: dnsPermissions,
                    onChanged: (v) => setState(() => dnsPermissions = v ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isFetching ? 'Fetching Expiry...' : (currentExpiry ?? 'Expiry: N/A'),
                          style: TextStyle(color: currentExpiry != null ? Colors.green : Colors.grey, fontWeight: currentExpiry != null ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                      IconButton(
                        onPressed: isFetching ? null : () async {
                          setState(() => isFetching = true);
                          final expiry = await _fetchExpiryFromApi(dnsController.text, usernameController.text, passwordController.text);
                          setState(() {
                            currentExpiry = expiry;
                            isFetching = false;
                          });
                        },
                        icon: const Icon(Icons.sync),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (dnsController.text.isEmpty) return;
                final dnsId = DateTime.now().millisecondsSinceEpoch.toString();
                final newDns = DnsModel(
                  id: dnsId,
                  title: titleController.text.trim().isEmpty ? 'DNS Line' : titleController.text.trim(),
                  dnsAddress: dnsController.text.trim(),
                  username: usernameController.text.trim(),
                  password: passwordController.text.trim(),
                  expiryDate: currentExpiry,
                  permissions: dnsPermissions,
                );
                await _dnsRepo.addDns(newDns);
                final updatedUser = user.copyWith(dnsIds: [...user.dnsIds, dnsId]);
                await _repo.updateUser(updatedUser);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadDnsList();
                }
              },
              child: const Text('Add DNS Line'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddUserDialog() async {
    final emailController = TextEditingController();
    final accountPasswordController = TextEditingController();
    
    final m3uController = TextEditingController();
    final dnsTitleController = TextEditingController();
    final dnsAddressController = TextEditingController(); 
    final playlistUsernameController = TextEditingController();
    final playlistPasswordController = TextEditingController();
    
    String selectedSubscription = 'active';
    bool isProtected = true;
    bool dnsPermissions = false;
    String? currentExpiry;
    bool isFetching = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New User & DNS Line'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Subscription Type', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            DropdownButton<String>(
                              value: selectedSubscription,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                DropdownMenuItem(value: 'trial', child: Text('Trial')),
                              ],
                              onChanged: (v) => setState(() => selectedSubscription = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Protect Playlist', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Row(
                              children: [
                                const Text('Protected'),
                                Switch(
                                  value: isProtected,
                                  onChanged: (v) => setState(() => isProtected = v),
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Login Email / Username', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 8),
                  TextField(controller: accountPasswordController, decoration: const InputDecoration(labelText: 'Login Password', border: OutlineInputBorder(), isDense: true)),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                  
                  const Text('Playlist / DNS Line Information', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 16),
                  const Text('Title', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  TextField(controller: dnsTitleController, decoration: const InputDecoration(hintText: 'Enter Playlist Title (e.g. King Server)', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Playlist Permissions', style: TextStyle(fontSize: 14)),
                    value: dnsPermissions,
                    onChanged: (v) => setState(() => dnsPermissions = v ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: m3uController,
                          decoration: const InputDecoration(hintText: 'Extract from M3U Link', border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final url = m3uController.text.trim();
                          if (url.isNotEmpty) {
                            try {
                              final uri = Uri.parse(url);
                              dnsAddressController.text = '${uri.scheme}://${uri.host}${uri.port != 0 ? ":${uri.port}" : ""}';
                              final params = uri.queryParameters;
                              if (params.containsKey('username')) playlistUsernameController.text = params['username']!;
                              if (params.containsKey('password')) playlistPasswordController.text = params['password']!;
                              if (dnsTitleController.text.isEmpty) dnsTitleController.text = uri.host;
                              
                              setState(() => isFetching = true);
                              final expiry = await _fetchExpiryFromApi(dnsAddressController.text, playlistUsernameController.text, playlistPasswordController.text);
                              setState(() {
                                currentExpiry = expiry;
                                isFetching = false;
                              });
                            } catch (_) {}
                          }
                        },
                        icon: const Icon(Icons.download, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: dnsAddressController, decoration: const InputDecoration(labelText: 'DNS Address', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 8),
                  TextField(controller: playlistUsernameController, decoration: const InputDecoration(labelText: 'Playlist Username', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 8),
                  TextField(controller: playlistPasswordController, decoration: const InputDecoration(labelText: 'Playlist Password', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isFetching ? 'Fetching Expiry...' : (currentExpiry ?? 'Expiry: N/A'),
                          style: TextStyle(color: currentExpiry != null ? Colors.green : Colors.grey, fontWeight: currentExpiry != null ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                      IconButton(
                        onPressed: isFetching ? null : () async {
                          setState(() => isFetching = true);
                          final expiry = await _fetchExpiryFromApi(dnsAddressController.text, playlistUsernameController.text, playlistPasswordController.text);
                          setState(() {
                            currentExpiry = expiry;
                            isFetching = false;
                          });
                        },
                        icon: const Icon(Icons.sync),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty || accountPasswordController.text.isEmpty || dnsAddressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                  return;
                }

                final dnsId = DateTime.now().millisecondsSinceEpoch.toString();
                final newDns = DnsModel(
                  id: dnsId,
                  title: dnsTitleController.text.trim().isEmpty ? 'DNS Line' : dnsTitleController.text.trim(),
                  dnsAddress: dnsAddressController.text.trim(),
                  username: playlistUsernameController.text.trim(),
                  password: playlistPasswordController.text.trim(),
                  expiryDate: currentExpiry,
                  permissions: dnsPermissions,
                );
                await _dnsRepo.addDns(newDns);

                final newUser = WebUserModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  email: emailController.text.trim(),
                  password: accountPasswordController.text.trim(),
                  macAddress: "",
                  dnsIds: [dnsId],
                  subscriptionType: selectedSubscription,
                  isProtected: isProtected,
                );

                await _repo.addUser(newUser);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadDnsList();
                }
              },
              child: const Text('Create User & DNS'),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(hintText: 'Search by Email, MAC or Device Key...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                  onChanged: _search,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: StreamBuilder<List<WebUserModel>>(
              stream: _repo.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final users = _filterUsers(snapshot.data!);
                if (users.isEmpty) return const Center(child: Text('No users found'));

                return Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Email / Login', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('MAC Address', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Device Key', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Subscription', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('DNS Lines', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Protect', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: users.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(user.email)),
                            DataCell(Text(user.macAddress.isEmpty ? 'Waiting...' : user.macAddress)),
                            DataCell(Text(user.deviceManager == null || user.deviceManager!.isEmpty ? 'N/A' : user.deviceManager!)),
                            DataCell(Text(user.subscriptionType ?? 'active')),
                            DataCell(
                              Row(
                                children: [
                                  ...user.dnsIds.map((id) {
                                    final dns = _dnsList.firstWhere((d) => d.id == id, orElse: () => DnsModel(id: '', dnsAddress: 'N/A'));
                                    return Tooltip(
                                      message: 'Line: ${dns.title}\nUser: ${dns.username}\nExp: ${dns.expiryDate ?? "N/A"}\nPerm: ${dns.permissions}',
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blue)),
                                        child: Text(dns.title.isEmpty ? 'Line' : dns.title, style: const TextStyle(fontSize: 10, color: Colors.blue)),
                                      ),
                                    );
                                  }),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.blue),
                                    onPressed: () => _showAddDnsDialog(user),
                                    tooltip: 'Add New Line',
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Switch(value: user.isProtected, onChanged: (_) => _toggleProtect(user), activeColor: Colors.green)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _repo.deleteUser(user.id), tooltip: 'Delete Account'),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
