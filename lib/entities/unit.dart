import 'package:duo_app/entities/lesson.dart';

class Unit {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int displayOrder;
  final String thumbnail;
  final DateTime updatedAt;
  final DateTime createdAt;
  final List<Lesson> lessons;

  Unit({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.displayOrder,
    required this.thumbnail,
    required this.updatedAt,
    required this.createdAt,
    required this.lessons,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['_id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      displayOrder: json['displayOrder'] as int,
      thumbnail: json['thumbnail'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((lessonJson) => Lesson.fromJson(lessonJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'displayOrder': displayOrder,
      'thumbnail': thumbnail,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
