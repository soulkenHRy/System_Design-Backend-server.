import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'leaderboard_api_service.dart';
import 'design_manager.dart';
import 'system_database_manager.dart';
import 'unlimited_design_screen.dart';

/// A chat message in the World Chat
class ChatMessage {
  final String odId;
  final String odId2; // Unique message ID
  final String username;
  final String country;
  final String message;
  final String? designName;
  final String? designNotes;
  final int? designScore;
  final Map<String, dynamic>?
  designCanvas; // Canvas design data (nodes, connections)
  final DateTime timestamp;
  final bool isCurrentUser;

  ChatMessage({
    required this.odId,
    required this.odId2,
    required this.username,
    required this.country,
    required this.message,
    this.designName,
    this.designNotes,
    this.designScore,
    this.designCanvas,
    required this.timestamp,
    this.isCurrentUser = false,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // Parse canvas data from JSON string
    Map<String, dynamic>? canvasData;
    if (json['designCanvas'] != null && json['designCanvas'] is String) {
      try {
        canvasData = jsonDecode(json['designCanvas']) as Map<String, dynamic>;
      } catch (_) {
        canvasData = null;
      }
    }

    return ChatMessage(
      odId: json['userId'] ?? '',
      odId2: json['messageId'] ?? '',
      username: json['username'] ?? 'Unknown',
      country: json['country'] ?? '🌍',
      message: json['message'] ?? '',
      designName: json['designName'],
      designNotes: json['designNotes'],
      designScore: json['designScore'],
      designCanvas: canvasData,
      timestamp:
          json['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
              : DateTime.now(),
      isCurrentUser: currentUserId != null && json['userId'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': odId,
    'messageId': odId2,
    'username': username,
    'country': country,
    'message': message,
    'designName': designName,
    'designNotes': designNotes,
    'designScore': designScore,
    'designCanvas': designCanvas != null ? jsonEncode(designCanvas) : null,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  bool get hasCanvas => designCanvas != null && designCanvas!.isNotEmpty;
}

class WorldChatScreen extends StatefulWidget {
  const WorldChatScreen({super.key});

  @override
  State<WorldChatScreen> createState() => _WorldChatScreenState();
}

class _WorldChatScreenState extends State<WorldChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;
  String _currentUsername = 'Player';
  String _currentCountry = '🌍';
  IO.Socket? _socket;
  List<SavedDesign> _savedDesigns = [];
  SavedDesign? _selectedDesign;
  bool _hasAccess = false;
  bool _checkingAccess = true;

  @override
  void initState() {
    super.initState();
    _cleanupTempDesigns(); // Clean any leftover temp designs
    _checkAccess();
  }

  /// Clean up any temporary shared designs left from previous sessions
  Future<void> _cleanupTempDesigns() async {
    try {
      final designs = await DesignManager.getSavedDesigns();
      for (final design in designs) {
        if (design.id.startsWith('temp_shared_') ||
            design.id.startsWith('shared_')) {
          await DesignManager.deleteDesign(design.id);
          print('Cleaned up temp design: ${design.id}');
        }
      }
    } catch (e) {
      print('Error cleaning temp designs: $e');
    }
  }

  Future<void> _checkAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final totalBestScore = prefs.getInt('user_total_best_score') ?? 0;

    // Load designs to check if user has any
    final unlimitedDesigns = await DesignManager.getSavedDesigns();

    // Check system designs for notes
    bool hasSystemDesigns = false;
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
      final notes = await SystemDatabaseManager.loadNotesFromSpecificDatabase(
        systemName,
      );
      if (notes != null && notes.isNotEmpty) {
        hasSystemDesigns = true;
        break;
      }
    }

    final hasDesigns = unlimitedDesigns.isNotEmpty || hasSystemDesigns;
    final hasLeaderboardAccess = totalBestScore > 0;

    setState(() {
      _hasAccess = hasDesigns || hasLeaderboardAccess;
      _checkingAccess = false;
    });

    if (_hasAccess) {
      // Wait for user info to load before connecting
      await _loadUserInfo();
      _connectSocket();
      _loadSavedDesigns();
    }
  }

  /// Connect to the WebSocket server for real-time chat
  void _connectSocket() {
    _socket = IO.io(
      LeaderboardApiConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('🔌 Connected to chat WebSocket');
      // Request recent message history on connect
      _socket!.emit('requestHistory');
    });

    _socket!.on('chatHistory', (data) {
      final List<dynamic> messagesJson = data['messages'] ?? [];
      setState(() {
        _messages = messagesJson
            .map((json) => ChatMessage.fromJson(
                  json,
                  currentUserId: _currentUserId,
                ))
            .toList();
        _isLoading = false;
      });
      _scrollToBottom();
    });

    _socket!.on('newMessage', (data) {
      final msg = ChatMessage.fromJson(
        data as Map<String, dynamic>,
        currentUserId: _currentUserId,
      );
      setState(() {
        _messages.add(msg);
        // Keep client-side list trimmed to last 100
        if (_messages.length > 100) {
          _messages.removeAt(0);
        }
      });
      _scrollToBottom();
    });

    _socket!.on('chatError', (data) {
      print('Chat error: $data');
    });

    _socket!.onDisconnect((_) {
      print('❌ Disconnected from chat WebSocket');
    });

    _socket!.connect();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = await LeaderboardApiService.instance.getUserId();
    setState(() {
      _currentUsername = prefs.getString('userName') ?? 'Player';
      _currentCountry = prefs.getString('userCountry') ?? '🌍';
    });
  }

  Future<void> _loadSavedDesigns() async {
    // Load unlimited designs
    final unlimitedDesigns = await DesignManager.getSavedDesigns();

    // Load system design evaluations using SystemDatabaseManager
    final systemDesigns = <SavedDesign>[];
    final prefs = await SharedPreferences.getInstance();

    // All 9 system names from Design a System screen (must match exactly)
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

      // Load notes from the correct database using SystemDatabaseManager
      final notes = await SystemDatabaseManager.loadNotesFromSpecificDatabase(
        systemName,
      );

      // Load canvas data from SharedPreferences (key: design_${systemName})
      final canvasKey = 'design_$systemName';
      final canvasJsonString = prefs.getString(canvasKey);
      Map<String, dynamic> canvasData = {};

      if (canvasJsonString != null) {
        try {
          final parsed = jsonDecode(canvasJsonString) as Map<String, dynamic>;
          // Convert from {icons: [...], lines: [...]} to {droppedIcons: [...], drawnLines: [...]}
          canvasData = {
            'droppedIcons': parsed['icons'] ?? [],
            'drawnLines': parsed['lines'] ?? [],
          };
        } catch (_) {
          // Invalid JSON, skip
        }
      }

      // Add if there are notes OR canvas data saved
      if ((notes != null && notes.isNotEmpty) || canvasData.isNotEmpty) {
        systemDesigns.add(
          SavedDesign(
            id: systemId,
            name: systemName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            canvasData: canvasData,
            notes: notes ?? '',
          ),
        );
      }
    }

    setState(() {
      // Combine both lists - unlimited designs first, then system designs
      // Filter out duplicates by checking if a similar name already exists
      final allDesigns = <SavedDesign>[];
      final seenNames = <String>{};

      // Add unlimited designs first (user's custom + downloaded designs)
      for (final design in unlimitedDesigns) {
        // Extract base name (remove " (by username)" suffix for comparison)
        final baseName =
            design.name.replaceAll(RegExp(r'\s*\(by\s+[^)]+\)$'), '').trim();
        if (!seenNames.contains(baseName.toLowerCase())) {
          allDesigns.add(design);
          seenNames.add(baseName.toLowerCase());
        }
      }

      // Add system designs only if not already present
      for (final design in systemDesigns) {
        final baseName = design.name.toLowerCase();
        if (!seenNames.contains(baseName)) {
          allDesigns.add(design);
          seenNames.add(baseName);
        }
      }

      _savedDesigns = allDesigns;
    });
  }

