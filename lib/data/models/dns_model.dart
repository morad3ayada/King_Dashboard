class DnsModel {
  final String id;
  final String dnsAddress;
  final String username;
  final String password;
  final bool isActive;
  final DateTime createdAt;

  DnsModel({
    required this.id,
    required this.dnsAddress,
    required this.username,
    required this.password,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DnsModel.fromJson(Map<String, dynamic> json) {
    return DnsModel(
      id: json['id'] ?? '',
      dnsAddress: json['dns_address'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dns_address': dnsAddress,
      'username': username,
      'password': password,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DnsModel copyWith({
    String? id,
    String? dnsAddress,
    String? username,
    String? password,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DnsModel(
      id: id ?? this.id,
      dnsAddress: dnsAddress ?? this.dnsAddress,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
