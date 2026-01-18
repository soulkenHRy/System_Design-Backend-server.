class EvaluationResult {
  final int score; // Total score (0-100)
  final int canvasScore; // Canvas design score (0-50)
  final int notesScore; // Notes/description score (0-50)
  final String feedback;
  final bool isSystemDesignRelated;
  final List<String>? concepts;
  final String? category;

  EvaluationResult({
    required this.score,
    this.canvasScore = 0, // Default 0 for backwards compatibility
    this.notesScore = 0, // Default 0 for backwards compatibility
    required this.feedback,
    required this.isSystemDesignRelated,
    this.concepts,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'canvasScore': canvasScore,
      'notesScore': notesScore,
      'feedback': feedback,
      'isSystemDesignRelated': isSystemDesignRelated,
      'concepts': concepts,
      'category': category,
      'keywords_found': concepts, // For compatibility
    };
  }

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      score: json['score'] ?? 0,
      canvasScore: json['canvasScore'] ?? 0,
      notesScore: json['notesScore'] ?? 0,
      feedback: json['feedback'] ?? '',
      isSystemDesignRelated: json['isSystemDesignRelated'] ?? true,
      concepts:
          json['concepts'] != null ? List<String>.from(json['concepts']) : null,
      category: json['category'],
    );
  }
}
