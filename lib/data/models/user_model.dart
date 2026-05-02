import 'package:cloud_firestore/cloud_firestore.dart';

class WebUserModel {
  final String id;
  final String email; // Primary login identifier
  final String? password; // Account Login Password
  final String macAddress;
  final bool isProtected;
  final List<String> dnsIds;
  final String? deviceManager; // Device key
  final String? subscriptionType; 
  final DateTime createdAt;
  final DateTime? lastLogin;

  WebUserModel({
    required this.id,
    required this.email,
    this.password,
    this.macAddress = '',
    this.isProtected = false,
    required this.dnsIds,
    this.deviceManager,
    this.subscriptionType,
    DateTime? createdAt,
    this.lastLogin,
  }) : createdAt = createdAt ?? DateTime.now();

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory WebUserModel.fromJson(Map<String, dynamic> json) {
    return WebUserModel(
      id: json['id']?.toString() ?? '',
      // Use email if present, fallback to username for old records
      email: json['email']?.toString() ?? json['username']?.toString() ?? '',
      password: json['password']?.toString(),
      macAddress: json['mac_address']?.toString() ?? '',
      isProtected: json['is_protected'] ?? false,
      dnsIds: json['dns_id'] is List 
          ? List<String>.from(json['dns_id'])
          : (json['dns_id'] != null ? [json['dns_id'].toString()] : []),
      deviceManager: json['device_key']?.toString(),
      subscriptionType: json['subscription_type']?.toString(),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      lastLogin: _parseDate(json['last_login']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      // REMOVED 'username' to clean up the collection
      'password': password,
      'mac_address': macAddress,
      'is_protected': isProtected,
      'dns_id': dnsIds,
      'device_key': deviceManager,
      'subscription_type': subscriptionType,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  WebUserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? macAddress,
    bool? isProtected,
    List<String>? dnsIds,
    String? deviceManager,
    String? subscriptionType,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return WebUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      isProtected: isProtected ?? this.isProtected,
      dnsIds: dnsIds ?? this.dnsIds,
      deviceManager: deviceManager ?? this.deviceManager,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
