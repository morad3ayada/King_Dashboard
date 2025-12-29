import 'package:cloud_firestore/cloud_firestore.dart';

class WebUserModel {
  final String id;
  final String title;
  final String macAddress;
  final String username;
  final String? email;
  final String? password;
  final bool isProtected;
  final String dnsId;
  final String? deviceManager; // Device manager identifier
  final String? subscriptionType; // Subscription type: active, inactive, trial, etc.
  final DateTime createdAt;
  final DateTime? expiryDate;
  final DateTime? lastLogin;

  WebUserModel({
    required this.id,
    required this.title,
    required this.macAddress,
    required this.username,
    this.email,
    this.password,
    this.isProtected = false,
    required this.dnsId,
    this.deviceManager,
    this.subscriptionType,
    DateTime? createdAt,
    this.expiryDate,
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
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      macAddress: json['mac_address'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      password: json['password'],
      isProtected: json['is_protected'] ?? false,
      dnsId: json['dns_id'] ?? '',
      deviceManager: json['device_key'],
      subscriptionType: json['subscription_type'],
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      expiryDate: _parseDate(json['expiry_date']),
      lastLogin: _parseDate(json['last_login']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'mac_address': macAddress,
      'username': username,
      'email': email,
      'password': password,
      'is_protected': isProtected,
      'dns_id': dnsId,
      'device_key': deviceManager,
      'subscription_type': subscriptionType,
      'created_at': createdAt.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  WebUserModel copyWith({
    String? id,
    String? title,
    String? macAddress,
    String? username,
    String? email,
    String? password,
    bool? isProtected,
    String? dnsId,
    String? deviceManager,
    String? subscriptionType,
    DateTime? createdAt,
    DateTime? expiryDate,
    DateTime? lastLogin,
  }) {
    return WebUserModel(
      id: id ?? this.id,
      title: title ?? this.title,
      macAddress: macAddress ?? this.macAddress,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      isProtected: isProtected ?? this.isProtected,
      dnsId: dnsId ?? this.dnsId,
      deviceManager: deviceManager ?? this.deviceManager,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
