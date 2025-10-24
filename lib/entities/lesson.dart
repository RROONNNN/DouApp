class Lesson {
  final String id;
  final String unitId;
  final String title;
  final String objectives;
  final int displayOrder;
  final String thumbnail;
  final DateTime updatedAt;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.unitId,
    required this.title,
    required this.objectives,
    required this.displayOrder,
    required this.thumbnail,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'] as String,
      unitId: json['unitId'] as String,
      title: json['title'] as String,
      objectives: json['objectives'] as String,
      displayOrder: json['displayOrder'] as int,
      thumbnail: json['thumbnail'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'unitId': unitId,
      'title': title,
      'objectives': objectives,
      'displayOrder': displayOrder,
      'thumbnail': thumbnail,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
