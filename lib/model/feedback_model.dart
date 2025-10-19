import 'user_model.dart';

class FeedbackModel {
  final int? id;
  final UserModel? student;
  final int? courseId;
  final String comment;

  FeedbackModel({
    this.id,
    this.student,
    this.courseId,
    required this.comment,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      student: json['student'] != null
          ? UserModel.fromJson(json['student'])
          : null,
      courseId: json['courseId'],
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': student?.toJson(),
      'courseId': courseId,
      'comment': comment,
    };
  }

  FeedbackModel copyWith({
    int? id,
    UserModel? student,
    int? courseId,
    String? comment,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      student: student ?? this.student,
      courseId: courseId ?? this.courseId,
      comment: comment ?? this.comment,
    );
  }
}

