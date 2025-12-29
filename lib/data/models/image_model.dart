class ImageModel {
  final String id;
  final String name;
  final String url;
  final String storagePath;
  final int sizeInBytes;
  final DateTime uploadedAt;

  ImageModel({
    required this.id,
    required this.name,
    required this.url,
    required this.storagePath,
    required this.sizeInBytes,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      storagePath: json['storage_path'] ?? '',
      sizeInBytes: json['size_in_bytes'] ?? 0,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'storage_path': storagePath,
      'size_in_bytes': sizeInBytes,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  ImageModel copyWith({
    String? id,
    String? name,
    String? url,
    String? storagePath,
    int? sizeInBytes,
    DateTime? uploadedAt,
  }) {
    return ImageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
