import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? avatarImage;
  final String fullName;
  final bool isActive;
  final int streakCount;
  final DateTime lastActiveAt;
  final int experiencePoint;
  final int heartCount;
  final DateTime updatedAt;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.email,
    this.avatarImage,
    required this.fullName,
    required this.isActive,
    required this.streakCount,
    required this.lastActiveAt,
    required this.experiencePoint,
    required this.heartCount,
    required this.updatedAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      email: json['email'] as String,
      avatarImage: json['avatarImage'] as String?,
      fullName: json['fullName'] as String,
      isActive: json['isActive'] as bool,
      streakCount: json['streakCount'] as int,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      experiencePoint: json['experiencePoint'] as int,
      heartCount: json['heartCount'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'avatarImage': avatarImage,
      'fullName': fullName,
      'isActive': isActive,
      'streakCount': streakCount,
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'experiencePoint': experiencePoint,
      'heartCount': heartCount,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    avatarImage,
    fullName,
    isActive,
    streakCount,
    lastActiveAt,
    experiencePoint,
    heartCount,
    updatedAt,
    createdAt,
  ];
}