  Future<void> _loadMessages({bool showLoading = true}) async {
    // Messages are now loaded via WebSocket (chatHistory event).
    // This method is kept as a fallback for manual refresh.
    if (_socket != null && _socket!.connected) {
      _socket!.emit('requestHistory');
      return;
    }

    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await http
          .get(Uri.parse('${LeaderboardApiConfig.baseUrl}/api/chat/messages'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> messagesJson = data['messages'] ?? [];

        setState(() {
          _messages =
              messagesJson
                  .map(
                    (json) => ChatMessage.fromJson(
                      json,
                      currentUserId: _currentUserId,
                    ),
                  )
                  .toList();
          _isLoading = false;
        });

        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading chat messages: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedDesign == null) return;

    setState(() => _isSending = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await LeaderboardApiService.instance.getUserId();

      // Get design score if sharing a design
      int? designScore;
      String? designCanvasJson;
      if (_selectedDesign != null) {
        final systemId = _selectedDesign!.name.toLowerCase().replaceAll(
          ' ',
          '_',
        );
        designScore = prefs.getInt('best_score_$systemId') ?? 0;

        // Include canvas data if available (limit size to prevent errors)
        if (_selectedDesign!.canvasData.isNotEmpty) {
          try {
            final simplifiedCanvas = _simplifyCanvasData(
              _selectedDesign!.canvasData,
            );
            final canvasJson = jsonEncode(simplifiedCanvas);
            if (canvasJson.length < 10000) {
              designCanvasJson = canvasJson;
            }
          } catch (e) {
            print('Error encoding canvas data: $e');
          }
        }
      }

      final messageData = {
        'userId': userId,
        'username': _currentUsername,
        'country': _currentCountry,
        'message': message.isNotEmpty ? message : 'Check out my design! 🎨',
        'designName': _selectedDesign?.name,
        'designNotes': _selectedDesign?.notes,
        'designScore': designScore,
      };

      if (designCanvasJson != null) {
        messageData['designCanvas'] = designCanvasJson;
      }

      if (_socket != null && _socket!.connected) {
        // Send via WebSocket
        _socket!.emit('sendMessage', messageData);
        _messageController.clear();
        setState(() {
          _selectedDesign = null;
        });
      } else {
        // Fallback to HTTP if socket is disconnected
        final response = await http
            .post(
              Uri.parse('${LeaderboardApiConfig.baseUrl}/api/chat/send'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(messageData),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200 || response.statusCode == 201) {
          _messageController.clear();
          setState(() {
            _selectedDesign = null;
          });
          await _loadMessages(showLoading: false);
        } else {
          _showError(
            'Failed to send message (${response.statusCode})',
          );
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      _showError(
        'Connection error: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e}',
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Simplify canvas data - icons and lines
  Map<String, dynamic> _simplifyCanvasData(Map<String, dynamic> canvasData) {
    final List<dynamic> icons =
        canvasData['droppedIcons'] ?? canvasData['icons'] ?? [];
    final List<dynamic> lines =
        canvasData['drawnLines'] ?? canvasData['lines'] ?? [];

    // Keep all icon data needed for rendering (limit to 50 icons)
    final simplifiedIcons =
        icons.take(50).map((icon) {
          return {
            'x': (icon['positionX'] as num?)?.round() ?? 0,
            'y': (icon['positionY'] as num?)?.round() ?? 0,
            'n': icon['name']?.toString() ?? '',
            'c': icon['category']?.toString() ?? '',
            'ic': icon['iconCodePoint'] ?? 0,
            'if': icon['iconFontFamily']?.toString() ?? 'MaterialIcons',
          };
        }).toList();

    // Keep line connections (limit to 100 lines)
    final simplifiedLines =
        lines.take(100).map((line) {
          return {
            'x1': (line['startX'] as num?)?.round() ?? 0,
            'y1': (line['startY'] as num?)?.round() ?? 0,
            'x2': (line['endX'] as num?)?.round() ?? 0,
            'y2': (line['endY'] as num?)?.round() ?? 0,
            'cl': line['colorValue'] ?? line['color'] ?? 0xFF2196F3,
          };
        }).toList();

    return {'i': simplifiedIcons, 'l': simplifiedLines};
  }

  void _showDesignPicker() {
    if (_savedDesigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No saved designs or notes found. Create a design first!',
          ),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C1810),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Design to Share',
                  style: GoogleFonts.saira(
                    color: const Color(0xFFFFE4B5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose from your unlimited designs or system designs',
                  style: GoogleFonts.robotoSlab(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _savedDesigns.length,
                    itemBuilder: (context, index) {
                      final design = _savedDesigns[index];
                      final isSystemDesign = design.canvasData.isEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D2817),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFE4B5).withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  isSystemDesign
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isSystemDesign ? Icons.menu_book : Icons.draw,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  design.name,
                                  style: GoogleFonts.saira(
                                    color: const Color(0xFFFFE4B5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSystemDesign
                                          ? const Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.2)
                                          : const Color(
                                            0xFFFF6B35,
                                          ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSystemDesign
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFFF6B35),
                                  ),
                                ),
                                child: Text(
                                  isSystemDesign ? 'System' : 'Custom',
                                  style: GoogleFonts.robotoSlab(
                                    color:
                                        isSystemDesign
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFFF6B35),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            design.notes.isNotEmpty
                                ? design.notes.substring(
                                      0,
                                      design.notes.length > 50
                                          ? 50
                                          : design.notes.length,
                                    ) +
                                    '...'
                                : 'No notes',
                            style: GoogleFonts.robotoSlab(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedDesign = design;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showDesignDetails(ChatMessage message) {
    if (message.designName == null) return;

    // Show confirmation dialog to download the design
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C1810),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
            ),
            title: Row(
              children: [
                const Icon(Icons.download_rounded, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Download Design',
                    style: GoogleFonts.saira(
                      color: const Color(0xFFFFE4B5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Design info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2817),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.architecture,
                            color: Color(0xFFFF6B35),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.designName!,
                              style: GoogleFonts.saira(
                                color: const Color(0xFFFFE4B5),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                message.username.isNotEmpty
                                    ? message.username[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.saira(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'By ${message.username}',
                            style: GoogleFonts.saira(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          if (message.designScore != null &&
                              message.designScore! > 0) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${message.designScore}/100',
                                style: GoogleFonts.saira(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Download this design to your saved designs and open it in the canvas editor?',
                  style: GoogleFonts.robotoSlab(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (message.hasCanvas) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Includes canvas diagram',
                        style: GoogleFonts.robotoSlab(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.saira(color: Colors.white54),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadAndOpenDesign(message);
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Download & Open',
                  style: GoogleFonts.saira(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Downloads the shared design and opens it in the canvas editor (temporary view)
  Future<void> _downloadAndOpenDesign(ChatMessage message) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C1810),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFF6B35)),
                const SizedBox(width: 16),
                Text(
                  'Opening design...',
                  style: GoogleFonts.saira(color: Colors.white),
                ),
              ],
            ),
          ),
    );

    try {
      // Decompress canvas data if available
      Map<String, dynamic> canvasData = {};
      if (message.hasCanvas && message.designCanvas != null) {
        canvasData = _decompressCanvasData(message.designCanvas!);
      }

      // Create a temporary SavedDesign (with special prefix for cleanup)
      final designId = 'temp_shared_${DateTime.now().millisecondsSinceEpoch}';
      final savedDesign = SavedDesign(
        id: designId,
        name: '${message.designName} (by ${message.username})',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        canvasData: canvasData,
        notes: message.designNotes ?? '',
      );

      // Temporarily save the design (needed for canvas screen to work)
      await DesignManager.saveDesign(savedDesign);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to the design editor and delete after returning
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => UnlimitedDesignScreen(initialDesign: savedDesign),
          ),
        );

        // Delete the temporary design after user finishes viewing
        await DesignManager.deleteDesign(designId);
        print('Deleted temporary shared design: $designId');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to open design: $e',
                    style: GoogleFonts.saira(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Decompresses the canvas data - icons and lines
  Map<String, dynamic> _decompressCanvasData(Map<String, dynamic> compressed) {
    final List<dynamic> icons = [];
    final List<dynamic> lines = [];

    // Decompress icons (i -> icons format expected by canvas)
    if (compressed['i'] != null) {
      for (final icon in compressed['i']) {
        icons.add({
          'positionX': (icon['x'] ?? 0).toDouble(),
          'positionY': (icon['y'] ?? 0).toDouble(),
          'name': icon['n'] ?? '',
          'category': icon['c'] ?? '',
          'iconCodePoint': icon['ic'] ?? 0xe156,
          'iconFontFamily': icon['if'] ?? 'MaterialIcons',
        });
      }
    }
    // Also support old format (droppedIcons)
    if (compressed['droppedIcons'] != null) {
      for (final icon in compressed['droppedIcons']) {
        icons.add({
          'positionX': (icon['positionX'] ?? icon['x'] ?? 0).toDouble(),
          'positionY': (icon['positionY'] ?? icon['y'] ?? 0).toDouble(),
          'name': icon['name'] ?? icon['n'] ?? '',
          'category': icon['category'] ?? icon['c'] ?? '',
          'iconCodePoint': icon['iconCodePoint'] ?? icon['ic'] ?? 0xe156,
          'iconFontFamily':
              icon['iconFontFamily'] ?? icon['if'] ?? 'MaterialIcons',
        });
      }
    }

    // Decompress lines (l -> lines format expected by canvas)
    if (compressed['l'] != null) {
      for (final line in compressed['l']) {
        lines.add({
          'startX': (line['x1'] ?? 0).toDouble(),
          'startY': (line['y1'] ?? 0).toDouble(),
          'endX': (line['x2'] ?? 0).toDouble(),
          'endY': (line['y2'] ?? 0).toDouble(),
          'colorValue': line['cl'] ?? 0xFF2196F3,
        });
      }
    }
    // Also support old format (drawnLines)
    if (compressed['drawnLines'] != null) {
      for (final line in compressed['drawnLines']) {
        lines.add({
          'startX': (line['startX'] ?? line['x1'] ?? 0).toDouble(),
          'startY': (line['startY'] ?? line['y1'] ?? 0).toDouble(),
          'endX': (line['endX'] ?? line['x2'] ?? 0).toDouble(),
          'endY': (line['endY'] ?? line['y2'] ?? 0).toDouble(),
          'colorValue':
              line['colorValue'] ?? line['color'] ?? line['cl'] ?? 0xFF2196F3,
        });
      }
    }

    // Return in format expected by canvas screen
    return {'icons': icons, 'lines': lines};
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking access
    if (_checkingAccess) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2C1810),
                Color(0xFF3D2817),
                Color(0xFF4A3420),
                Color(0xFF5C4129),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
          ),
        ),
      );
    }

    // Show access denied message if user hasn't designed anything
    if (!_hasAccess) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2C1810),
                Color(0xFF3D2817),
                Color(0xFF4A3420),
                Color(0xFF5C4129),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFFE4B5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Access denied content
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D2817),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'World Chat Locked',
                            style: GoogleFonts.saira(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFE4B5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'To access World Chat, you need to:\n\n'
                            '• Complete at least one system design\n'
                            '• Get your design evaluated by the AI\n\n'
                            'This ensures you have something to share with the community!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoSlab(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.design_services),
                            label: const Text('Go Design Something'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810),
              Color(0xFF3D2817),
              Color(0xFF4A3420),
              Color(0xFF5C4129),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFFF6B35).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFFFE4B5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.public,
                      color: Color(0xFFFF6B35),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'World Chat',
                            style: GoogleFonts.saira(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFE4B5),
                            ),
                          ),
                          Text(
                            'Share your designs with the world',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _loadMessages(),
                      icon: const Icon(Icons.refresh, color: Color(0xFFFFE4B5)),
                    ),
                  ],
                ),
              ),

              // Messages list
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF6B35),
                          ),
                        )
                        : _messages.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: GoogleFonts.saira(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Be the first to share your design!',
                                style: GoogleFonts.robotoSlab(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return _buildMessageBubble(message);
                          },
                        ),
              ),

              // Selected design preview
              if (_selectedDesign != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2817),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF6B35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.architecture, color: Color(0xFFFF6B35)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sharing: ${_selectedDesign!.name}',
                          style: GoogleFonts.saira(
                            color: const Color(0xFFFFE4B5),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _selectedDesign = null);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFFFFE4B5),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

              // Message input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFFF6B35).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Attach design button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2817),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFE4B5),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _showDesignPicker,
                        icon: const Icon(
                          Icons.attach_file,
                          color: Color(0xFFFFE4B5),
                        ),
                        tooltip: 'Attach Design',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Message input
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.robotoSlab(
                          color: const Color(0xFFFFE4B5),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.robotoSlab(
                            color: Colors.white38,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF3D2817),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFE4B5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFE4B5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF6B35),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 1,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _isSending ? null : _sendMessage,
                        icon:
                            _isSending
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isCurrentUser;
    final hasDesign = message.designName != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            // Avatar for other users - show first letter of username
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF3D2817),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF6B35), width: 2),
              ),
              child: Center(
                child: Text(
                  message.username.isNotEmpty
                      ? message.username[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.saira(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFE4B5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Username and time
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${message.username} • ${_formatTime(message.timestamp)}',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ),
                // Message bubble
                GestureDetector(
                  onTap: hasDesign ? () => _showDesignDetails(message) : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? const Color(0xFFFF6B35).withOpacity(0.8)
                              : const Color(0xFF3D2817),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight:
                            isMe ? Radius.zero : const Radius.circular(16),
                      ),
                      border: Border.all(
                        color:
                            isMe
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFFFFE4B5).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Design card if shared
                        if (hasDesign) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C1810).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFE4B5).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  message.hasCanvas
                                      ? Icons.grid_view
                                      : Icons.architecture,
                                  color:
                                      message.hasCanvas
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFFFE4B5),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.designName!,
                                        style: GoogleFonts.saira(
                                          color: const Color(0xFFFFE4B5),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (message.hasCanvas)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 1,
                                                  ),
                                              margin: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF4CAF50,
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '📐 Canvas',
                                                style: GoogleFonts.robotoSlab(
                                                  color: const Color(
                                                    0xFF4CAF50,
                                                  ),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          if (message.designScore != null &&
                                              message.designScore! > 0)
                                            Text(
                                              'Score: ${message.designScore}/100',
                                              style: GoogleFonts.robotoSlab(
                                                color: Colors.white60,
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFFFFE4B5),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Message text
                        Text(
                          message.message,
                          style: GoogleFonts.robotoSlab(
                            color:
                                isMe ? Colors.white : const Color(0xFFFFE4B5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            // Avatar for current user
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFE4B5), width: 2),
              ),
              child: Center(
                child: Text(
                  _currentCountry,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
