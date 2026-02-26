import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'leaderboard_api_service.dart';

Future<List<Map<String, dynamic>>> _generateStaticBots() async {
  // Get device-specific seed for consistent but unique bot generation per device
  final prefs = await SharedPreferences.getInstance();

  int deviceSeed = prefs.getInt('device_bot_seed') ?? 0;
  if (deviceSeed == 0) {
    // Generate a unique seed for this device based on current timestamp
    deviceSeed = DateTime.now().millisecondsSinceEpoch % 1000000;
    await prefs.setInt('device_bot_seed', deviceSeed);
  }

  // Generate bots with random averages (< 100) ONLY ONCE - these will be permanent
  // Method: Generate random average per system first, then ensure total = average × systems
  // Individual system scores vary slightly but total maintains exact mathematical relationship
  final botNames = [
    'CodeMaster_Elite',
    'SystemArchitect_Pro',
    'ScalabilityGuru',
    'CloudNinja_X',
    'DatabaseWizard',
    'MicroserviceKing',
    'LoadBalancer_Ace',
    'CacheOptimizer',
    'TechStackLegend',
    'PerformanceBeast',
    'SecuritySentinel',
    'APIDesignPro',
    'DistributedMaster',
    'ThroughputExpert',
    'LatencyHunter',
    'RedisCommander',
    'KafkaStreamr',
    'DockerCaptain',
    'KubernetesWiz',
    'DevOpsNinja_99',
  ];

  final countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kosovo',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestine',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Korea',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];

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

  final List<Map<String, dynamic>> bots = [];
  final random = Random(
    deviceSeed,
  ); // Device-specific seed for unique bot assignment per device

  for (int i = 0; i < 20; i++) {
    // Assign target ranks: distribute 20 bots across ranks 1-10 (2 bots per rank)
    final targetRank =
        (i ~/ 2) +
        1; // Rank 1: bots 0,1 | Rank 2: bots 2,3 | ... | Rank 10: bots 18,19

    // Generate realistic number of systems (2-7 for competitive bots)
    final systemsDesigned = random.nextInt(6) + 2;

    // Generate random average per system (30-95 to ensure it's less than 100)
    final averageScore = 30 + random.nextInt(66); // 30-95 range

    // Calculate total score based on average and number of systems
    final finalScore = averageScore * systemsDesigned;

    final evaluations = <Map<String, dynamic>>[];

    // Distribute the average score across different systems with small variations
    // but ensure the total remains exactly averageScore * systemsDesigned
    final shuffledSystems = List<String>.from(systemNames)..shuffle(random);
    final List<int> systemScores = [];

    // Generate scores around the average with small variations
    for (int j = 0; j < systemsDesigned - 1; j++) {
      // Create small variation around the average (±15 points max)
      final variation = random.nextInt(31) - 15; // -15 to +15
      int systemScore = averageScore + variation;

      // Keep system scores within reasonable bounds (20-100)
      systemScore = systemScore < 20 ? 20 : systemScore;
      systemScore = systemScore > 100 ? 100 : systemScore;

      systemScores.add(systemScore);
    }

    // Calculate the last system score to ensure total = averageScore * systemsDesigned
    final currentTotal = systemScores.fold(0, (sum, score) => sum + score);
    final lastSystemScore = finalScore - currentTotal;

    // Ensure the last score is within bounds
    final adjustedLastScore =
        lastSystemScore < 20
            ? 20
            : (lastSystemScore > 100 ? 100 : lastSystemScore);
    systemScores.add(adjustedLastScore);

    // If we had to adjust the last score, recalculate the actual total and average
    final actualTotal = systemScores.fold(0, (sum, score) => sum + score);
    final actualAverage = (actualTotal / systemsDesigned).round();

    for (int j = 0; j < systemsDesigned; j++) {
      final systemName = shuffledSystems[j % systemNames.length];
      final systemScore = systemScores[j];

      evaluations.add({
        'systemName': systemName,
        'score': systemScore,
        'timestamp':
            DateTime.now()
                .subtract(Duration(days: random.nextInt(7)))
                .millisecondsSinceEpoch,
      });
    }

    // Use the actual total and recalculated average to ensure mathematical accuracy
    bots.add({
      'username': botNames[i],
      'country': countries[random.nextInt(countries.length)],
      'score': actualTotal,
      'systemsDesigned': systemsDesigned,
      'averageScore': actualAverage,
      'evaluations': evaluations,
      'isBot': true,
      'targetRank': targetRank,
    });
  }

  return bots;
}

/// Utility class for leaderboard bot management
class LeaderboardBotManager {
  /// Call this method from anywhere in the app when the player gains score.
  static Future<void> triggerLeaderboardBotUpdate() async {
    await _updateLeaderboardBotsOnScore();
  }

  static Future<void> _updateLeaderboardBotsOnScore() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateTime = prefs.getInt('bots_last_update') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDiff = currentTime - lastUpdateTime;
    final twentyFourHours = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    // Calculate how many 24-hour periods have elapsed
    final periodsElapsed = timeDiff ~/ twentyFourHours;

    List<Map<String, dynamic>> bots = [];
    final botsJsonString = prefs.getString('persistent_bots_v2');
    final botsInitialized = prefs.getBool('bots_initialized') ?? false;

    if (botsJsonString != null && botsInitialized) {
      try {
        final List<dynamic> botsJson = jsonDecode(botsJsonString);
        bots = botsJson.map((bot) => Map<String, dynamic>.from(bot)).toList();

        // Migration: Check if bots have required fields, regenerate if corrupted
        if (bots.isNotEmpty &&
            (bots.first['isBot'] == null || bots.first['score'] == null)) {
          // Bots are corrupted (missing required fields), regenerate them
          bots = await _generateStaticBots();
          await prefs.setString('persistent_bots_v2', jsonEncode(bots));
          await prefs.setInt('bots_last_update', currentTime);
          return;
        }
      } catch (e) {
        if (botsJsonString.isEmpty) {
          bots = [];
        }
      }
    } else {
      // First time: Generate initial bots
      bots = await _generateStaticBots();
      await prefs.setBool('bots_initialized', true);
      await prefs.setString('persistent_bots_v2', jsonEncode(bots));
      await prefs.setInt('bots_last_update', currentTime);
      return;
    }

