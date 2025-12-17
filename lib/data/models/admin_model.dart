class AdminModel {
  final String id;
  final String username;
  final String password;
  final String panelName;
  final String brandName;
  final String contactUrl;
  final String loginFooterUrl;
  final String loginFooterText;
  final String? logoImagePath;

  AdminModel({
    required this.id,
    required this.username,
    required this.password,
    required this.panelName,
    required this.brandName,
    required this.contactUrl,
    required this.loginFooterUrl,
    required this.loginFooterText,
    this.logoImagePath,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      panelName: json['panel_name'] ?? '',
      brandName: json['brand_name'] ?? '',
      contactUrl: json['contact_url'] ?? '',
      loginFooterUrl: json['login_footer_url'] ?? '',
      loginFooterText: json['login_footer_text'] ?? '',
      logoImagePath: json['logo_image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'panel_name': panelName,
      'brand_name': brandName,
      'contact_url': contactUrl,
      'login_footer_url': loginFooterUrl,
      'login_footer_text': loginFooterText,
      'logo_image_path': logoImagePath,
    };
  }

  AdminModel copyWith({
    String? id,
    String? username,
    String? password,
    String? panelName,
    String? brandName,
    String? contactUrl,
    String? loginFooterUrl,
    String? loginFooterText,
    String? logoImagePath,
  }) {
    return AdminModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      panelName: panelName ?? this.panelName,
      brandName: brandName ?? this.brandName,
      contactUrl: contactUrl ?? this.contactUrl,
      loginFooterUrl: loginFooterUrl ?? this.loginFooterUrl,
      loginFooterText: loginFooterText ?? this.loginFooterText,
      logoImagePath: logoImagePath ?? this.logoImagePath,
    );
  }
}
