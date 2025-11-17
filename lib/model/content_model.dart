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
    ContentType type;

    if (json['contentType'] != null) {
      type = ContentType.fromJson(json['contentType']);
    } else {
      final fileName = (json['fileName'] ?? '').toString().toLowerCase();
      if (fileName.endsWith('.pdf')) {
        type = ContentType.PDF;
      } else if (fileName.endsWith('.mp4') ||
                 fileName.endsWith('.avi') ||
                 fileName.endsWith('.mov') ||
                 fileName.endsWith('.wmv') ||
                 fileName.endsWith('.webm')) {
        type = ContentType.VIDEO;
      } else {
        // Verificar pela URL também
        final fileUrl = (json['fileUrl'] ?? '').toString().toLowerCase();
        if (fileUrl.contains('.pdf')) {
          type = ContentType.PDF;
        } else {
          type = ContentType.VIDEO;
        }
      }
    }

    String fileUrlFinal = json['fileUrl'] ?? '';

    if (fileUrlFinal.isEmpty) {
      fileUrlFinal = json['fileName'] ?? '';
    }

    if (fileUrlFinal.isNotEmpty && !fileUrlFinal.startsWith('http')) {
      const s3BucketUrl = 'https://inove-bucket-streaming.s3.amazonaws.com/';
      fileUrlFinal = s3BucketUrl + fileUrlFinal;
    }

    return ContentModel(
      id: json['id'],
      description: json['description'] ?? '',
      title: json['title'] ?? '',
      contentType: type,
      fileUrl: fileUrlFinal,
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
