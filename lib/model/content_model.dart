enum ContentType {
  VIDEO,
  PDF;

  String toJson() {
    return name;
  }

  static ContentType fromJson(String value) {
    return ContentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContentType.VIDEO,
    );
  }
}

class ContentModel {
  final int? id;
  final String description;
  final String title;
  final ContentType contentType;
  final String fileUrl;
  final String fileName;
  final int sectionId;

  ContentModel({
    this.id,
    required this.description,
    required this.title,
    required this.contentType,
    required this.fileUrl,
    required this.fileName,
    required this.sectionId,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      description: json['description'] ?? '',
      title: json['title'] ?? '',
      contentType: ContentType.fromJson(json['contentType'] ?? 'VIDEO'),
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'] ?? '',
      sectionId: json['sectionId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'title': title,
      'contentType': contentType.toJson(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'sectionId': sectionId,
    };
  }

  ContentModel copyWith({
    int? id,
    String? description,
    String? title,
    ContentType? contentType,
    String? fileUrl,
    String? fileName,
    int? sectionId,
  }) {
    return ContentModel(
      id: id ?? this.id,
      description: description ?? this.description,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      sectionId: sectionId ?? this.sectionId,
    );
  }
}