    // Apply updates for each missed 24-hour period
    if (periodsElapsed > 0 && bots.isNotEmpty) {
      //print('DEBUG: Applying $periodsElapsed missed update period(s)...');

      final userScoreImprovement = await _calculateUserScoreImprovementStatic();

      // Apply the update for each missed period
      for (int i = 0; i < periodsElapsed; i++) {
        bots = _updateExistingBotsStatic(bots, userScoreImprovement);
        //print('DEBUG: Applied update period ${i + 1}/$periodsElapsed');
      }

      // Check if we need to change names (every 7 days)
      final lastNameChangeTime = prefs.getInt('bots_last_name_change') ?? 0;
      final nameChangeDiff = currentTime - lastNameChangeTime;
      final sevenDays = 7 * 24 * 60 * 60 * 1000;

      if (nameChangeDiff >= sevenDays) {
        bots = _changeRandomBotNamesStatic(bots);
        await prefs.setInt('bots_last_name_change', currentTime);
        //print('DEBUG: Bot names changed after 7 days');
      }

      // Save updated bots with the current timestamp
      await prefs.setString('persistent_bots_v2', jsonEncode(bots));
      await prefs.setInt('bots_last_update', currentTime);
      //print('DEBUG: Bots updated successfully at $currentTime');
    }
  }

  static Future<int> _calculateUserScoreImprovementStatic() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTotalScore = prefs.getInt('user_total_best_score') ?? 0;
    final scoreHistory = prefs.getStringList('user_score_history') ?? [];
    final twentyFourHoursAgo =
        DateTime.now()
            .subtract(const Duration(hours: 24))
            .millisecondsSinceEpoch;
    int scoreFrom24HoursAgo = currentTotalScore;
    for (final historyEntry in scoreHistory.reversed) {
      try {
        final data = jsonDecode(historyEntry);
        final timestamp = data['timestamp'] as int;
        final score = data['score'] as int;
        if (timestamp <= twentyFourHoursAgo) {
          scoreFrom24HoursAgo = score;
          break;
        }
      } catch (e) {}
    }
    final improvement = currentTotalScore - scoreFrom24HoursAgo;
    return improvement;
  }

  static List<Map<String, dynamic>> _updateExistingBotsStatic(
    List<Map<String, dynamic>> existingBots,
    int userScoreImprovement,
  ) {
    if (userScoreImprovement <= 0) {
      return existingBots;
    }
    final now = DateTime.now();
    final daysSinceEpoch = now.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    final weekCycle = (daysSinceEpoch ~/ 7) % 2;
    Map<int, double> rankingMultipliers;
    if (weekCycle == 0) {
      rankingMultipliers = {
        1: 1.10,
        2: 1.10,
        3: 0.80,
        4: 0.80,
        5: 0.60,
        6: 0.60,
        7: 0.40,
        8: 0.40,
        9: 0.20,
        10: 0.20,
      };
    } else {
      rankingMultipliers = {
        1: 0.20,
        2: 0.20,
        3: 0.40,
        4: 0.40,
        5: 0.60,
        6: 0.60,
        7: 0.80,
        8: 0.80,
        9: 1.10,
        10: 1.10,
      };
    }
    for (int i = 0; i < existingBots.length; i++) {
      final rank = i + 1;
      final multiplier = rankingMultipliers[rank] ?? 0.2;
      final newScore =
          (existingBots[i]['score'] as int) +
          (userScoreImprovement * multiplier).round();
      existingBots[i]['score'] = newScore;
    }
    return existingBots;
  }

  static List<Map<String, dynamic>> _changeRandomBotNamesStatic(
    List<Map<String, dynamic>> bots,
  ) {
    // You can reuse your existing _changeRandomBotNames logic here, or keep it simple
    return bots;
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;
  String? _currentUser;
  int _totalScore = 0;
  int _totalSystems = 0;
  String _serverName = '';

  String _getSystemUsername() {
    if (kIsWeb) return 'You';
    try {
      return 'You';
    } catch (e) {
      return 'You';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeServerName();
    _checkRequirementsAndLoad();
  }

  Future<void> _initializeServerName() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedServerName = prefs.getString('server_name');

    if (savedServerName == null) {
      // Generate a random server name
      savedServerName = _generateRandomServerName();
      await prefs.setString('server_name', savedServerName);
    }

    setState(() {
      _serverName = savedServerName!;
    });
  }

  String _generateRandomServerName() {
    final random = Random();

    // Lists of server name components
    final adjectives = [
      'Alpha',
      'Beta',
      'Gamma',
      'Delta',
      'Echo',
      'Phoenix',
      'Nova',
      'Quantum',
      'Cyber',
      'Digital',
      'Virtual',
      'Binary',
      'Matrix',
      'Stellar',
      'Cosmic',
      'Thunder',
      'Lightning',
      'Storm',
      'Frost',
      'Fire',
      'Shadow',
      'Light',
      'Crystal',
      'Diamond',
      'Platinum',
      'Golden',
      'Silver',
      'Iron',
      'Steel',
      'Turbo',
      'Hyper',
      'Ultra',
      'Mega',
      'Super',
      'Prime',
      'Elite',
      'Pro',
      'Neon',
      'Laser',
      'Plasma',
      'Fusion',
      'Atomic',
      'Neural',
      'Quantum',
    ];

    final nouns = [
      'Server',
      'Node',
      'Core',
      'Hub',
      'Station',
      'Base',
      'Center',
      'Point',
      'Terminal',
      'Gateway',
      'Portal',
      'Network',
      'Cloud',
      'Cluster',
      'Grid',
      'Nexus',
      'Vault',
      'Chamber',
      'Tower',
      'Fortress',
      'Citadel',
      'Palace',
      'Arsenal',
      'Workshop',
      'Factory',
      'Forge',
      'Lab',
      'Institute',
      'Academy',
      'Command',
      'Control',
      'Operations',
      'Systems',
      'Engine',
      'Reactor',
      'Generator',
      'Mainframe',
      'Database',
      'Archive',
      'Repository',
      'Databank',
      'Registry',
    ];

    final regions = [
      'US-East',
      'US-West',
      'EU-North',
      'EU-South',
      'Asia-Pacific',
      'Global',
      'Americas',
      'Europe',
      'Asia',
      'Oceania',
      'Arctic',
      'Nordic',
      'Alpine',
      'Pacific',
      'Atlantic',
      'Continental',
      'International',
      'Worldwide',
    ];

    final numbers = List.generate(
      999,
      (index) => (index + 1).toString().padLeft(3, '0'),
    );

    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final region = regions[random.nextInt(regions.length)];
    final number = numbers[random.nextInt(numbers.length)];

    // Choose a random format
    final formats = [
      '$adjective $noun $number',
      '$adjective $noun [$region]',
      '$region $adjective $noun',
      '$noun-$adjective-$number',
      '$region-$noun-$number',
    ];

    return formats[random.nextInt(formats.length)];
  }

  Future<void> _checkRequirementsAndLoad() async {
    final hasInternet = await _hasInternetConnection();
    final hasDesignedSystem = await _hasDesignedAtLeastOneSystem();

    if (!hasInternet || !hasDesignedSystem) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _loadUserEvaluations();
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasDesignedAtLeastOneSystem() async {
    final prefs = await SharedPreferences.getInstance();

    // First check the general completion flag
    final hasCompleted = prefs.getBool('has_completed_system_design') ?? false;
    if (hasCompleted) {
      return true;
    }

    // Check specific system completion flags (for backward compatibility)
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

    // Check if any system has been completed (evaluated)
    for (final systemName in systemNames) {
      final systemId = systemName.toLowerCase().replaceAll(' ', '_');
      final isCompleted = prefs.getBool('system_completed_$systemId') ?? false;
      if (isCompleted) {
        return true;
      }
    }

    // Also check for any evaluation data (for systems completed before this update)
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('evaluation_') && !key.endsWith('_temp')) {
        final evaluationData = prefs.getString(key);
        if (evaluationData != null && evaluationData.isNotEmpty) {
          try {
            final data = jsonDecode(evaluationData);
            if (data['score'] != null && data['score'] > 0) {
              // Found a valid evaluation, mark as completed for future
              await prefs.setBool('has_completed_system_design', true);
              return true;
            }
          } catch (e) {
            // Skip invalid evaluation data
          }
        }
      }
    }

    return false;
  }

  Future<Map<String, bool>> _getRequirements() async {
    final hasInternet = await _hasInternetConnection();
    final hasDesignedSystem = await _hasDesignedAtLeastOneSystem();

    return {'hasInternet': hasInternet, 'hasDesignedSystem': hasDesignedSystem};
  }

  // Country name to short form and flag mapping
  Map<String, Map<String, String>> getCountryInfo() {
    return {
      'Afghanistan': {'short': 'AFG', 'flag': '🇦🇫'},
      'Albania': {'short': 'ALB', 'flag': '🇦🇱'},
      'Algeria': {'short': 'DZA', 'flag': '🇩🇿'},
      'Andorra': {'short': 'AND', 'flag': '🇦🇩'},
      'Angola': {'short': 'AGO', 'flag': '🇦🇴'},
      'Antigua and Barbuda': {'short': 'ATG', 'flag': '🇦🇬'},
      'Argentina': {'short': 'ARG', 'flag': '🇦🇷'},
      'Armenia': {'short': 'ARM', 'flag': '🇦🇲'},
      'Australia': {'short': 'AUS', 'flag': '🇦🇺'},
      'Austria': {'short': 'AUT', 'flag': '🇦🇹'},
      'Azerbaijan': {'short': 'AZE', 'flag': '🇦🇿'},
      'Bahamas': {'short': 'BHS', 'flag': '🇧🇸'},
      'Bahrain': {'short': 'BHR', 'flag': '🇧🇭'},
      'Bangladesh': {'short': 'BGD', 'flag': '🇧🇩'},
      'Barbados': {'short': 'BRB', 'flag': '🇧🇧'},
      'Belarus': {'short': 'BLR', 'flag': '🇧🇾'},
      'Belgium': {'short': 'BEL', 'flag': '🇧🇪'},
      'Belize': {'short': 'BLZ', 'flag': '🇧🇿'},
      'Benin': {'short': 'BEN', 'flag': '🇧🇯'},
      'Bhutan': {'short': 'BTN', 'flag': '🇧🇹'},
      'Bolivia': {'short': 'BOL', 'flag': '🇧🇴'},
      'Bosnia and Herzegovina': {'short': 'BIH', 'flag': '🇧🇦'},
      'Botswana': {'short': 'BWA', 'flag': '🇧🇼'},
      'Brazil': {'short': 'BRA', 'flag': '🇧🇷'},
      'Brunei': {'short': 'BRN', 'flag': '🇧🇳'},
      'Bulgaria': {'short': 'BGR', 'flag': '🇧🇬'},
      'Burkina Faso': {'short': 'BFA', 'flag': '🇧🇫'},
      'Burundi': {'short': 'BDI', 'flag': '�🇮'},
      'Cabo Verde': {'short': 'CPV', 'flag': '🇨🇻'},
      'Cambodia': {'short': 'KHM', 'flag': '🇰🇭'},
      'Cameroon': {'short': 'CMR', 'flag': '🇨🇲'},
      'Canada': {'short': 'CAN', 'flag': '🇨🇦'},
      'Central African Republic': {'short': 'CAF', 'flag': '🇨🇫'},
      'Chad': {'short': 'TCD', 'flag': '🇹🇩'},
      'Chile': {'short': 'CHL', 'flag': '🇨🇱'},
      'China': {'short': 'CHN', 'flag': '🇨🇳'},
      'Colombia': {'short': 'COL', 'flag': '🇨🇴'},
      'Comoros': {'short': 'COM', 'flag': '🇰🇲'},
      'Congo': {'short': 'COG', 'flag': '🇨🇬'},
      'Costa Rica': {'short': 'CRI', 'flag': '🇨🇷'},
      'Croatia': {'short': 'HRV', 'flag': '🇭🇷'},
      'Cuba': {'short': 'CUB', 'flag': '🇨�🇺'},
      'Cyprus': {'short': 'CYP', 'flag': '🇨🇾'},
      'Czech Republic': {'short': 'CZE', 'flag': '🇨🇿'},
      'Denmark': {'short': 'DNK', 'flag': '🇩�'},
      'Djibouti': {'short': 'DJI', 'flag': '🇩🇯'},
      'Dominica': {'short': 'DMA', 'flag': '🇩🇲'},
      'Dominican Republic': {'short': 'DOM', 'flag': '🇩🇴'},
      'Ecuador': {'short': 'ECU', 'flag': '🇪🇨'},
      'Egypt': {'short': 'EGY', 'flag': '🇪🇬'},
      'El Salvador': {'short': 'SLV', 'flag': '�🇸🇻'},
      'Equatorial Guinea': {'short': 'GNQ', 'flag': '🇬🇶'},
      'Eritrea': {'short': 'ERI', 'flag': '🇪🇷'},
      'Estonia': {'short': 'EST', 'flag': '🇪🇪'},
      'Eswatini': {'short': 'SWZ', 'flag': '🇸🇿'},
      'Ethiopia': {'short': 'ETH', 'flag': '🇪🇹'},
      'Fiji': {'short': 'FJI', 'flag': '🇫🇯'},
      'Finland': {'short': 'FIN', 'flag': '🇫🇮'},
      'France': {'short': 'FRA', 'flag': '🇫🇷'},
      'Gabon': {'short': 'GAB', 'flag': '🇬🇦'},
      'Gambia': {'short': 'GMB', 'flag': '🇬🇲'},
      'Georgia': {'short': 'GEO', 'flag': '🇬🇪'},
      'Germany': {'short': 'DEU', 'flag': '🇩🇪'},
      'Ghana': {'short': 'GHA', 'flag': '🇬🇭'},
      'Greece': {'short': 'GRC', 'flag': '�🇷'},
      'Grenada': {'short': 'GRD', 'flag': '🇬�🇩'},
      'Guatemala': {'short': 'GTM', 'flag': '🇬🇹'},
      'Guinea': {'short': 'GIN', 'flag': '🇬�'},
      'Guinea-Bissau': {'short': 'GNB', 'flag': '🇬🇼'},
      'Guyana': {'short': 'GUY', 'flag': '🇬🇾'},
      'Haiti': {'short': 'HTI', 'flag': '🇭🇹'},
      'Honduras': {'short': 'HND', 'flag': '🇭🇳'},
      'Hungary': {'short': 'HUN', 'flag': '🇭🇺'},
      'Iceland': {'short': 'ISL', 'flag': '🇮🇸'},
      'India': {'short': 'IND', 'flag': '🇮🇳'},
      'Indonesia': {'short': 'IDN', 'flag': '🇮🇩'},
      'Iran': {'short': 'IRN', 'flag': '🇮🇷'},
      'Iraq': {'short': 'IRQ', 'flag': '🇮🇶'},
      'Ireland': {'short': 'IRL', 'flag': '🇮�🇪'},
      'Israel': {'short': 'ISR', 'flag': '🇮🇱'},
      'Italy': {'short': 'ITA', 'flag': '🇮🇹'},
      'Jamaica': {'short': 'JAM', 'flag': '🇯🇲'},
      'Japan': {'short': 'JPN', 'flag': '🇯🇵'},
      'Jordan': {'short': 'JOR', 'flag': '🇯🇴'},
      'Kazakhstan': {'short': 'KAZ', 'flag': '🇰🇿'},
      'Kenya': {'short': 'KEN', 'flag': '🇰🇪'},
      'Kiribati': {'short': 'KIR', 'flag': '🇰🇮'},
      'Kosovo': {'short': 'XKX', 'flag': '🇽🇰'},
      'Kuwait': {'short': 'KWT', 'flag': '🇰🇼'},
      'Kyrgyzstan': {'short': 'KGZ', 'flag': '🇰🇬'},
      'Laos': {'short': 'LAO', 'flag': '🇱🇦'},
      'Latvia': {'short': 'LVA', 'flag': '🇱🇻'},
      'Lebanon': {'short': 'LBN', 'flag': '🇱🇧'},
      'Lesotho': {'short': 'LSO', 'flag': '🇱🇸'},
      'Liberia': {'short': 'LBR', 'flag': '�🇷'},
      'Libya': {'short': 'LBY', 'flag': '🇱🇾'},
      'Liechtenstein': {'short': 'LIE', 'flag': '🇱🇮'},
      'Lithuania': {'short': 'LTU', 'flag': '🇱🇹'},
      'Luxembourg': {'short': 'LUX', 'flag': '🇱🇺'},
      'Madagascar': {'short': 'MDG', 'flag': '🇲🇬'},
      'Malawi': {'short': 'MWI', 'flag': '🇲🇼'},
      'Malaysia': {'short': 'MYS', 'flag': '🇲🇾'},
      'Maldives': {'short': 'MDV', 'flag': '🇲🇻'},
      'Mali': {'short': 'MLI', 'flag': '🇲🇱'},
      'Malta': {'short': 'MLT', 'flag': '🇲🇹'},
      'Marshall Islands': {'short': 'MHL', 'flag': '🇲🇭'},
      'Mauritania': {'short': 'MRT', 'flag': '🇲🇷'},
      'Mauritius': {'short': 'MUS', 'flag': '🇲🇺'},
      'Mexico': {'short': 'MEX', 'flag': '🇲🇽'},
      'Micronesia': {'short': 'FSM', 'flag': '🇫🇲'},
      'Moldova': {'short': 'MDA', 'flag': '🇲🇩'},
      'Monaco': {'short': 'MCO', 'flag': '🇲🇨'},
      'Mongolia': {'short': 'MNG', 'flag': '🇲🇳'},
      'Montenegro': {'short': 'MNE', 'flag': '🇲🇪'},
      'Morocco': {'short': 'MAR', 'flag': '🇲🇦'},
      'Mozambique': {'short': 'MOZ', 'flag': '🇲🇿'},
      'Myanmar': {'short': 'MMR', 'flag': '🇲🇲'},
      'Namibia': {'short': 'NAM', 'flag': '�🇦'},
      'Nauru': {'short': 'NRU', 'flag': '🇳🇷'},
      'Nepal': {'short': 'NPL', 'flag': '🇳🇵'},
      'Netherlands': {'short': 'NLD', 'flag': '🇳🇱'},
      'New Zealand': {'short': 'NZL', 'flag': '🇳🇿'},
      'Nicaragua': {'short': 'NIC', 'flag': '🇳🇮'},
      'Niger': {'short': 'NER', 'flag': '🇳🇪'},
      'Nigeria': {'short': 'NGA', 'flag': '🇳🇬'},
      'North Korea': {'short': 'PRK', 'flag': '🇰🇵'},
      'North Macedonia': {'short': 'MKD', 'flag': '🇲🇰'},
      'Norway': {'short': 'NOR', 'flag': '🇳🇴'},
      'Oman': {'short': 'OMN', 'flag': '🇴🇲'},
      'Pakistan': {'short': 'PAK', 'flag': '🇵🇰'},
      'Palau': {'short': 'PLW', 'flag': '🇵🇼'},
      'Palestine': {'short': 'PSE', 'flag': '🇵🇸'},
      'Panama': {'short': 'PAN', 'flag': '🇵🇦'},
      'Papua New Guinea': {'short': 'PNG', 'flag': '🇵🇬'},
      'Paraguay': {'short': 'PRY', 'flag': '🇵🇾'},
      'Peru': {'short': 'PER', 'flag': '🇵🇪'},
      'Philippines': {'short': 'PHL', 'flag': '🇵🇭'},
      'Poland': {'short': 'POL', 'flag': '🇵🇱'},
      'Portugal': {'short': 'PRT', 'flag': '🇵🇹'},
      'Qatar': {'short': 'QAT', 'flag': '🇶🇦'},
      'Romania': {'short': 'ROU', 'flag': '��'},
      'Russia': {'short': 'RUS', 'flag': '🇷🇺'},
      'Rwanda': {'short': 'RWA', 'flag': '🇷🇼'},
      'Saint Kitts and Nevis': {'short': 'KNA', 'flag': '🇰🇳'},
      'Saint Lucia': {'short': 'LCA', 'flag': '🇱🇨'},
      'Saint Vincent and the Grenadines': {'short': 'VCT', 'flag': '🇻🇨'},
      'Samoa': {'short': 'WSM', 'flag': '🇼🇸'},
      'San Marino': {'short': 'SMR', 'flag': '🇸🇲'},
      'Sao Tome and Principe': {'short': 'STP', 'flag': '🇸🇹'},
      'Saudi Arabia': {'short': 'SAU', 'flag': '🇸🇦'},
      'Senegal': {'short': 'SEN', 'flag': '��🇳'},
      'Serbia': {'short': 'SRB', 'flag': '�🇸'},
      'Seychelles': {'short': 'SYC', 'flag': '🇸🇨'},
      'Sierra Leone': {'short': 'SLE', 'flag': '🇸�🇱'},
      'Singapore': {'short': 'SGP', 'flag': '🇸🇬'},
      'Slovakia': {'short': 'SVK', 'flag': '🇸🇰'},
      'Slovenia': {'short': 'SVN', 'flag': '🇸🇮'},
      'Solomon Islands': {'short': 'SLB', 'flag': '🇸🇧'},
      'Somalia': {'short': 'SOM', 'flag': '🇸🇴'},
      'South Africa': {'short': 'ZAF', 'flag': '🇿🇦'},
      'South Korea': {'short': 'KOR', 'flag': '🇰🇷'},
      'South Sudan': {'short': 'SSD', 'flag': '🇸🇸'},
      'Spain': {'short': 'ESP', 'flag': '🇪🇸'},
      'Sri Lanka': {'short': 'LKA', 'flag': '🇱🇰'},
      'Sudan': {'short': 'SDN', 'flag': '🇸🇩'},
      'Suriname': {'short': 'SUR', 'flag': '��'},
      'Sweden': {'short': 'SWE', 'flag': '🇸🇪'},
      'Switzerland': {'short': 'CHE', 'flag': '🇨🇭'},
      'Syria': {'short': 'SYR', 'flag': '🇸🇾'},
      'Taiwan': {'short': 'TWN', 'flag': '🇹🇼'},
      'Tajikistan': {'short': 'TJK', 'flag': '🇹🇯'},
      'Tanzania': {'short': 'TZA', 'flag': '🇹🇿'},
      'Thailand': {'short': 'THA', 'flag': '🇹🇭'},
      'Timor-Leste': {'short': 'TLS', 'flag': '�🇱'},
      'Togo': {'short': 'TGO', 'flag': '🇹🇬'},
      'Tonga': {'short': 'TON', 'flag': '��'},
      'Trinidad and Tobago': {'short': 'TTO', 'flag': '🇹🇹'},
      'Tunisia': {'short': 'TUN', 'flag': '�🇳'},
      'Turkey': {'short': 'TUR', 'flag': '🇹🇷'},
      'Turkmenistan': {'short': 'TKM', 'flag': '🇹🇲'},
      'Tuvalu': {'short': 'TUV', 'flag': '🇹🇻'},
      'Uganda': {'short': 'UGA', 'flag': '��'},
      'Ukraine': {'short': 'UKR', 'flag': '🇺🇦'},
      'United Arab Emirates': {'short': 'ARE', 'flag': '��'},
      'United Kingdom': {'short': 'GBR', 'flag': '🇬🇧'},
      'United States': {'short': 'USA', 'flag': '��'},
      'Uruguay': {'short': 'URY', 'flag': '��'},
      'Uzbekistan': {'short': 'UZB', 'flag': '🇺🇿'},
      'Vanuatu': {'short': 'VUT', 'flag': '🇻🇺'},
      'Vatican City': {'short': 'VAT', 'flag': '🇻🇦'},
      'Venezuela': {'short': 'VEN', 'flag': '��'},
      'Vietnam': {'short': 'VNM', 'flag': '🇻🇳'},
      'Yemen': {'short': 'YEM', 'flag': '�🇪'},
      'Zambia': {'short': 'ZMB', 'flag': '🇿🇲'},
      'Zimbabwe': {'short': 'ZWE', 'flag': '🇿🇼'},
      // Special cases for user entries
      'Your Progress': {'short': 'YOU', 'flag': '👤'},
      'No Designs Yet': {'short': 'NEW', 'flag': '🆕'},
    };
  }

  String getCountryDisplay(String countryName) {
    final countryInfo = getCountryInfo();
    final info = countryInfo[countryName];
    if (info != null) {
      return '${info['flag']} ${info['short']}';
    }
    return countryName; // Fallback to original name
  }

  Future<void> _loadUserEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the same userName key as profile and main screen
    _currentUser = prefs.getString('userName') ?? _getSystemUsername();

    // Load best scores from all systems (not accumulating multiple submissions of same system)
    List<Map<String, dynamic>> userEvaluations = [];
    int totalBestScore = 0;
    int systemCount = 0;

    // System names that might have evaluations (matching actual system names from design_system_screen.dart)
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

    for (final systemName in systemNames) {
      final systemId = systemName.toLowerCase().replaceAll(' ', '_');
      final bestScore = prefs.getInt('best_score_$systemId') ?? 0;

      if (bestScore > 0) {
        // Only count systems with actual best scores
        final timestamp =
            prefs.getInt('best_score_timestamp_$systemId') ??
            DateTime.now().millisecondsSinceEpoch;

        userEvaluations.add({
          'systemName': systemName,
          'score': bestScore,
          'timestamp': timestamp,
          'isBestScore': true,
        });

        totalBestScore += bestScore;
        systemCount++;
      }
    }

    // UNLIMITED DESIGN INTEGRATION: Load scores from Unlimited Design mode
    final unlimitedDesignKeys =
        prefs
            .getKeys()
            .where((key) => key.startsWith('best_score_unlimited_design_'))
            .toList();

    // ...existing code...

    // Debug: List ALL keys that might be related
    // ...existing code...
    // ...existing code...

    for (final key in unlimitedDesignKeys) {
      final bestScore = prefs.getInt(key) ?? 0;
      // ...existing code...

      if (bestScore > 0) {
        final systemId = key.replaceFirst('best_score_unlimited_design_', '');
        final displayName = systemId
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) =>
                  word.isEmpty
                      ? word
                      : word[0].toUpperCase() + word.substring(1),
            )
            .join(' ');
        final timestamp =
            prefs.getInt('best_score_timestamp_unlimited_design_$systemId') ??
            DateTime.now().millisecondsSinceEpoch;

        userEvaluations.add({
          'systemName': 'Unlimited Design: $displayName',
          'score': bestScore,
          'timestamp': timestamp,
          'isBestScore': true,
        });

        totalBestScore += bestScore;
        systemCount++;
        // ...existing code...
      }
    }

    // Create leaderboard entry for current user
    List<Map<String, dynamic>> leaderboard = [];

    // Load user's selected country
    final userCountry = prefs.getString('userCountry') ?? 'United States';

    if (systemCount > 0) {
      final averageScore = (totalBestScore / systemCount).round();
      leaderboard.add({
        'username': _currentUser!,
        'score':
            totalBestScore, // This is now sum of best scores from different systems
        'averageScore': averageScore,
        'systemsDesigned': systemCount,
        'country': userCountry,
        'isCurrentUser': true,
        'evaluations': userEvaluations,
      });
    } else {
      // No evaluations yet
      leaderboard.add({
        'username': _currentUser!,
        'score': 0,
        'averageScore': 0,
        'systemsDesigned': 0,
        'country': userCountry,
        'isCurrentUser': true,
        'evaluations': [],
      });
    }

    // Add persistent bots to the leaderboard (always show bots for a richer experience)
    final bots = await _getPersistentBots();
    leaderboard.addAll(bots);

    // Also fetch and add online users from the backend
    final onlineUsers = await _fetchOnlineLeaderboard(
      prefs,
      userCountry,
      totalBestScore,
      systemCount,
      userEvaluations,
    );

    if (onlineUsers != null && onlineUsers.isNotEmpty) {
      // Add online users to compete alongside bots
      leaderboard.addAll(onlineUsers);
    }

    // Sort by score (highest first) and add rankings
    leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
    for (int i = 0; i < leaderboard.length; i++) {
      leaderboard[i]['rank'] = i + 1;
    }

    // Find user's rank and save royal title if in top 3
    int userRank = -1;
    for (final entry in leaderboard) {
      if (entry['isCurrentUser'] == true) {
        userRank = entry['rank'];
        break;
      }
    }

    // Save royal title to SharedPreferences for profile screen
    if (userRank >= 1 && userRank <= 3 && systemCount > 0) {
      final title = '$_serverName No.$userRank SystemDesigner';
      await prefs.setString('saved_royal_title', title);
      await prefs.setBool('has_royal_title', true);
    } else {
      await prefs.remove('saved_royal_title');
      await prefs.setBool('has_royal_title', false);
    }

    setState(() {
      _leaderboardData = leaderboard;
      _totalScore = totalBestScore;
      _totalSystems = systemCount;
      _isLoading = false;
    });

    // Save current score to history for future improvement calculations
    await _saveCurrentScoreToHistory(totalBestScore);
  }

  // Save current score to history for tracking improvements
  Future<void> _saveCurrentScoreToHistory(int currentScore) async {
    final prefs = await SharedPreferences.getInstance();
    final scoreHistory = prefs.getStringList('user_score_history') ?? [];

    // Add current score with timestamp
    final scoreEntry = jsonEncode({
      'score': currentScore,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    scoreHistory.add(scoreEntry);

    // Keep only last 100 entries to prevent unlimited growth
    if (scoreHistory.length > 100) {
      scoreHistory.removeRange(0, scoreHistory.length - 100);
    }

    await prefs.setStringList('user_score_history', scoreHistory);
  }

  /// Fetch online leaderboard data from the backend API
  /// Returns null if online leaderboard is unavailable (falls back to bots)
  Future<List<Map<String, dynamic>>?> _fetchOnlineLeaderboard(
    SharedPreferences prefs,
    String userCountry,
    int totalBestScore,
    int systemCount,
    List<Map<String, dynamic>> userEvaluations,
  ) async {
    // Check if online leaderboard is enabled
    if (!LeaderboardApiConfig.useOnlineLeaderboard) {
      return null;
    }

    try {
      final apiService = LeaderboardApiService.instance;

      // First, sync the current user's scores to the server
      final username = prefs.getString('userName') ?? _getSystemUsername();

      // Register/update user and sync scores
      await apiService.registerUser(username: username, country: userCountry);
      await apiService.syncAllScores();

      // Fetch the global leaderboard
      final result = await apiService.getLeaderboard(limit: 100);

      if (result == null || result.users.isEmpty) {
        return null;
      }

      // Convert online users to the format expected by the UI
      final onlineUsers = <Map<String, dynamic>>[];
      final currentUserId = await apiService.getUserId();

      for (final user in result.users) {
        // Skip if this is the current user (already added to leaderboard)
        if (user.odId == currentUserId) {
          continue;
        }

        onlineUsers.add({
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
        });
      }

      return onlineUsers;
    } catch (e) {
      print('Error fetching online leaderboard: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getPersistentBots() async {
    //print('DEBUG: _getPersistentBots called');
    final prefs = await SharedPreferences.getInstance();

    // Check if 24 hours have passed since last update
    final lastUpdateTime = prefs.getInt('bots_last_update') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDiff = currentTime - lastUpdateTime;
    final twentyFourHours = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    // Calculate how many 24-hour periods have elapsed
    final periodsElapsed = timeDiff ~/ twentyFourHours;
    //print('DEBUG: $periodsElapsed period(s) elapsed since last update');

    List<Map<String, dynamic>> bots = [];

    // Check if bots exist - NEVER delete existing bots, only load or create once
    final botsJsonString = prefs.getString('persistent_bots_v2');
    final botsInitialized = prefs.getBool('bots_initialized') ?? false;

    if (botsJsonString != null && botsInitialized) {
      try {
        final List<dynamic> botsJson = jsonDecode(botsJsonString);
        bots = botsJson.map((bot) => Map<String, dynamic>.from(bot)).toList();

        // Migration: Check if bots have required fields, regenerate if corrupted
        if (bots.isNotEmpty &&
            (bots.first['isBot'] == null || bots.first['score'] == null)) {
          // Bots are corrupted (missing required fields), regenerate them
          bots = await _generateStaticBots();
          await prefs.setString('persistent_bots_v2', jsonEncode(bots));
          await prefs.setInt('bots_last_update', currentTime);
          return bots;
        }
      } catch (e) {
        // Even if there's an error, try to preserve bots - only recreate as absolute last resort
        if (botsJsonString.isEmpty) {
          bots = [];
        }
      }
    } else {
      // First time only: Generate initial bots and mark as initialized
      bots = await _generateStaticBots();

      // Mark bots as initialized - this ensures they're NEVER recreated
      await prefs.setBool('bots_initialized', true);
      await prefs.setString('persistent_bots_v2', jsonEncode(bots));
      await prefs.setInt('bots_last_update', currentTime);

      return bots;
    }

    // Apply updates for each missed 24-hour period
    if (periodsElapsed > 0 && bots.isNotEmpty) {
      //print('DEBUG: Applying $periodsElapsed missed update period(s) in leaderboard...');

      // Update existing bots by adding to their scores - PRESERVE names and base structure
      final userScoreImprovement = await _calculateUserScoreImprovement();

      // Apply the update for each missed period
      for (int i = 0; i < periodsElapsed; i++) {
        bots = _updateExistingBots(bots, userScoreImprovement);
        //print('DEBUG: Applied leaderboard update period ${i + 1}/$periodsElapsed');
      }
      //print('DEBUG: userScoreImprovement = $userScoreImprovement');
      //print('DEBUG: Bots before update:');
      //for (var bot in bots) {
      //  print('  Bot ${bot['username']} score: ${bot['score']}');
      //}
      //print('DEBUG: Bots after update:');
      for (var bot in bots) {
        //print('  Bot ${bot['username']} score: ${bot['score']}');-------------------------------------------------
      }
      // ...existing code...

      // Check if we need to change names weekly (every 7 days)
      final lastNameChangeTime = prefs.getInt('bots_last_name_change') ?? 0;
      final nameChangeDiff = currentTime - lastNameChangeTime;
      //final sevenDays = 1 * 60 * 1000; // 1 minute in milliseconds
      final sevenDays = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
      //final twentyFourHours = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

      if (nameChangeDiff >= sevenDays) {
        bots = _changeRandomBotNames(bots);
        await prefs.setInt('bots_last_name_change', currentTime);
      }

      // Store updated bots (preserving names and structure, only updating scores)
      await prefs.setString('persistent_bots_v2', jsonEncode(bots));
      await prefs.setInt('bots_last_update', currentTime);
    }

    return bots;
  }

  Future<int> _calculateUserScoreImprovement() async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user total score
    final currentTotalScore = prefs.getInt('user_total_best_score') ?? 0;

    // Get user score from 24 hours ago (matching bot update interval)
    final scoreHistory = prefs.getStringList('user_score_history') ?? [];
    final twentyFourHoursAgo =
        DateTime.now()
            .subtract(const Duration(hours: 24))
            .millisecondsSinceEpoch;

    int scoreFrom24HoursAgo = currentTotalScore; // Default to current score

    // Find the most recent score that's older than 24 hours
    for (final historyEntry in scoreHistory.reversed) {
      try {
        final data = jsonDecode(historyEntry);
        final timestamp = data['timestamp'] as int;
        final score = data['score'] as int;

        if (timestamp <= twentyFourHoursAgo) {
          scoreFrom24HoursAgo = score;
          break;
        }
      } catch (e) {
        // Skip invalid entries
      }
    }

    // Calculate improvement (current score - score from 24hrs ago)
    final improvement = currentTotalScore - scoreFrom24HoursAgo;

    // Return improvement (can be 0 or negative)
    return improvement;
  }

  List<Map<String, dynamic>> _updateExistingBots(
    List<Map<String, dynamic>> existingBots,
    int userScoreImprovement,
  ) {
    // If user didn't improve, don't update bot scores
    if (userScoreImprovement <= 0) {
      return existingBots;
    }

    // Determine which week pattern we're in (alternates every 7 days)
    final now = DateTime.now();
    //print('DEBUG: Pattern logic running. Time: ${now.toIso8601String()}');
    final minutesSinceEpoch =
        now.millisecondsSinceEpoch ~/
        (1000 * 60 * 60 * 24 * 7); // 7 days in minutes
    final weekCycle =
        (minutesSinceEpoch ~/ 1) %
        2; // 0 for pattern 1, 1 for pattern 2 (changes every minute)
    //print('DEBUG: weekCycle = $weekCycle');

    Map<int, double> rankingMultipliers;

    if (weekCycle == 0) {
      // Week 1 Pattern: Top ranks get highest bonuses (traditional pattern)
      rankingMultipliers = {
        1: 1.10, // Rank 1-2: Add 110% of user improvement for 7 days
        2: 1.10,
        3: 0.80, // Rank 3-4: Add 80% of user improvement for 7 days
        4: 0.80,
        5: 0.60, // Rank 5-6: Add 60% of user improvement for 7 days
        6: 0.60,
        7: 0.40, // Rank 7-8: Add 40% of user improvement for 7 days
        8: 0.40,
        9: 0.20, // Rank 9-10: Add 20% of user improvement for 7 days
        10: 0.20,
      };
    } else {
      // Week 2 Pattern: Lower ranks get highest bonuses (flipped pattern)
      rankingMultipliers = {
        1: 0.20, // Rank 1-2: Add 20% of user improvement for 7 days
        2: 0.20,
        3: 0.40, // Rank 3-4: Add 40% of user improvement for 7 days
        4: 0.40,
        5: 0.60, // Rank 5-6: Add 60% of user improvement for 7 days
        6: 0.60,
        7: 0.80, // Rank 7-8: Add 80% of user improvement for 7 days
        8: 0.80,
        9: 1.10, // Rank 9-10: Add 110% of user improvement for 7 days
        10: 1.10,
      };
    }

    final updatedBots = <Map<String, dynamic>>[];

    for (final bot in existingBots) {
      // SKIP REAL USERS - only apply scoring algorithm to bots
      final isBot = bot['isBot'] ?? false;
      if (!isBot) {
        // This is a real user, preserve them as-is without applying bot algorithm
        updatedBots.add(Map<String, dynamic>.from(bot));
        continue;
      }

      // PRESERVE all original bot data - never change names, countries, etc.
      final updatedBot = Map<String, dynamic>.from(bot);

      final targetRank = bot['targetRank'] ?? 5; // Default to rank 5 if not set
      final multiplier = rankingMultipliers[targetRank] ?? 0.50;

      // Calculate score addition based on current week pattern
      final scoreAddition = (userScoreImprovement * multiplier).round();

      // Add to existing score (NEVER replace, only add)
      final currentScore = bot['score'] as int;
      final newScore = currentScore + scoreAddition;
      final currentSystemsDesigned = bot['systemsDesigned'] as int;

      // Determine if bot should "design" new systems to keep average under 100
      final currentAverage = newScore / currentSystemsDesigned;
      var newSystemsDesigned = currentSystemsDesigned;

      // If average would exceed 100, bot "designs" 4-5 new systems to adjust average
      if (currentAverage > 100) {
        final random = Random();
        final systemsToAdd = 4 + random.nextInt(2); // Add 4-5 systems
        newSystemsDesigned = currentSystemsDesigned + systemsToAdd;

        // Add multiple new system evaluations to maintain consistency
        final evaluations = List<Map<String, dynamic>>.from(
          bot['evaluations'] ?? [],
        );

        // Generate creative system names as bots expand beyond the basic 9
        final basicSystems = [
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

        final advancedSystems = [
          'Distributed Database System',
          'Microservices API Gateway',
          'Real-time Chat Platform',
          'Video Conferencing System',
          'E-commerce Marketplace',
          'Content Delivery Network',
          'Machine Learning Pipeline',
          'Blockchain Network',
          'IoT Device Management Platform',
          'Cloud Storage System',
          'Email Service Provider',
          'Payment Processing System',
          'Search Engine',
          'Analytics Dashboard',
          'Message Queue System',
          'Load Balancer',
          'Authentication Service',
          'Notification System',
          'File Sharing Platform',
          'Video Game Backend',
          'Social Media Analytics',
          'Cryptocurrency Exchange',
          'Weather Monitoring System',
          'Traffic Management System',
          'Hospital Management System',
          'School Management System',
          'Inventory Management System',
          'Customer Support Platform',
          'Time Tracking System',
          'Project Management Tool',
        ];

        // Find systems not already used by this bot
        final usedSystems =
            evaluations.map((e) => e['systemName'] as String).toSet();
        final allSystems = [...basicSystems, ...advancedSystems];
        var availableSystems =
            allSystems.where((name) => !usedSystems.contains(name)).toList();

        // Calculate target average (aim for 85-95 range to prevent future spikes)
        final targetAverage = 85 + random.nextInt(11); // 85-95 range
        final targetTotalScore = targetAverage * newSystemsDesigned;
        final totalNewSystemScore = targetTotalScore - currentScore;
        final averageNewSystemScore = totalNewSystemScore / systemsToAdd;

        // Add the new systems
        for (int i = 0; i < systemsToAdd; i++) {
          String newSystemName;

          if (availableSystems.isNotEmpty) {
            final randomIndex = random.nextInt(availableSystems.length);
            newSystemName = availableSystems.removeAt(randomIndex);
          } else {
            // Generate unlimited creative system names
            final systemTypes = [
              'AI-Powered Recommendation Engine',
              'Distributed Cache System',
              'Real-time Monitoring Platform',
              'Automated Testing Framework',
              'Data Warehousing Solution',
              'Edge Computing Network',
              'Serverless Function Platform',
              'Container Orchestration System',
              'Event Streaming Platform',
              'Graph Database System',
              'Time Series Database',
              'Multi-tenant SaaS Platform',
              'Fraud Detection System',
              'Image Recognition Service',
              'Natural Language Processing API',
              'Recommendation Algorithm Engine',
              'Real-time Bidding Platform',
              'Supply Chain Management System',
            ];
            final baseType = systemTypes[random.nextInt(systemTypes.length)];
            final systemNumber =
                newSystemsDesigned -
                basicSystems.length -
                advancedSystems.length +
                i +
                1;
            newSystemName = '$baseType v$systemNumber';
          }

          // Score for each new system (with some variation)
          final variation = random.nextInt(21) - 10; // -10 to +10 variation
          var systemScore = (averageNewSystemScore + variation).round();
          systemScore =
              systemScore > 100 ? 100 : (systemScore < 30 ? 30 : systemScore);

          evaluations.add({
            'systemName': newSystemName,
            'score': systemScore,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        updatedBot['evaluations'] = evaluations;
        updatedBot['systemsDesigned'] = newSystemsDesigned;

        // Recalculate total score with new systems
        final actualNewScore = evaluations.fold<int>(
          0,
          (sum, eval) => sum + (eval['score'] as int),
        );
        updatedBot['score'] = actualNewScore;
        final finalAverage = (actualNewScore / newSystemsDesigned).round();
        updatedBot['averageScore'] = finalAverage > 100 ? 100 : finalAverage;
      } else {
        // Normal update - just add to existing scores
        updatedBot['score'] = newScore;
        updatedBot['systemsDesigned'] = currentSystemsDesigned;
        final averagePerSystem = (newScore / currentSystemsDesigned).round();
        updatedBot['averageScore'] =
            averagePerSystem > 100 ? 100 : averagePerSystem;
      }

      // Update existing evaluation scores if no new system was added
      if (newSystemsDesigned == currentSystemsDesigned) {
        final evaluations = List<Map<String, dynamic>>.from(
          bot['evaluations'] ?? [],
        );
        for (final evaluation in evaluations) {
          // PRESERVE system name and timestamp, only update score
          final oldScore = evaluation['score'] as int;
          final proportionalIncrease =
              (scoreAddition / currentSystemsDesigned).round();
          final newSystemScore = oldScore + proportionalIncrease;
          // Cap individual system scores at 100 since that's the maximum possible
          evaluation['score'] = newSystemScore > 100 ? 100 : newSystemScore;
          // Keep systemName, timestamp unchanged
        }
        updatedBot['evaluations'] = evaluations;
      }

      // Store which week pattern was used for this update
      updatedBot['lastUpdatePattern'] = weekCycle == 0 ? 'Week1' : 'Week2';
      updatedBot['lastUpdateRankMultiplier'] = multiplier;

      // Ensure ALL other fields are preserved (username, country, isBot, etc.)
      // Note: systemsDesigned may increase if bot "designs" new systems to maintain realistic averages
      // This is automatic since we're using Map.from(bot) and only updating specific fields

      updatedBots.add(updatedBot);
    }

    return updatedBots;
  }

  Future<List<Map<String, dynamic>>> _generateStaticBots() async {
    // Get device-specific seed for consistent but unique bot generation per device
    final prefs = await SharedPreferences.getInstance();

    int deviceSeed = prefs.getInt('device_bot_seed') ?? 0;
    if (deviceSeed == 0) {
      // Generate a unique seed for this device based on current timestamp
      deviceSeed = DateTime.now().millisecondsSinceEpoch % 1000000;
      await prefs.setInt('device_bot_seed', deviceSeed);
    }

    // Generate bots with random averages (< 100) ONLY ONCE - these will be permanent
    // Method: Generate random average per system first, then ensure total = average × systems
    // Individual system scores vary slightly but total maintains exact mathematical relationship
    final botNames = [
      'CodeMaster_Elite',
      'SystemArchitect_Pro',
      'ScalabilityGuru',
      'CloudNinja_X',
      'DatabaseWizard',
      'MicroserviceKing',
      'LoadBalancer_Ace',
      'CacheOptimizer',
      'TechStackLegend',
      'PerformanceBeast',
      'SecuritySentinel',
      'APIDesignPro',
      'DistributedMaster',
      'ThroughputExpert',
      'LatencyHunter',
      'RedisCommander',
      'KafkaStreamr',
      'DockerCaptain',
      'KubernetesWiz',
      'DevOpsNinja_99',
    ];

    final countries = [
      'United States',
      'Germany',
      'Japan',
      'South Korea',
      'Canada',
      'United Kingdom',
      'Netherlands',
      'Singapore',
      'Australia',
      'Sweden',
      'Switzerland',
      'Israel',
      'India',
      'China',
      'Brazil',
      'France',
      'Finland',
      'Norway',
      'Denmark',
      'Ireland',
    ];

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

    final List<Map<String, dynamic>> bots = [];
    final random = Random(
      deviceSeed,
    ); // Device-specific seed for unique bot assignment per device

    for (int i = 0; i < 20; i++) {
      // Assign target ranks: distribute 20 bots across ranks 1-10 (2 bots per rank)
      final targetRank =
          (i ~/ 2) +
          1; // Rank 1: bots 0,1 | Rank 2: bots 2,3 | ... | Rank 10: bots 18,19

      // Generate realistic number of systems (2-7 for competitive bots)
      final systemsDesigned = random.nextInt(6) + 2;

      // Generate random average per system (30-95 to ensure it's less than 100)
      final averageScore = 30 + random.nextInt(66); // 30-95 range

      // Calculate total score based on average and number of systems
      final finalScore = averageScore * systemsDesigned;

      final evaluations = <Map<String, dynamic>>[];

      // Distribute the average score across different systems with small variations
      // but ensure the total remains exactly averageScore * systemsDesigned
      final shuffledSystems = List<String>.from(systemNames)..shuffle(random);
      final List<int> systemScores = [];

      // Generate scores around the average with small variations
      for (int j = 0; j < systemsDesigned - 1; j++) {
        // Create small variation around the average (±15 points max)
        final variation = random.nextInt(31) - 15; // -15 to +15
        int systemScore = averageScore + variation;

        // Keep system scores within reasonable bounds (20-100)
        systemScore = systemScore < 20 ? 20 : systemScore;
        systemScore = systemScore > 100 ? 100 : systemScore;

        systemScores.add(systemScore);
      }

      // Calculate the last system score to ensure total = averageScore * systemsDesigned
      final currentTotal = systemScores.fold(0, (sum, score) => sum + score);
      final lastSystemScore = finalScore - currentTotal;

      // Ensure the last score is within bounds
      final adjustedLastScore =
          lastSystemScore < 20
              ? 20
              : (lastSystemScore > 100 ? 100 : lastSystemScore);
      systemScores.add(adjustedLastScore);

      // If we had to adjust the last score, recalculate the actual total and average
      final actualTotal = systemScores.fold(0, (sum, score) => sum + score);
      final actualAverage = (actualTotal / systemsDesigned).round();

      for (int j = 0; j < systemsDesigned; j++) {
        final systemName = shuffledSystems[j % systemNames.length];
        final systemScore = systemScores[j];

        evaluations.add({
          'systemName': systemName,
          'score': systemScore,
          'timestamp':
              DateTime.now()
                  .subtract(Duration(days: random.nextInt(7)))
                  .millisecondsSinceEpoch,
        });
      }

      // Use the actual total and recalculated average to ensure mathematical accuracy
      bots.add({
        'username': botNames[i],
        'score': actualTotal,
        'averageScore': actualAverage,
        'systemsDesigned': systemsDesigned,
        'country': countries[random.nextInt(countries.length)],
        'isCurrentUser': false,
        'evaluations': evaluations,
        'isBot': true,
        'targetRank':
            targetRank, // Assign target rank for weekly scoring pattern
      });
    }

    return bots;
  }

  List<Map<String, dynamic>> _changeRandomBotNames(
    List<Map<String, dynamic>> bots,
  ) {
    // Original 20 bot names pool
    final allBotNames = [
      'CodeMaster_Elite',
      'SystemArchitect_Pro',
      'ScalabilityGuru',
      'CloudNinja_X',
      'DatabaseWizard',
      'MicroserviceKing',
      'LoadBalancer_Ace',
      'CacheOptimizer',
      'TechStackLegend',
      'PerformanceBeast',
      'SecuritySentinel',
      'APIDesignPro',
      'DistributedMaster',
      'ThroughputExpert',
      'LatencyHunter',
      'RedisCommander',
      'KafkaStreamr',
      'DockerCaptain',
      'KubernetesWiz',
      'DevOpsNinja_99',
    ];

    // Sort bots by score to get current rankings
    final sortedBots = List<Map<String, dynamic>>.from(bots);
    sortedBots.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // Get bots in ranks 6-10 (bottom 5 of top 10)
    final eligibleBots = <Map<String, dynamic>>[];
    for (int i = 5; i < sortedBots.length && i < 10; i++) {
      eligibleBots.add(sortedBots[i]);
    }

    // If we don't have enough bots in ranks 6-10, expand to more ranks
    if (eligibleBots.length < 3) {
      for (int i = 10; i < sortedBots.length && eligibleBots.length < 5; i++) {
        eligibleBots.add(sortedBots[i]);
      }
    }

    // Randomly select 3 bots to change names
    final random = Random();
    final botsToChange = <Map<String, dynamic>>[];
    final eligibleCopy = List<Map<String, dynamic>>.from(eligibleBots);

    for (int i = 0; i < 3 && eligibleCopy.isNotEmpty; i++) {
      final randomIndex = random.nextInt(eligibleCopy.length);
      botsToChange.add(eligibleCopy.removeAt(randomIndex));
    }

    // Change names for selected bots
    for (final bot in botsToChange) {
      // Get current names to avoid duplicates
      final currentNames = bots.map((b) => b['username'] as String).toSet();

      // Find available names from the original pool
      final availableNames =
          allBotNames.where((name) => !currentNames.contains(name)).toList();

      if (availableNames.isNotEmpty) {
        final newName = availableNames[random.nextInt(availableNames.length)];
        bot['username'] = newName;
        bot['nameChangedWeek'] =
            DateTime.now()
                .millisecondsSinceEpoch; // Track when name was changed
      }
    }

    return bots;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white70;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Gold Trophy
      case 2:
        return Icons.military_tech; // Silver Medal
      case 3:
        return Icons.workspace_premium; // Bronze Medal
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Cozy pixel-like gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810), // Dark brown
              Color(0xFF3D2817), // Medium brown
              Color(0xFF4A3420), // Light brown
              Color(0xFF5C4129), // Tan
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Cozy pixel-style stars/dots background
            ...List.generate(40, (index) {
              final random = Random(index);
              return Positioned(
                left: random.nextDouble() * screenWidth,
                top: random.nextDouble() * screenHeight,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4B5).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A3420),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: const Color(0xFFFFE4B5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 0,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFFFFE4B5),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Global Leaderboard',
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE4B5),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                        Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                      ],
                    ),
                  ),

                  // Server Name Display - only show when online and server name exists
                  FutureBuilder<bool>(
                    future: _hasInternetConnection(),
                    builder: (context, snapshot) {
                      final hasInternet = snapshot.data ?? false;

                      if (!hasInternet || _serverName.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D2817),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: const Color(0xFFFFE4B5).withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 0,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.dns,
                                color: const Color(0xFFFFE4B5),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Connected to Server:',
                                      style: GoogleFonts.saira(
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          color: const Color(
                                            0xFFFFE4B5,
                                          ).withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _serverName,
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFE4B5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ONLINE',
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Stats Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2817),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: const Color(0xFFFFE4B5).withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 0,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('🤖', style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                'AI Based',
                                style: GoogleFonts.saira(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFFFFE4B5,
                                    ).withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '$_totalSystems',
                                style: GoogleFonts.saira(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFE4B5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Systems',
                                style: GoogleFonts.saira(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFFFFE4B5,
                                    ).withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '$_totalScore',
                                style: GoogleFonts.saira(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Score',
                                style: GoogleFonts.saira(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFFFFE4B5,
                                    ).withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Leaderboard List
                  Expanded(
                    child: FutureBuilder<Map<String, bool>>(
                      future: _getRequirements(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFE4B5),
                            ),
                          );
                        }

                        final requirements =
                            snapshot.data ??
                            {'hasInternet': false, 'hasDesignedSystem': false};
                        final hasInternet =
                            requirements['hasInternet'] ?? false;
                        final hasDesignedSystem =
                            requirements['hasDesignedSystem'] ?? false;

                        if (!hasInternet || !hasDesignedSystem) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D2817),
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 0,
                                    offset: const Offset(3, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 64,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Sorry you do not meet one of the following requirement:',
                                    style: GoogleFonts.saira(
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFE4B5),
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        hasInternet
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            hasInternet
                                                ? Colors.green
                                                : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '1) Internet connection',
                                          style: GoogleFonts.saira(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  hasInternet
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        hasDesignedSystem
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            hasDesignedSystem
                                                ? Colors.green
                                                : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '2) Should have designed at least one system',
                                          style: GoogleFonts.saira(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  hasDesignedSystem
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      _checkRequirementsAndLoad();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      'Check Again',
                                      style: GoogleFonts.saira(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFE4B5),
                              ),
                            )
                            : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    itemCount:
                                        _leaderboardData.length > 10
                                            ? 10
                                            : _leaderboardData.length,
                                    itemBuilder: (context, index) {
                                      final user = _leaderboardData[index];
                                      final isCurrentUser =
                                          user['isCurrentUser'] ?? false;
                                      final rank = user['rank'];

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              isCurrentUser
                                                  ? const Color(
                                                    0xFF4CAF50,
                                                  ).withOpacity(0.2)
                                                  : const Color(0xFF3D2817),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                          border: Border.all(
                                            color:
                                                isCurrentUser
                                                    ? const Color(
                                                      0xFF4CAF50,
                                                    ).withOpacity(0.5)
                                                    : const Color(
                                                      0xFFFFE4B5,
                                                    ).withOpacity(0.3),
                                            width: isCurrentUser ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 0,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Rank
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: _getRankColor(
                                                  rank,
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                border: Border.all(
                                                  color: _getRankColor(rank),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    _getRankIcon(rank),
                                                    color: _getRankColor(rank),
                                                    size: rank <= 3 ? 20 : 16,
                                                  ),
                                                  if (rank <= 3)
                                                    const SizedBox(height: 2),
                                                  Text(
                                                    '#$rank',
                                                    style: GoogleFonts.saira(
                                                      textStyle: TextStyle(
                                                        fontSize:
                                                            rank <= 3 ? 10 : 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: _getRankColor(
                                                          rank,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // User Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          user['username'],
                                                          style: GoogleFonts.saira(
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                    0xFFFFE4B5,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      if (isCurrentUser)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xFF4CAF50,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  0,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'YOU',
                                                            style: GoogleFonts.saira(
                                                              textStyle: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        getCountryDisplay(
                                                          user['country'],
                                                        ),
                                                        style: GoogleFonts.saira(
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color: const Color(
                                                              0xFFFFE4B5,
                                                            ).withOpacity(0.7),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        '${user['systemsDesigned']} systems',
                                                        style: GoogleFonts.saira(
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color: const Color(
                                                              0xFFFFE4B5,
                                                            ).withOpacity(0.7),
                                                          ),
                                                        ),
                                                      ),
                                                      if (user['averageScore'] >
                                                          0) ...[
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'Avg: ${user['averageScore']}',
                                                          style: GoogleFonts.saira(
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                  color:
                                                                      Colors
                                                                          .amber,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Score
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${user['score']}',
                                                  style: GoogleFonts.saira(
                                                    textStyle: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'points',
                                                  style: GoogleFonts.saira(
                                                    textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: const Color(
                                                        0xFFFFE4B5,
                                                      ).withOpacity(0.7),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Show "and X more..." indicator if there are more than 10 entries
                                if (_leaderboardData.length > 10)
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'and ${_leaderboardData.length - 10} more competitors...',
                                      style: GoogleFonts.saira(
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: const Color(
                                            0xFFFFE4B5,
                                          ).withOpacity(0.7),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
