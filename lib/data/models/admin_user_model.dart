class AdminUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final List<String> permissions;
  final bool isSuperAdmin;

  AdminUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.permissions,
    this.isSuperAdmin = false,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      isSuperAdmin: json['is_super_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'permissions': permissions,
      'is_super_admin': isSuperAdmin,
    };
  }
  
  AdminUser copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? password,
    List<String>? permissions,
    bool? isSuperAdmin,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      permissions: permissions ?? this.permissions,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
    );
  }
}
