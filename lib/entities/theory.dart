class Theory {
  final String id;
  final String? title;
  final String? content;
  final String? example;
  final String? audio;
  final String? translation;
  final String? phraseText;
  final String? term;
  final String? image;
  final String? ipa;
  final String? partOfSpeech;
  final int displayOrder;
  final String unitId;
  final String typeTheory; //grammar,flashcard,phrase

  Theory({
    required this.id,
    this.title,
    this.content,
    this.example,
    this.audio,
    this.translation,
    this.phraseText,
    this.term,
    this.image,
    this.ipa,
    this.partOfSpeech,
    required this.displayOrder,
    required this.unitId,
    required this.typeTheory,
  });

  factory Theory.fromJson(Map<String, dynamic> json) {
    return Theory(
      id: json['_id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String?,
      example: json['example'] as String?,
      audio: json['audio'] as String?,
      translation: json['translation'] as String?,
      phraseText: json['phraseText'] as String?,
      term: json['term'] as String?,
      image: json['image'] as String?,
      ipa: json['ipa'] as String?,
      partOfSpeech: json['partOfSpeech'] as String?,
      displayOrder: json['displayOrder'] as int,
      unitId: json['unitId'] as String,
      typeTheory: json['typeTheory'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'example': example,
      'audio': audio,
      'translation': translation,
      'phraseText': phraseText,
      'term': term,
      'image': image,
      'ipa': ipa,
      'partOfSpeech': partOfSpeech,
      'displayOrder': displayOrder,
      'unitId': unitId,
      'typeTheory': typeTheory,
    };
  }
}
