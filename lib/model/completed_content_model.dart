class CompletedContent {
  final int userId;
  final int contentId;
  final double progressPercentage;
  final bool completed;

  CompletedContent({
    required this.userId,
    required this.contentId,
    required this.progressPercentage,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'contentId': contentId,
      'progressPercentage': progressPercentage,
      'completed': completed,
    };
  }

  factory CompletedContent.fromJson(Map<String, dynamic> json) {
    return CompletedContent(
      userId: json['userId'] ?? 0,
      contentId: json['contentId'] ?? 0,
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      completed: json['completed'] ?? false,
    );
  }

  @override
  String toString() {
    return 'CompletedContentDTO(userId: $userId, contentId: $contentId, progressPercentage: $progressPercentage, completed: $completed)';
  }
}

