import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './system_detail_screen.dart';
import './view_demos_screen.dart';
import 'dart:math';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  final List<Map<String, dynamic>> tiers = const [
    {
      'tier': 'Tier 1: Foundational Systems',
      'description': 'Perfect for learning core, fundamental concepts.',
      'color': Color(0xFF4CAF50),
      'systems': [
        {
          'name': 'URL Shortener (e.g., TinyURL)',
          'concept':
              'The "Hello, World!" of system design. Teaches hashing, data modeling, and high-volume reads.',
          'keyProblems': [
            'Unique Hash Generation',
            'High-Availability Redirects',
            'Database Schema Design (SQL vs. NoSQL)',
            'Analytics Tracking',
          ],
        },
        {
          'name': 'Pastebin Service (e.g., Pastebin.com)',
          'concept':
              'Focuses on write-heavy systems, data storage, and content lifecycle management.',
          'keyProblems': [
            'Storing Large Text/Code Blocks',
            'Automatic Content Expiration',
            'Custom URL Generation',
            'High Write Throughput',
          ],
        },
        {
          'name': 'Web Crawler',
          'concept':
              'Introduces distributed systems, data pipelines, and asynchronous processing.',
          'keyProblems': [
            'URL Discovery & Crawl Queue Management',
            'HTML Parsing and Data Extraction',
            'Respecting robots.txt',
            'Distributed Task Processing (using queues like RabbitMQ/SQS)',
          ],
        },
      ],
    },
    {
      'tier': 'Tier 2: Web-Scale Giants',
      'description':
          'Covers systems that serve millions of users with complex features.',
      'color': Color(0xFF2196F3),
      'systems': [
        {
          'name': 'Social Media News Feed (e.g., Facebook, X/Twitter)',
          'concept':
              'The classic problem of balancing real-time data with algorithmic personalization at massive scale.',
          'keyProblems': [
            'Feed Generation (Fan-out on Write vs. Pull on Read)',
            'Algorithmic Timeline Ranking',
            'Multi-Layered Caching Strategy',
            'Real-time Updates for Likes/Comments',
          ],
        },
        {
          'name': 'Video Streaming Service (e.g., Netflix, YouTube)',
          'concept':
              'Tackles the challenges of storing and delivering massive binary files with low latency globally.',
          'keyProblems': [
            'Video Upload and Transcoding Pipeline',
            'Content Delivery Network (CDN) Design',
            'Adaptive Bitrate Streaming',
            'Personalized Recommendation Engine',
          ],
        },
        {
          'name': 'Ride-Sharing Service (e.g., Uber, Lyft)',
          'concept':
              'A masterclass in real-time geospatial systems, state management, and matchmaking.',
          'keyProblems': [
            'Real-time Geolocation Tracking',
            'Efficient Driver-Rider Matchmaking',
            'Geospatial Indexing (Quadtrees, Geohashing)',
            'Dynamic/Surge Pricing Logic',
          ],
        },
      ],
    },
    {
      'tier': 'Tier 3: Advanced & Specialized Systems',
      'description':
          'Dives into complex, niche problems for experienced engineers.',
      'color': Color(0xFFFF9800),
      'systems': [
        {
          'name': 'Collaborative Editor (e.g., Google Docs, Figma)',
          'concept':
              'Explores the difficult challenge of real-time conflict resolution and data synchronization.',
          'keyProblems': [
            'Concurrent Edit Management',
            'Conflict Resolution Algorithms (Operational Transforms vs. CRDTs)',
            'Low-Latency Communication (WebSockets)',
            'User Presence and Cursor Tracking',
          ],
        },
        {
          'name': 'Live Streaming Platform (e.g., Twitch, YouTube Live)',
          'concept':
              'Focuses on ultra-low latency video and building a chat system for millions of concurrent users.',
          'keyProblems': [
            'Low-Latency Video Protocols (WebRTC, LL-HLS)',
            'Highly Scalable Chat Architecture (WebSockets + Pub/Sub)',
            'Real-time Chat Moderation',
            'Stream Ingest and Distribution',
          ],
        },
        {
          'name': 'Global Gaming Leaderboard',
          'concept':
              'A performance-critical system that requires a deep understanding of data structures for real-time ranking.',
          'keyProblems': [
            'High-Performance Data Structure (e.g., Redis Sorted Sets)',
            'Scalability and Sharding',
            'Real-time Score Updates and Rank Calculation',
            'Handling Ties and Cheating',
          ],
        },
      ],
    },
  ];

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
                  // Header with back button
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Design a System',
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE4B5),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Choose a System to Design',
                      style: GoogleFonts.saira(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tiers List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: tiers.length,
                      itemBuilder: (context, index) {
                        final tier = tiers[index];
                        return _buildTierCard(tier, context);
                      },
                    ),
                  ),

                  // View Demos Button (at the bottom, after all tiers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2817),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: const Color(0xFFFFE4B5),
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const ViewDemosScreen(
                                      folderPath:
                                          '/home/shaken/quiz_game/lib/Flowchart, Diagrams',
                                    ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  color: Color(0xFFFFE4B5),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'View Demos',
                                  style: GoogleFonts.saira(
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFE4B5),
                                      fontFamily: 'monospace',
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }

  Widget _buildTierCard(Map<String, dynamic> tier, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3420),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: const Color(0xFFFFE4B5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xFFFFE4B5),
        collapsedIconColor: const Color(0xFFFFE4B5),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: tier['color'],
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tier['tier'],
                    style: GoogleFonts.saira(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFE4B5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                tier['description'],
                style: GoogleFonts.saira(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
        children: [
          ...tier['systems']
              .map<Widget>(
                (system) => _buildSystemCard(system, tier['color'], context),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSystemCard(
    Map<String, dynamic> system,
    Color tierColor,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2817),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: tierColor.withOpacity(0.7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => SystemDetailScreen(
                      systemName: system['name'],
                      concept: system['concept'],
                      keyProblems: List<String>.from(system['keyProblems']),
                      color: tierColor,
                    ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tierColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Icon(
                    Icons.settings_suggest,
                    color: tierColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        system['name'],
                        style: GoogleFonts.saira(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFE4B5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${system['keyProblems'].length} Key Problems',
                        style: GoogleFonts.saira(
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: tierColor.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFFE4B5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
