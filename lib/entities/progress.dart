import 'package:equatable/equatable.dart';

class Progress extends Equatable {
  final String id;
  final String user;
  final String lesson;
  final String unit;
  final String course;
  final DateTime updatedAt;
  final DateTime createdAt;

  const Progress({
    required this.id,
    required this.user,
    required this.lesson,
    required this.unit,
    required this.course,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['_id'] as String,
      user: json['user'] as String,
      lesson: json['lesson'] as String,
      unit: json['unit'] as String,
      course: json['course'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'lesson': lesson,
      'unit': unit,
      'course': course,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [
    id,
    user,
    lesson,
    unit,
    course,
    updatedAt,
    createdAt,
  ];
}
