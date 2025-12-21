class Course {
  final String id;
  final String description;
  final int displayOrder;
  final String thumbnail;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLocked;

  const Course({
    required this.id,
    required this.description,
    required this.displayOrder,
    required this.thumbnail,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.isLocked,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Course(
      id: (json['_id'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      displayOrder: parseInt(json['displayOrder']),
      thumbnail: (json['thumbnail'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      isLocked: (json['isLocked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'description': description,
    'displayOrder': displayOrder,
    'thumbnail': thumbnail,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isLocked': isLocked,
  };

  Course copyWith({
    String? id,
    String? description,
    int? displayOrder,
    String? thumbnail,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      thumbnail: thumbnail ?? this.thumbnail,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  String toString() {
    return 'Course(id: $id, description: $description, displayOrder: $displayOrder, thumbnail: $thumbnail, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
