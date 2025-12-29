import 'package:cloud_firestore/cloud_firestore.dart';

class ActivationCodeModel {
  final String id;
  final String title; // M3U Extractor
  final String code;
  final String dnsId;
  final String username;
  final String password;
  final String userStatus; // 'active', 'inactive', 'trial'
  final String? email; // Optional email
  final bool isUsed;
  final DateTime createdAt;
  final DateTime? usedAt;
  final String? usedByUserId;

  ActivationCodeModel({
    required this.id,
    this.title = '',
    required this.code,
    required this.dnsId,
    this.username = '',
    this.password = '',
    required this.userStatus,
    this.email,
    this.isUsed = false,
    DateTime? createdAt,
    this.usedAt,
    this.usedByUserId,
  }) : createdAt = createdAt ?? DateTime.now();

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json) {
    return ActivationCodeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      dnsId: json['dns_id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      userStatus: json['user_status'] ?? 'inactive',
      email: json['email'],
      isUsed: json['is_used'] ?? false,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      usedAt: _parseDate(json['used_at']),
      usedByUserId: json['used_by_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'dns_id': dnsId,
      'username': username,
      'password': password,
      'user_status': userStatus,
      'email': email,
      'is_used': isUsed,
      'created_at': createdAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'used_by_user_id': usedByUserId,
    };
  }

  ActivationCodeModel copyWith({
    String? id,
    String? title,
    String? code,
    String? dnsId,
    String? username,
    String? password,
    String? userStatus,
    String? email,
    bool? isUsed,
    DateTime? createdAt,
    DateTime? usedAt,
    String? usedByUserId,
  }) {
    return ActivationCodeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      dnsId: dnsId ?? this.dnsId,
      username: username ?? this.username,
      password: password ?? this.password,
      userStatus: userStatus ?? this.userStatus,
      email: email ?? this.email,
      isUsed: isUsed ?? this.isUsed,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      usedByUserId: usedByUserId ?? this.usedByUserId,
    );
  }
}
