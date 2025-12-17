class ActivationCodeModel {
  final String id;
  final String title; // M3U Extractor
  final String code;
  final String dnsId;
  final String username;
  final String password;
  final String userStatus; // 'active', 'inactive', 'trial'
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
    this.isUsed = false,
    DateTime? createdAt,
    this.usedAt,
    this.usedByUserId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json) {
    return ActivationCodeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      dnsId: json['dns_id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      userStatus: json['user_status'] ?? 'inactive',
      isUsed: json['is_used'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'])
          : null,
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
      isUsed: isUsed ?? this.isUsed,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      usedByUserId: usedByUserId ?? this.usedByUserId,
    );
  }
}
