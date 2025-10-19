import 'feedback_model.dart';
import 'section_model.dart';
import 'user_model.dart';

class CursoModel {
  final int? id;
  final String name;
  final String description;
  final String? creationDate;
  final String? lastUpdateDate;
  final String? imageUrl;
  final List<UserModel> instructors;
  final List<FeedbackModel> feedBacks;
  final List<SectionModel> sections;

  CursoModel({
    this.id,
    required this.name,
    required this.description,
    this.creationDate,
    this.lastUpdateDate,
    this.imageUrl,
    this.instructors = const [],
    this.feedBacks = const [],
    this.sections = const [],
  });

  factory CursoModel.fromJson(Map<String, dynamic> json) {
    return CursoModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      creationDate: json['creationDate'],
      lastUpdateDate: json['lastUpdateDate'],
      imageUrl: json['imageUrl'],
      instructors: (json['instructors'] as List<dynamic>?)
          ?.map((user) => UserModel.fromJson(user))
          .toList() ?? [],
      feedBacks: (json['feedBacks'] as List<dynamic>?)
          ?.map((feedback) => FeedbackModel.fromJson(feedback))
          .toList() ?? [],
      sections: (json['sections'] as List<dynamic>?)
          ?.map((section) => SectionModel.fromJson(section))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creationDate': creationDate,
      'lastUpdateDate': lastUpdateDate,
      'imageUrl': imageUrl,
      'instructors': instructors.map((user) => user.toJson()).toList(),
      'feedBacks': feedBacks.map((feedback) => feedback.toJson()).toList(),
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }

  CursoModel copyWith({
    int? id,
    String? name,
    String? description,
    String? creationDate,
    String? lastUpdateDate,
    String? imageUrl,
    List<UserModel>? instructors,
    List<FeedbackModel>? feedBacks,
    List<SectionModel>? sections,
  }) {
    return CursoModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creationDate: creationDate ?? this.creationDate,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      imageUrl: imageUrl ?? this.imageUrl,
      instructors: instructors ?? this.instructors,
      feedBacks: feedBacks ?? this.feedBacks,
      sections: sections ?? this.sections,
    );
  }
}
