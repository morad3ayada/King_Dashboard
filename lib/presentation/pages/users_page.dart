import 'package:flutter/material.dart';

import '../../core/routing/web_router.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<WebUserModel> _filterUsers(List<WebUserModel> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      return user.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.macAddress.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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

  Future<void> _showAddTrialDialog(WebUserModel user) async {
    final daysController = TextEditingController(text: '30');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Trial for ${user.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: daysController,
              decoration: const InputDecoration(
                labelText: 'Trial Days',
                suffixText: 'days',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final days = int.tryParse(daysController.text) ?? 30;
              final success = await _repo.addTrial(user.id, days);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Trial added: $days days')),
                );
              }
            },
            child: const Text('Add Trial'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(WebUserModel user) async {
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email ?? '');
    final passwordController = TextEditingController(text: user.password ?? '');
    final titleController = TextEditingController(text: user.title);
    final macAddressController = TextEditingController(text: user.macAddress);
    final dnsIdController = TextEditingController(text: user.dnsId);
    final deviceManagerController = TextEditingController(text: user.deviceManager ?? '');
    final subscriptionTypeController = TextEditingController(text: user.subscriptionType ?? 'inactive');
    DateTime? selectedExpiryDate = user.expiryDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User: ${user.username}'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username *',
                    hintText: 'Enter username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter new password (leave empty to keep current)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: macAddressController,
                  decoration: const InputDecoration(
                    labelText: 'MAC Address *',
                    hintText: 'Enter MAC address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dnsIdController,
                  decoration: const InputDecoration(
                    labelText: 'DNS ID *',
                    hintText: 'Enter DNS ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: deviceManagerController,
                  decoration: const InputDecoration(
                    labelText: 'Device Manager',
                    hintText: 'Enter device manager (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subscriptionTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Subscription Type',
                    hintText: 'active, inactive, trial, etc.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedExpiryDate != null
                              ? 'Expiry: ${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}'
                              : 'No expiry date set',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedExpiryDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() => selectedExpiryDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Select Date'),
                      ),
                      if (selectedExpiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => selectedExpiryDate = null),
                        ),
                    ],
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
          ElevatedButton(
            onPressed: () async {
              // Validate required fields
              if (usernameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username is required')),
                );
                return;
              }
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title is required')),
                );
                return;
              }
              if (macAddressController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('MAC Address is required')),
                );
                return;
              }

              // Update user
              final updatedUser = user.copyWith(
                username: usernameController.text.trim(),
                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                password: passwordController.text.trim().isEmpty ? user.password : passwordController.text.trim(),
                title: titleController.text.trim(),
                macAddress: macAddressController.text.trim(),
                dnsId: dnsIdController.text.trim(),
                deviceManager: deviceManagerController.text.trim().isEmpty ? null : deviceManagerController.text.trim(),
                subscriptionType: subscriptionTypeController.text.trim().isEmpty ? 'inactive' : subscriptionTypeController.text.trim(),
                expiryDate: selectedExpiryDate,
              );

              final success = await _repo.updateUser(updatedUser);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully')),
                );
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update user')),
                  );
                }
              }
            },
            child: const Text('Update User'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUserDialog() async {
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

    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final titleController = TextEditingController(); // Server Name
    final macAddressController = TextEditingController();
    final deviceManagerController = TextEditingController();
    final subscriptionTypeController = TextEditingController(text: 'inactive');

    String selectedDnsId = dnsList.first.id;
    bool isProtected = false;
    DateTime? selectedExpiryDate;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. MAC Address
                  TextField(
                    controller: macAddressController,
                    decoration: const InputDecoration(
                      labelText: 'MAC Address', // Removed (Optional) label as it is primary now
                      hintText: 'Enter MAC address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Protect This Playlist (Switch)
                  SwitchListTile(
                    title: const Text('Protect this playlist'),
                    value: isProtected,
                    onChanged: (val) => setState(() => isProtected = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // 3. Server Name (Title)
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Server Name',
                      hintText: 'Enter server name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. DNS (Dropdown)
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

                  // 5. Username
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username *',
                      hintText: 'Enter username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Password
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      hintText: 'Enter password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // 7. Email
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'Enter email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Device Manager
                  TextField(
                    controller: deviceManagerController,
                    decoration: const InputDecoration(
                      labelText: 'Device Manager (Optional)',
                      hintText: 'Enter device manager',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subscription Type
                  TextField(
                    controller: subscriptionTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Subscription Type',
                      hintText: 'active, inactive, trial, etc.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expiry Date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedExpiryDate != null
                              ? 'Expiry: ${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}'
                              : 'No expiry date set',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            setState(() => selectedExpiryDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Select Date'),
                      ),
                      if (selectedExpiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => selectedExpiryDate = null),
                        ),
                    ],
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
                // Validate required fields
                if (usernameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username is required')),
                  );
                  return;
                }
                if (emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email is required')),
                  );
                  return;
                }
                if (passwordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password is required')),
                  );
                  return;
                }

                // Create new user
                final newUser = WebUserModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  username: usernameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  title: titleController.text.trim().isEmpty 
                      ? usernameController.text.trim() 
                      : titleController.text.trim(),
                  macAddress: macAddressController.text.trim().isEmpty 
                      ? '00:00:00:00:00:00' 
                      : macAddressController.text.trim(),
                  dnsId: selectedDnsId,
                  isProtected: isProtected,
                  deviceManager: deviceManagerController.text.trim().isEmpty 
                      ? null 
                      : deviceManagerController.text.trim(),
                  subscriptionType: subscriptionTypeController.text.trim().isEmpty 
                      ? 'inactive' 
                      : subscriptionTypeController.text.trim(),
                  expiryDate: selectedExpiryDate,
                );

                final success = await _repo.addUser(newUser);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User added successfully')),
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add user')),
                    );
                  }
                }
              },
              child: const Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
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
      final success = await _repo.deleteUser(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    }
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
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _search,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<WebUserModel>>(
              stream: _repo.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = _filterUsers(snapshot.data!);

                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }

                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('MAC Address')),
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Device Key')),
                        DataColumn(label: Text('Subscription')),
                        DataColumn(label: Text('Protect')),
                        DataColumn(label: Text('DNS')),
                        DataColumn(label: Text('Expiry')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: users.map((user) {
                        return DataRow(cells: [
                          DataCell(Text(user.title)),
                          DataCell(Text(user.macAddress)),
                          DataCell(Text(user.username)),
                          DataCell(Text(user.email ?? 'N/A')),
                          DataCell(Text(user.deviceManager ?? 'N/A')),
                          DataCell(Text(user.subscriptionType ?? 'inactive')),
                          DataCell(
                            Switch(
                              value: user.isProtected,
                              onChanged: (_) => _toggleProtect(user),
                            ),
                          ),
                          DataCell(Text('DNS ${user.dnsId}')),
                          DataCell(Text(
                            user.expiryDate != null
                                ? '${user.expiryDate!.day}/${user.expiryDate!.month}/${user.expiryDate!.year}'
                                : 'N/A',
                          )),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showEditUserDialog(user),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.card_giftcard, size: 20, color: Colors.orange),
                                  onPressed: () => _showAddTrialDialog(user),
                                  tooltip: 'Add Trial',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteUser(user.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
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
