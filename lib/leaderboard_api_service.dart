import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Configuration for the leaderboard API
class LeaderboardApiConfig {
  /// The base URL for the leaderboard API backend
  ///
  /// IMPORTANT: Update this URL after deploying your backend to Railway!
  /// Example: 'https://quiz-game-backend-production.up.railway.app'
  ///
  /// For local testing, use: 'http://localhost:3000' or 'http://10.0.2.2:3000' for Android emulator
  static const String baseUrl =
      'https://patient-betteann-system-design-0def3375.koyeb.app';

  /// Timeout duration for API requests
  static const Duration timeout = Duration(seconds: 10);

  /// Whether to use the online leaderboard (set to false to use offline/bot mode)
  static const bool useOnlineLeaderboard = true;
}

/// A user on the leaderboard
class LeaderboardUser {
  final String odId;
  final String username;
  final String country;
  final int totalScore;
  final int systemsDesigned;
  final int averageScore;
  final int rank;
  final List<SystemEvaluation> evaluations;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.odId,
    required this.username,
    required this.country,
    required this.totalScore,
    required this.systemsDesigned,
    required this.averageScore,
    required this.rank,
    this.evaluations = const [],
    this.isCurrentUser = false,
  });

  factory LeaderboardUser.fromJson(
    Map<String, dynamic> json, {
    bool isCurrentUser = false,
  }) {
    return LeaderboardUser(
      odId: json['userId'] ?? '',
      username: json['username'] ?? 'Unknown',
      country: json['country'] ?? 'Unknown',
      totalScore: json['totalScore'] ?? json['score'] ?? 0,
      systemsDesigned: json['systemsDesigned'] ?? 0,
      averageScore: json['averageScore'] ?? 0,
      rank: json['rank'] ?? 0,
      evaluations:
          (json['evaluations'] as List<dynamic>?)
              ?.map((e) => SystemEvaluation.fromJson(e))
              .toList() ??
          [],
      isCurrentUser: isCurrentUser || (json['isCurrentUser'] ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': odId,
    'username': username,
    'country': country,
    'score': totalScore,
    'systemsDesigned': systemsDesigned,
    'averageScore': averageScore,
    'rank': rank,
    'evaluations': evaluations.map((e) => e.toJson()).toList(),
  };
}

/// A system evaluation score
class SystemEvaluation {
  final String systemName;
  final int score;
  final int timestamp;

  SystemEvaluation({
    required this.systemName,
    required this.score,
    required this.timestamp,
  });

  factory SystemEvaluation.fromJson(Map<String, dynamic> json) {
    return SystemEvaluation(
      systemName: json['systemName'] ?? '',
      score: json['score'] ?? 0,
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
    'systemName': systemName,
    'score': score,
    'timestamp': timestamp,
  };
}

/// Result of a leaderboard fetch operation
class LeaderboardResult {
  final List<LeaderboardUser> users;
  final int totalUsers;
  final bool hasMore;
  final int? currentUserRank;
  final bool isOnline;

  LeaderboardResult({
    required this.users,
    required this.totalUsers,
    this.hasMore = false,
    this.currentUserRank,
    this.isOnline = true,
  });
}

/// Service for interacting with the online leaderboard API
class LeaderboardApiService {
  static LeaderboardApiService? _instance;

  LeaderboardApiService._();

  static LeaderboardApiService get instance {
    _instance ??= LeaderboardApiService._();
    return _instance!;
  }

  /// Get or generate a unique user ID for this device
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? odId = prefs.getString('online_leaderboard_user_id');

    if (odId == null) {
      // Generate a new UUID-like ID
      odId = _generateUUID();
      await prefs.setString('online_leaderboard_user_id', odId);
    }

    return odId;
  }

  /// Generate a UUID v4
  String _generateUUID() {
    final random = DateTime.now().millisecondsSinceEpoch;
    const chars = 'abcdef0123456789';
    final buffer = StringBuffer();

    for (int i = 0; i < 32; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        buffer.write('-');
      }
      final charIndex = ((random + i * 7) * 31) % chars.length;
      buffer.write(chars[charIndex]);
    }

    return buffer.toString();
  }

  /// Check if there's an internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      return false;
    }
  }

  /// Register or update a user on the leaderboard
  Future<LeaderboardUser?> registerUser({
    required String username,
    required String country,
  }) async {
    if (!LeaderboardApiConfig.useOnlineLeaderboard) return null;

    try {
      final odId = await getUserId();

      final response = await http
          .post(
            Uri.parse('${LeaderboardApiConfig.baseUrl}/api/users/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': odId,
              'username': username,
              'country': country,
            }),
          )
          .timeout(LeaderboardApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LeaderboardUser.fromJson(data, isCurrentUser: true);
      }

      return null;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  /// Submit a score for a specific system
  Future<bool> submitScore({
    required String systemName,
    required int score,
  }) async {
    if (!LeaderboardApiConfig.useOnlineLeaderboard) return false;

    try {
      final odId = await getUserId();

      final response = await http
          .post(
            Uri.parse('${LeaderboardApiConfig.baseUrl}/api/scores/submit'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': odId,
              'systemName': systemName,
              'score': score,
            }),
          )
          .timeout(LeaderboardApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting score: $e');
      return false;
    }
  }

  /// Sync all local scores to the server
  Future<bool> syncAllScores() async {
    if (!LeaderboardApiConfig.useOnlineLeaderboard) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final odId = await getUserId();

      // Get username and country
      final username = prefs.getString('userName') ?? 'Player';
      final country = prefs.getString('userCountry') ?? 'Unknown';

      // First, register/update the user
      await registerUser(username: username, country: country);

      // Collect all system scores
      final systemNames = [
        'URL Shortener (e.g., TinyURL)',
        'Pastebin Service (e.g., Pastebin.com)',
        'Web Crawler',
        'Social Media News Feed (e.g., Facebook, X/Twitter)',
        'Video Streaming Service (e.g., Netflix, YouTube)',
        'Ride-Sharing Service (e.g., Uber, Lyft)',
        'Collaborative Editor (e.g., Google Docs, Figma)',
        'Live Streaming Platform (e.g., Twitch, YouTube Live)',
        'Global Gaming Leaderboard',
      ];

      final List<Map<String, dynamic>> systemScores = [];

      for (final systemName in systemNames) {
        final systemId = systemName.toLowerCase().replaceAll(' ', '_');
        final bestScore = prefs.getInt('best_score_$systemId') ?? 0;

        if (bestScore > 0) {
          systemScores.add({'systemName': systemName, 'score': bestScore});
        }
      }

      if (systemScores.isEmpty) return true;

      final response = await http
          .post(
            Uri.parse('${LeaderboardApiConfig.baseUrl}/api/scores/sync'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': odId, 'systemScores': systemScores}),
          )
          .timeout(LeaderboardApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error syncing scores: $e');
      return false;
    }
  }

  /// Fetch the global leaderboard
  Future<LeaderboardResult?> getLeaderboard({
    int limit = 100,
    int offset = 0,
  }) async {
    if (!LeaderboardApiConfig.useOnlineLeaderboard) return null;

    try {
      final odId = await getUserId();

      final response = await http
          .get(
            Uri.parse(
              '${LeaderboardApiConfig.baseUrl}/api/leaderboard?limit=$limit&offset=$offset',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(LeaderboardApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> leaderboardJson = data['leaderboard'] ?? [];

        final users =
            leaderboardJson.map((json) {
              return LeaderboardUser.fromJson(
                json,
                isCurrentUser: json['userId'] == odId,
              );
            }).toList();

        // Find current user's rank
        int? currentUserRank;
        for (final user in users) {
          if (user.isCurrentUser) {
            currentUserRank = user.rank;
            break;
          }
        }

        return LeaderboardResult(
          users: users,
          totalUsers: data['totalUsers'] ?? users.length,
          hasMore: data['hasMore'] ?? false,
          currentUserRank: currentUserRank,
          isOnline: true,
        );
      }

      return null;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return null;
    }
  }

  /// Get the current user's profile and rank
  Future<LeaderboardUser?> getCurrentUserProfile() async {
    if (!LeaderboardApiConfig.useOnlineLeaderboard) return null;

    try {
      final odId = await getUserId();

      final response = await http
          .get(
            Uri.parse('${LeaderboardApiConfig.baseUrl}/api/users/$odId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(LeaderboardApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'];
        userJson['rank'] = data['rank'];
        return LeaderboardUser.fromJson(userJson, isCurrentUser: true);
      }

      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get users around the current user for contextual view
  Future<LeaderboardResult?> getLeaderboardAroundUser({int range = 5}) async {
    if (!LeaderboardApiConfig.useOnlineLeaderboard) return null;

    try {
      final odId = await getUserId();

      final response = await http
          .get(
            Uri.parse(
              '${LeaderboardApiConfig.baseUrl}/api/leaderboard/around/$odId?range=$range',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(LeaderboardApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> usersJson = data['users'] ?? [];

        final users =
            usersJson.map((json) {
              return LeaderboardUser.fromJson(json);
            }).toList();

        return LeaderboardResult(
          users: users,
          totalUsers: data['totalUsers'] ?? users.length,
          currentUserRank: data['userRank'],
          isOnline: true,
        );
      }

      return null;
    } catch (e) {
      print('Error fetching leaderboard around user: $e');
      return null;
    }
  }

  /// Convert LeaderboardUser to the format expected by the existing leaderboard UI
  static Map<String, dynamic> toLeaderboardDataFormat(LeaderboardUser user) {
    return {
      'username': user.username,
      'country': user.country,
      'score': user.totalScore,
      'systemsDesigned': user.systemsDesigned,
      'averageScore': user.averageScore,
      'evaluations':
          user.evaluations
              .map(
                (e) => {
                  'systemName': e.systemName,
                  'score': e.score,
                  'timestamp': e.timestamp,
                },
              )
              .toList(),
      'isBot': false,
      'isOnlineUser': true,
      'rank': user.rank,
    };
  }
}

// ============================================
// LEGACY BOT DATA (PRESERVED FOR REFERENCE)
// ============================================
// 
// The original bot generation code is kept in leaderboard_screen.dart
// in the _generateStaticBots() function and LeaderboardBotManager class.
// 
// To switch back to bot mode:
// 1. Set LeaderboardApiConfig.useOnlineLeaderboard = false
// 2. The leaderboard will automatically fall back to using bots
// 
// ============================================
