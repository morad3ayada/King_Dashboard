class DnsModel {
  final String id;
  final String title;
  final String dnsAddress;
  final String username;
  final String password;
  final bool isActive;
  final DateTime createdAt;

  DnsModel({
    required this.id,
    this.title = '',
    required this.dnsAddress,
    this.username = '',
    this.password = '',
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DnsModel.fromJson(Map<String, dynamic> json) {
    return DnsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
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
      'title': title,
      'dns_address': dnsAddress,
      'username': username,
      'password': password,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DnsModel copyWith({
    String? id,
    String? title,
    String? dnsAddress,
    String? username,
    String? password,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DnsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dnsAddress: dnsAddress ?? this.dnsAddress,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
