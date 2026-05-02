import 'package:cloud_firestore/cloud_firestore.dart';

class DnsModel {
  final String id;
  final String title;
  final String dnsAddress;
  final String username;
  final String password;
  final bool isActive;
  final String type; // e.g. "xtream"
  final String activeCode;
  final bool permissions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? expiryDate;

  DnsModel({
    required this.id,
    this.title = '',
    required this.dnsAddress,
    this.username = '',
    this.password = '',
    this.isActive = true,
    this.type = 'xtream',
    this.activeCode = '',
    this.permissions = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.expiryDate,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static String? _formatDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      final date = value.toDate();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
    if (value is String) {
      // If it's already a date string, return it. 
      // If it's a raw timestamp string, try to parse it.
      if (value.contains('-')) return value;
      final timestamp = int.tryParse(value);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
      return value;
    }
    return value.toString();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory DnsModel.fromJson(Map<String, dynamic> json) {
    return DnsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      dnsAddress: json['dns_address'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      isActive: json['is_active'] ?? true,
      type: json['type'] ?? 'xtream',
      activeCode: json['active_code'] ?? '',
      permissions: json['Permissions'] ?? json['permissions'] ?? false,
      createdAt: _parseDate(json['created_at']) ?? _parseDate(json['added_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      expiryDate: _formatDate(json['expiry_date']),
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
      'type': type,
      'active_code': activeCode,
      'Permissions': permissions,
      'created_at': createdAt.toIso8601String(),
      'added_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expiry_date': expiryDate,
    };
  }

  DnsModel copyWith({
    String? id,
    String? title,
    String? dnsAddress,
    String? username,
    String? password,
    bool? isActive,
    String? type,
    String? activeCode,
    bool? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? expiryDate,
  }) {
    return DnsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dnsAddress: dnsAddress ?? this.dnsAddress,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      activeCode: activeCode ?? this.activeCode,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
