import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'leaderboard_api_service.dart';
import 'design_manager.dart';
import 'system_database_manager.dart';

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
    required this.timestamp,
    this.isCurrentUser = false,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    return ChatMessage(
      odId: json['userId'] ?? '',
      odId2: json['messageId'] ?? '',
      username: json['username'] ?? 'Unknown',
      country: json['country'] ?? '🌍',
      message: json['message'] ?? '',
      designName: json['designName'],
      designNotes: json['designNotes'],
      designScore: json['designScore'],
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
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
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
  Timer? _refreshTimer;
  List<SavedDesign> _savedDesigns = [];
  SavedDesign? _selectedDesign;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadMessages();
    _loadSavedDesigns();
    // Auto-refresh messages every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadMessages(showLoading: false);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
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
      final notes = await SystemDatabaseManager.loadNotesFromSpecificDatabase(systemName);

      // Only add if there are notes saved
      if (notes != null && notes.isNotEmpty) {
        systemDesigns.add(
          SavedDesign(
            id: systemId,
            name: systemName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            canvasData:
                {}, // System designs don't have canvas data in local storage
            notes: notes,
          ),
        );
      }
    }

    setState(() {
      // Combine both lists - unlimited designs first, then system designs
      _savedDesigns = [...unlimitedDesigns, ...systemDesigns];
    });
  }

  Future<void> _loadMessages({bool showLoading = true}) async {
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
      if (_selectedDesign != null) {
        final systemId = _selectedDesign!.name.toLowerCase().replaceAll(
          ' ',
          '_',
        );
        designScore = prefs.getInt('best_score_$systemId') ?? 0;
      }

      final response = await http
          .post(
            Uri.parse('${LeaderboardApiConfig.baseUrl}/api/chat/send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'username': _currentUsername,
              'country': _currentCountry,
              'message':
                  message.isNotEmpty ? message : 'Check out my design! 🎨',
              'designName': _selectedDesign?.name,
              'designNotes': _selectedDesign?.notes,
              'designScore': designScore,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _messageController.clear();
        setState(() {
          _selectedDesign = null;
        });
        await _loadMessages(showLoading: false);
      } else {
        _showError('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      _showError('Failed to send message: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
                const Icon(Icons.architecture, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.designName!,
                    style: GoogleFonts.saira(
                      color: const Color(0xFFFFE4B5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Designer info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D2817),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          message.country,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'By ${message.username}',
                            style: GoogleFonts.saira(
                              color: const Color(0xFFFFE4B5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (message.designScore != null &&
                            message.designScore! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${message.designScore}/100',
                              style: GoogleFonts.saira(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Design notes
                  Text(
                    'Design Notes',
                    style: GoogleFonts.saira(
                      color: const Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D2817),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.3),
                      ),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(
                        message.designNotes ?? 'No notes provided',
                        style: GoogleFonts.robotoSlab(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.saira(color: const Color(0xFFFF6B35)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Avatar for other users
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
                  message.country,
                  style: const TextStyle(fontSize: 16),
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
                                const Icon(
                                  Icons.architecture,
                                  color: Color(0xFFFFE4B5),
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
