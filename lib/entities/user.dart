import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String role;
  final String email;
  final String fullName;
  final bool isActive;
  final int streakCount;
  final DateTime lastActiveAt;
  final DateTime updatedAt;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.role,
    required this.email,
    required this.fullName,
    required this.isActive,
    required this.streakCount,
    required this.lastActiveAt,
    required this.updatedAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      isActive: json['isActive'] as bool,
      streakCount: json['streakCount'] as int,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'role': role,
      'email': email,
      'fullName': fullName,
      'isActive': isActive,
      'streakCount': streakCount,
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    role,
    email,
    fullName,
    isActive,
    streakCount,
    lastActiveAt,
    updatedAt,
    createdAt,
  ];
}
