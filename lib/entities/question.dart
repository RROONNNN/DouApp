class MatchingItem {
  final String value;
  final String pairId;

  MatchingItem({required this.value, required this.pairId});

  factory MatchingItem.fromJson(Map<String, dynamic> json) {
    return MatchingItem(
      value: json['value'] as String,
      pairId: json['pairId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'pairId': pairId};
  }
}

enum TypeQuestion { multipleChoice, matching, gap, ordering }

extension TypeQuestionExtension on TypeQuestion {
  static TypeQuestion fromString(String value) {
    switch (value) {
      case 'multiple_choice':
        return TypeQuestion.multipleChoice;
      case 'matching':
        return TypeQuestion.matching;
      case 'gap':
        return TypeQuestion.gap;
      case 'ordering':
        return TypeQuestion.ordering;
      default:
        throw ArgumentError('Unknown TypeQuestion value: $value');
    }
  }

  String toShortString() {
    switch (this) {
      case TypeQuestion.multipleChoice:
        return 'multiple_choice';
      case TypeQuestion.matching:
        return 'matching';
      case TypeQuestion.gap:
        return 'gap';
      case TypeQuestion.ordering:
        return 'ordering';
    }
  }
}

class Question {
  final String id;
  final String lessonId;
  final String? correctAnswer;
  final List<String>? answers;
  final String? exactFragmentText;
  final List<String>? fragmentText;
  final String? mediaUrl;
  final int displayOrder;
  final String? title;
  final TypeQuestion typeQuestion;
  final DateTime updatedAt;
  final DateTime createdAt;
  final List<MatchingItem>? leftText;
  final List<MatchingItem>? rightText;

  Question({
    required this.id,
    required this.lessonId,
    this.correctAnswer,
    this.answers,
    this.mediaUrl,
    this.title,
    required this.displayOrder,
    required this.typeQuestion,
    required this.updatedAt,
    required this.createdAt,
    required this.exactFragmentText,
    required this.fragmentText,
    this.leftText,
    this.rightText,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] as String,
      lessonId: json['lessonId'] as String,
      correctAnswer: json['correctAnswer'] as String?,
      title: json['title'] as String?,
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mediaUrl: json['mediaUrl'] as String?,
      displayOrder: json['displayOrder'] as int,
      typeQuestion: TypeQuestionExtension.fromString(
        json['typeQuestion'] as String,
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      exactFragmentText: json['exactFragmentText'] as String?,
      fragmentText: (json['fragmentText'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      leftText: (json['leftText'] as List<dynamic>?)
          ?.map((e) => MatchingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rightText: (json['rightText'] as List<dynamic>?)
          ?.map((e) => MatchingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'lessonId': lessonId,
      'correctAnswer': correctAnswer,
      'answers': answers,
      'title': title,
      'mediaUrl': mediaUrl,
      'displayOrder': displayOrder,
      'typeQuestion': typeQuestion.toShortString(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'exactFragmentText': exactFragmentText,
      'fragmentText': fragmentText,
      'leftText': leftText?.map((e) => e.toJson()).toList(),
      'rightText': rightText?.map((e) => e.toJson()).toList(),
    };
  }
}
