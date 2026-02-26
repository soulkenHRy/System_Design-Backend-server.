import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AIJudge {
  static const String ollamaUrl = 'http://localhost:11434/api/generate';
  static const String model = 'llama3.1:8b';

  /// AI Judge with multiple evaluation methods
  static Future<Map<String, dynamic>> judgeAnswer({
    required String question,
    required String userAnswer,
    String? expectedConcepts,
  }) async {
    try {
      // Use improved rule-based judge directly
      final result = _improvedRuleBasedJudge(question, userAnswer);
      return result;
    } catch (e) {
      final fallbackResult = _simpleRuleBasedJudge(question, userAnswer);
      return fallbackResult;
    }
  }

  /// Try the embedded Python AI judge (not available on web)
  static Future<Map<String, dynamic>?> _tryEmbeddedAIJudge(
    String question,
    String userAnswer,
  ) async {
    // Python process execution is not available on web
    if (kIsWeb) return null;
    try {
      // Create input data (no temp file - use stdin instead)
      final tempInput = {'question': question, 'answer': userAnswer};
      final inputJson = json.encode(tempInput);

      // On non-web platforms, this would use dart:io Process
      // but since we compile for web, we skip this entirely
      return null;
    } catch (e) {
      // Silent failure, will fall back to other methods
    }
    return null;
  }

  /// Try Ollama-based judgment
  static Future<Map<String, dynamic>> _tryOllamaJudge(
    String question,
    String userAnswer,
    String? expectedConcepts,
  ) async {
    try {
      final prompt = _buildJudgePrompt(question, userAnswer, expectedConcepts);

      final response = await http.post(
        Uri.parse(ollamaUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': model,
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.7, 'top_p': 0.9, 'max_tokens': 500},
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['response'] ?? '';
        final result = _parseJudgeResponse(aiResponse);
        result['method'] = 'ollama';
        return result;
      }
    } catch (e) {
      // Silent failure, will fall back to rule-based judge
    }
    return _simpleRuleBasedJudge(question, userAnswer);
  }

  /// Build a focused prompt for the AI judge
  static String _buildJudgePrompt(
    String question,
    String userAnswer,
    String? expectedConcepts,
  ) {
    return '''
You are a friendly but knowledgeable system design judge. Your job is to evaluate the user's answer and provide constructive feedback.

QUESTION: $question

USER'S ANSWER: $userAnswer

${expectedConcepts != null ? 'KEY CONCEPTS TO LOOK FOR: $expectedConcepts' : ''}

Please evaluate this answer and respond in EXACTLY this format:

SCORE: [0-100]
FEEDBACK: [2-3 sentences of constructive feedback]
STRENGTHS: [What they did well]
IMPROVEMENTS: [What they could improve]
ENCOURAGEMENT: [A motivating closing comment]

Keep it simple, encouraging, and focused on learning. Be like a helpful mentor, not a harsh critic.
''';
  }

  /// Parse the AI response into structured feedback
  static Map<String, dynamic> _parseJudgeResponse(String aiResponse) {
    try {
      final lines = aiResponse.split('\n');
      int score = 75; // Default score
      String feedback = "Good attempt!";
      String strengths = "Shows understanding of the topic";
      String improvements = "Could provide more details";
      String encouragement = "Keep practicing!";

      for (String line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('SCORE:')) {
          final scoreText = trimmed.replaceFirst('SCORE:', '').trim();
          score =
              int.tryParse(scoreText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 75;
        } else if (trimmed.startsWith('FEEDBACK:')) {
          feedback = trimmed.replaceFirst('FEEDBACK:', '').trim();
        } else if (trimmed.startsWith('STRENGTHS:')) {
          strengths = trimmed.replaceFirst('STRENGTHS:', '').trim();
        } else if (trimmed.startsWith('IMPROVEMENTS:')) {
          improvements = trimmed.replaceFirst('IMPROVEMENTS:', '').trim();
        } else if (trimmed.startsWith('ENCOURAGEMENT:')) {
          encouragement = trimmed.replaceFirst('ENCOURAGEMENT:', '').trim();
        }
      }

      return {
        'score': score.clamp(0, 100),
        'feedback': feedback.isNotEmpty ? feedback : "Good attempt!",
        'strengths': strengths.isNotEmpty ? strengths : "Shows understanding",
        'improvements':
            improvements.isNotEmpty ? improvements : "Keep practicing",
        'encouragement':
            encouragement.isNotEmpty ? encouragement : "You're doing great!",
        'isAiGenerated': true,
      };
    } catch (e) {
      return _fallbackJudgment('');
    }
  }

  /// Simple rule-based judge as final fallback
  static Map<String, dynamic> _simpleRuleBasedJudge(
    String question,
    String userAnswer,
  ) {
    final answer = userAnswer.toLowerCase();
    int score = 5; // Much lower base score - was 30
    List<String> foundConcepts = [];

    // Check for key system design concepts
    final concepts = {
      'database': 8,
      'cache': 8,
      'caching': 8,
      'load balancer': 10,
      'load balancing': 8,
      'scalability': 10,
      'scaling': 8,
      'microservice': 9,
      'api': 6,
      'rest': 5,
      'websocket': 7,
      'message queue': 9,
      'sharding': 9,
      'replication': 8,
      'monitoring': 6,
      'security': 6,
      'authentication': 6,
      'cdn': 8,
      'redis': 7,
      'mongodb': 5,
      'postgres': 5,
      'nginx': 5,
    };

    for (String concept in concepts.keys) {
      if (answer.contains(concept)) {
        score += concepts[concept]!;
        foundConcepts.add(concept);
      }
    }

    // Length bonus
    if (userAnswer.length > 200) {
      score += 15;
    } else if (userAnswer.length > 100) {
      score += 10;
    } else if (userAnswer.length > 50) {
      score += 5;
    }

    // Structure bonus for numbered lists
    if (RegExp(r'\d+\.').hasMatch(userAnswer)) {
      score += 10;
    }

    score = score.clamp(10, 100);

    String feedback;
    String strengths;
    String improvements;
    String encouragement;

    if (score >= 85) {
      feedback =
          "Excellent system design! Your answer shows comprehensive understanding.";
      strengths =
          "Great coverage of system design concepts including ${foundConcepts.take(3).join(', ')}.";
      improvements = "Consider adding more specific implementation details.";
      encouragement = "Outstanding work! You're mastering system design.";
    } else if (score >= 70) {
      feedback =
          "Good system design approach! Your answer covers important concepts.";
      strengths =
          "Good mention of key concepts: ${foundConcepts.take(3).join(', ')}.";
      improvements = "Add more details about scalability and performance.";
      encouragement =
          "You're on the right track! Keep building on these concepts.";
    } else if (score >= 50) {
      feedback = "Your answer shows basic understanding but needs more depth.";
      strengths = "You've included some relevant concepts.";
      improvements =
          "Add more architectural components like databases, caching, and load balancing.";
      encouragement =
          "Good start! Study more system design patterns to improve.";
    } else {
      feedback =
          "Your answer needs significant improvement. Focus on system design fundamentals.";
      strengths = "You attempted to answer the question.";
      improvements =
          "Study distributed systems, databases, caching, and scalability concepts.";
      encouragement = "Don't give up! System design takes practice to master.";
    }

    return {
      'score': score,
      'feedback': feedback,
      'strengths': strengths,
      'improvements': improvements,
      'encouragement': encouragement,
      'isAiGenerated': false,
      'method': 'rule_based',
    };
  }

  /// Fallback when AI is not available (kept for compatibility)
  static Map<String, dynamic> _fallbackJudgment(String userAnswer) {
    return _simpleRuleBasedJudge('System Design Question', userAnswer);
  }

  /// Check if Ollama is running and accessible
  static Future<bool> isOllamaAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:11434/api/tags'))
          .timeout(Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available models from Ollama
  static Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:11434/api/tags'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['models'] as List?;
        return models?.map((m) => m['name'] as String).toList() ?? [];
      }
    } catch (e) {
      // Silent failure, return empty list
    }
    return [];
  }

  /// Build strengths from AI response
  static String _buildStrengths(Map<String, dynamic> response) {
    final keywordsText = response['keywords_found'] ?? '';
    final score = response['score'] ?? 50;

    if (keywordsText.isNotEmpty && keywordsText != '') {
      return 'Good use of key concepts: $keywordsText. Shows solid understanding of system design principles.';
    } else if (score >= 40) {
      return 'Shows basic understanding of the problem. Provides a reasonable approach to the system design challenge.';
    } else {
      return 'Demonstrates effort in approaching the system design problem.';
    }
  }

  /// Build improvements from AI response
  static String _buildImprovements(Map<String, dynamic> response) {
    final suggestions = List<String>.from(response['suggestions'] ?? []);
    final score = response['score'] ?? 50;

    if (suggestions.isNotEmpty) {
      return suggestions.first;
    } else if (score < 60) {
      return 'Consider adding more architectural details like scalability, caching, and load balancing strategies.';
    } else if (score < 80) {
      return 'Try to include more specific technologies and explain the reasoning behind your architectural choices.';
    } else {
      return 'Consider adding monitoring, security, and fault tolerance aspects to make the design more comprehensive.';
    }
  }

  /// Build encouragement from AI response
  static String _buildEncouragement(Map<String, dynamic> response) {
    final score = response['score'] ?? 50;

    if (score >= 85) {
      return 'Excellent work! You have a strong grasp of system design concepts. Keep pushing your boundaries!';
    } else if (score >= 70) {
      return 'Great job! You\'re developing solid system design skills. Keep practicing with more complex scenarios!';
    } else if (score >= 50) {
      return 'Good effort! You\'re on the right track. Keep learning and practicing to strengthen your architecture skills!';
    } else {
      return 'Keep going! System design takes practice. Every attempt makes you better. You\'ve got this!';
    }
  }

  static Map<String, dynamic> _improvedRuleBasedJudge(
    String question,
    String userAnswer,
  ) {
    final answer = userAnswer.toLowerCase();

    // Start with very low base score
    int score = 2;
    String feedback = "";

    // 1. Check for empty or very short answers
    if (userAnswer.trim().isEmpty) {
      return {
        'score': 0,
        'feedback': '❌ Empty answer provided',
        'strengths': '',
        'improvements': '',
        'encouragement': '',
        'method': 'improved_rule_based',
        'keywords_found': '',
        'breakdown': <String, dynamic>{},
      };
    }

    if (userAnswer.length < 10) {
      return {
        'score': score,
        'feedback':
            '❌ Answer too short - lacks detail\n💡 Consider discussing trade-offs\n💡 Include monitoring and observability',
        'strengths': '',
        'improvements': '',
        'encouragement': '',
        'method': 'improved_rule_based',
        'keywords_found': '',
        'breakdown': <String, dynamic>{},
      };
    }

    // 2. Check for contradictions (heavy penalty)
    final contradictions = [
      'microservice.*monolith',
      'stateless.*state',
      'horizontal.*single.*server',
      'distributed.*centralized',
    ];

    bool hasContradiction = false;
    for (String pattern in contradictions) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(answer)) {
        hasContradiction = true;
        score = (score - 15).clamp(0, 100);
        feedback += '❌ Logical contradictions detected\n';
        break;
      }
    }

    // 3. Check for quality indicators (good bonus)
    final qualityWords = [
      'trade-off',
      'consider',
      'because',
      'constraint',
      'cost',
      'maintenance',
    ];
    bool hasQuality = false;
    for (String word in qualityWords) {
      if (answer.contains(word)) {
        hasQuality = true;
        score += 15;
        break;
      }
    }

    // 4. Check for technical concepts (moderate bonus)
    final concepts = {
      'database': 4,
      'cache': 4,
      'api': 3,
      'server': 2,
      'load balancer': 6,
      'microservice': 5,
      'scaling': 4,
      'monitor': 3,
    };

    String foundConceptsText = "";
    for (String concept in concepts.keys) {
      if (answer.contains(concept)) {
        score += concepts[concept]!;
        if (foundConceptsText.isNotEmpty) foundConceptsText += ", ";
        foundConceptsText += concept;
      }
    }

    // 5. Length bonus for detailed answers
    if (userAnswer.length > 100) {
      score += 8;
    } else if (userAnswer.length > 50) {
      score += 4;
    }

    // 6. Generate feedback prefix
    String prefix;
    if (score >= 60) {
      prefix = '👍 Good design foundation';
    } else if (score >= 30) {
      prefix = '⚠️ Basic understanding but needs more depth';
    } else {
      prefix = '❌ Significant design issues detected';
    }

    feedback = prefix + '\n' + feedback;

    if (hasQuality) {
      feedback += '✅ Shows thoughtful consideration\n';
    }

    if (!answer.contains('trade-off') && !answer.contains('consider')) {
      feedback += '💡 Consider discussing trade-offs\n';
    }

    if (!answer.contains('monitor') && !answer.contains('observ')) {
      feedback += '💡 Include monitoring and observability\n';
    }

    // Remove trailing newline
    feedback = feedback.trimRight();

    // Cap score at 100
    score = score.clamp(0, 100);

    return {
      'score': score,
      'feedback': feedback,
      'strengths': hasQuality ? 'Shows thoughtful consideration' : '',
      'improvements': '',
      'encouragement':
          score > 20 ? 'Keep improving!' : 'Study system design fundamentals',
      'method': 'improved_rule_based',
      'keywords_found': foundConceptsText,
      'breakdown': <String, dynamic>{
        'contradictions': hasContradiction,
        'quality_indicators': hasQuality,
      },
    };
  }
}
