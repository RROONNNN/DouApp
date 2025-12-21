import 'dart:math';

class Lesson {
  final String id;
  final String unitId;
  final String? title;
  final String? objectives;
  final int displayOrder;
  final String? thumbnail;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int experiencePoint;

  Lesson({
    required this.id,
    required this.unitId,
    required this.title,
    required this.objectives,
    required this.displayOrder,
    required this.thumbnail,
    this.updatedAt,
    this.createdAt,
    required this.experiencePoint,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    try {
      final lesson = Lesson(
        id: json['_id'] as String,
        unitId: json['unitId'] as String,
        title: json['title'] as String?,
        objectives: json['objectives'] as String?,
        displayOrder: json['displayOrder'] as int,
        thumbnail: json['thumbnail'] as String,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        experiencePoint: json['experiencePoint'] as int,
      );
      return lesson;
    } catch (e) {
      print('Error Lesson.fromJson: $e');
      print('json: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'unitId': unitId,
      'title': title,
      'objectives': objectives,
      'displayOrder': displayOrder,
      'thumbnail': thumbnail,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'experiencePoint': experiencePoint,
    };
  }
}
