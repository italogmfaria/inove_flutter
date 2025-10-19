import 'content_model.dart';

class SectionModel {
  final int? id;
  final String title;
  final String description;
  final int courseId;
  final List<ContentModel> contents;
  final bool? isOpen;

  SectionModel({
    this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.contents = const [],
    this.isOpen,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: json['courseId'] ?? 0,
      contents: (json['contents'] as List<dynamic>?)
          ?.map((content) => ContentModel.fromJson(content))
          .toList() ?? [],
      isOpen: json['isOpen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'contents': contents.map((content) => content.toJson()).toList(),
      'isOpen': isOpen,
    };
  }

  SectionModel copyWith({
    int? id,
    String? title,
    String? description,
    int? courseId,
    List<ContentModel>? contents,
    bool? isOpen,
  }) {
    return SectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      contents: contents ?? this.contents,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

