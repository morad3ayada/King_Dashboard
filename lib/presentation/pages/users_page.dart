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

    final m3uController = TextEditingController();
    final macAddressController = TextEditingController();
    final serverNameController = TextEditingController();
    final dnsController = TextEditingController(); 
    final usernameController = TextEditingController(); // Optional Username
    final emailController = TextEditingController(); 
    final passwordController = TextEditingController();
    
    // Default values
    bool isProtected = true; 
    String selectedProtection = 'YES';

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
                            hintText: 'Enter M3U Link',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Extract Logic
                          final url = m3uController.text.trim();
                          if (url.isNotEmpty) {
                            try {
                              final uri = Uri.parse(url);
                              final scheme = uri.scheme;
                              final host = uri.host;
                              final port = uri.port;
                              
                              // DNS
                              String dns = '$scheme://$host';
                              // Always include port to ensure compatibility with all players
                              if (port != 0) {
                                dns += ':$port';
                              }
                              dnsController.text = dns;

                              // Username & Password from query params
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

                  // MAC Address
                  const Text('Mac address', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: macAddressController,
                    decoration: const InputDecoration(
                      hintText: 'A7:75:7C:0A:43:48',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Protect this playlist
                  const Text('Protect this playlist', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedProtection,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'YES', child: Text('YES')),
                          DropdownMenuItem(value: 'NO', child: Text('NO')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedProtection = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Server Name
                  const Text('Server Name', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: serverNameController,
                    decoration: const InputDecoration(
                      hintText: 'new name',
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

                  // Username (Optional)
                  const Text('Username (Optional)', style: TextStyle(color: Colors.grey)),
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

                  // Email
                  const Text('Email', style: TextStyle(color: Colors.grey)),
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
                    obscureText: false, 
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validation
                        // Require DNS and Password.
                        // Require either Username or Email to be present.
                        if (dnsController.text.isEmpty || passwordController.text.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in required fields (DNS, Password)')),
                          );
                          return;
                        }
                        
                        if (usernameController.text.isEmpty && emailController.text.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please provide either Username or Email')),
                          );
                          return;
                        }

                        // Handle DNS logic
                        String finalDnsId = '';
                        final dnsUrl = dnsController.text.trim();
                        
                        // Check if DNS exists
                        try {
                          final existingDns = dnsList.firstWhere(
                            (d) => d.dnsAddress == dnsUrl,
                            orElse: () => DnsModel(id: '', dnsAddress: '', username: '', password: ''), 
                          );

                          if (existingDns.id.isNotEmpty) {
                            finalDnsId = existingDns.id;
                          } else {
                            // Create new DNS
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
                           print('Error handling DNS: $e');
                           return; 
                        }

                        // Determine primary username
                        final finalUsername = usernameController.text.trim().isNotEmpty
                            ? usernameController.text.trim()
                            : emailController.text.trim();

                        // Create User
                        final newUser = WebUserModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: serverNameController.text.trim().isEmpty 
                              ? finalUsername
                              : serverNameController.text.trim(),
                          macAddress: macAddressController.text.trim(),
                          username: finalUsername,
                          email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                          password: passwordController.text.trim(),
                          isProtected: selectedProtection == 'YES',
                          dnsId: finalDnsId,
                          // Defaults
                          subscriptionType: 'active',
                          deviceManager: null, 
                        );

                        final success = await _repo.addUser(newUser);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User added successfully')),
                          );
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
