// Pastebin System - Canvas Design Data
// Contains predefined system designs using available canvas icons

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined Pastebin system designs for the canvas
class PastebinCanvasDesigns {
  static Map<String, dynamic> _createIcon(
    String name,
    String category,
    double x,
    double y, {
    String? id,
  }) {
    final iconData = SystemDesignIcons.getIcon(name);
    return {
      'id': id ?? name,
      'name': name,
      'iconCodePoint': iconData?.codePoint ?? Icons.help.codePoint,
      'iconFontFamily': iconData?.fontFamily ?? 'MaterialIcons',
      'category': category,
      'positionX': x,
      'positionY': y,
    };
  }

  static Map<String, dynamic> _createConnection(
    int from,
    int to, {
    String? label,
    int color = 0xFF795548,
    double strokeWidth = 2.0,
  }) {
    return {
      'fromIconIndex': from,
      'toIconIndex': to,
      'label': label,
      'color': color,
      'strokeWidth': strokeWidth,
    };
  }

  // DESIGN 1: Basic Pastebin
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic Pastebin',
    'description': 'Simple text sharing with unique URLs',
    'explanation': '''
## Basic Pastebin Architecture

### What This System Does
Users paste text/code, get a shareable link (paste.io/abc123), and anyone with the link can view it.

### Icons Explained

**Web Browser** - The user's browser where they type or view pastes

**API Gateway** - Entry point that receives all requests, validates them, and routes to the right service

**Content Storage** - Saves and retrieves paste content, handles the core create/read logic

**Configuration Service** - Generates unique short IDs (abc123) for each paste URL

**SQL Database** - Stores all paste data: content, creation time, expiration, view count

**Scheduler** - Runs cleanup jobs to delete expired pastes automatically

### How They Work Together

1. User types text in **Web Browser** → clicks "Create Paste"
2. Request goes to **API Gateway** → validates input, checks rate limits
3. **API Gateway** forwards to **Content Storage** service
4. **Content Storage** asks **Configuration Service** for a unique ID
5. **Content Storage** saves paste to **SQL Database**
6. User gets back URL: paste.io/abc123
7. **Scheduler** runs every hour, finds expired pastes, deletes them from **SQL Database**

### Why This Design Works
- Simple and easy to understand
- Each component has one job
- Database handles all storage
- Scheduler keeps storage clean
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 250, 350),
      _createIcon('Content Storage', 'Application Services', 450, 350),
      _createIcon('Configuration Service', 'System Utilities', 450, 550),
      _createIcon('SQL Database', 'Database & Storage', 650, 350),
      _createIcon('Scheduler', 'System Utilities', 650, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Create Paste'),
      _createConnection(1, 2, label: 'Process'),
      _createConnection(2, 3, label: 'Generate ID'),
      _createConnection(2, 4, label: 'Store'),
      _createConnection(5, 4, label: 'Delete Expired'),
    ],
  };

  // DESIGN 2: Scalable Pastebin
  static Map<String, dynamic> get scalableArchitecture => {
    'name': 'Scalable Pastebin',
    'description': 'High-traffic pastebin with caching and CDN',
    'explanation': '''
## Scalable Pastebin Architecture

### What This System Does
Handles viral pastes with millions of views using caching and global distribution.

### Icons Explained

**Web Browser** - User accessing the paste from anywhere in the world

**CDN** - Content Delivery Network with servers worldwide, caches popular pastes close to users

**Global Load Balancer** - Distributes traffic across multiple servers, prevents overload

**Content Storage** - Core service that manages paste creation and retrieval

**Redis Cache** - Super-fast in-memory storage, holds frequently accessed pastes

**SQL Database** - Permanent storage for all pastes

### How They Work Together

1. User in Tokyo requests paste.io/abc123
2. **CDN** checks if it has a cached copy nearby → if yes, returns instantly (5ms)
3. If not cached, request goes to **Global Load Balancer**
4. **Load Balancer** picks a healthy server running **Content Storage**
5. **Content Storage** checks **Redis Cache** first → if found, returns (10ms)
6. If not in cache, fetches from **SQL Database** (50ms)
7. Response cached in **Redis Cache** and **CDN** for next requests

### Why This Design Works
- CDN serves 90%+ of reads from edge locations
- Redis Cache handles the rest without hitting database
- Database only touched for new pastes or rare reads
- Can handle millions of requests per second
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('CDN', 'Networking', 200, 350),
      _createIcon('Global Load Balancer', 'Networking', 400, 350),
      _createIcon('Content Storage', 'Application Services', 600, 250),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 450),
      _createIcon('SQL Database', 'Database & Storage', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Request'),
      _createConnection(1, 2, label: 'Cache Miss'),
      _createConnection(2, 3, label: 'Route'),
      _createConnection(3, 4, label: 'Check Cache'),
      _createConnection(4, 5, label: 'Cache Miss'),
      _createConnection(3, 5, label: 'Store'),
    ],
  };

  // DESIGN 3: Content Moderation
  static Map<String, dynamic> get moderationArchitecture => {
    'name': 'Content Moderation',
    'description': 'Detecting and removing harmful content',
    'explanation': '''
## Content Moderation Architecture

### What This System Does
Automatically scans pastes for malware, phishing, and illegal content before they go public.

### Icons Explained

**Web Browser** - User submitting a paste

**API Gateway** - Receives the paste and sends it for scanning before storing

**Security Scanner** (first) - Main scanning coordinator that runs all checks

**Security Scanner** (top) - Checks for malware signatures and virus patterns

**Fraud Detection** - Detects personal info (credit cards, SSN) and phishing attempts

**Security Scanner** (bottom) - Scans URLs for known malicious domains

**Message Queue** - Holds flagged pastes for human moderators to review

**Authorization** - Blocks/bans users who repeatedly post harmful content

### How They Work Together

1. User submits paste through **Web Browser**
2. **API Gateway** intercepts and forwards to **Security Scanner**
3. **Security Scanner** runs three parallel checks:
   - Top scanner looks for malware code
   - **Fraud Detection** checks for personal data leaks
   - Bottom scanner validates all URLs
4. If any check fails, paste goes to **Message Queue** for human review
5. Repeat offenders get blocked by **Authorization** service
6. Clean pastes proceed to storage

### Why This Design Works
- Multiple scanners catch different threat types
- Humans review edge cases (reduces false positives)
- Bad actors get banned permanently
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Security Scanner', 'Security,Monitoring', 400, 350),
      _createIcon('Security Scanner', 'Security,Monitoring', 600, 200),
      _createIcon('Fraud Detection', 'Security,Monitoring', 600, 350),
      _createIcon('Security Scanner', 'Security,Monitoring', 600, 500),
      _createIcon('Message Queue', 'Application Services', 800, 350),
      _createIcon('Authorization', 'Security,Monitoring', 800, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Submit'),
      _createConnection(1, 2, label: 'Scan'),
      _createConnection(2, 3, label: 'Check'),
      _createConnection(2, 4, label: 'Check'),
      _createConnection(2, 5, label: 'Check'),
      _createConnection(3, 6, label: 'Flag'),
      _createConnection(4, 6, label: 'Flag'),
      _createConnection(6, 7, label: 'Ban'),
    ],
  };

  // DESIGN 4: Syntax Highlighting System
  static Map<String, dynamic> get syntaxHighlightingArchitecture => {
    'name': 'Syntax Highlighting System',
    'description': 'Server and client-side code formatting',
    'explanation': '''
## Syntax Highlighting System Architecture

### What This System Does
Makes code pastes readable with colored syntax - keywords blue, strings green, comments gray.

### Icons Explained

**Web Browser** - Where user views the formatted code

**Content Storage** - Retrieves the raw paste content

**Analytics Service** (top) - Detects programming language from code patterns

**Stream Processor** - Breaks code into tokens (keywords, strings, operators)

**Analytics Service** (bottom) - Applies colors to each token type

**Configuration Service** - Provides color themes (dark mode, light mode)

**Cache** - Stores already-highlighted pastes to avoid re-processing

### How They Work Together

1. User opens paste in **Web Browser**
2. **Content Storage** fetches the raw code
3. **Analytics Service** (top) detects language: "This is JavaScript"
4. **Stream Processor** tokenizes: function → KEYWORD, "hello" → STRING
5. **Analytics Service** (bottom) applies colors to tokens
6. **Configuration Service** provides the color theme
7. Result cached in **Cache** for next viewer
8. Colored HTML sent to **Web Browser**

### Why This Design Works
- Language detection handles 100+ languages
- Tokenizer understands syntax rules
- Themes let users pick their colors
- Cache avoids re-processing popular pastes
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('Content Storage', 'Application Services', 250, 350),
      _createIcon('Analytics Service', 'Data Processing', 450, 200),
      _createIcon('Stream Processor', 'Data Processing', 450, 350),
      _createIcon('Analytics Service', 'Application Services', 450, 500),
      _createIcon('Configuration Service', 'Application Services', 650, 350),
      _createIcon('Cache', 'Caching,Performance', 650, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'View Paste'),
      _createConnection(1, 2, label: 'Detect'),
      _createConnection(2, 3, label: 'Tokenize'),
      _createConnection(3, 4, label: 'Highlight'),
      _createConnection(4, 5, label: 'Theme'),
      _createConnection(4, 6, label: 'Cache'),
      _createConnection(5, 0, label: 'Render'),
    ],
  };

  // DESIGN 5: Private and Encrypted Pastes
  static Map<String, dynamic> get encryptedArchitecture => {
    'name': 'Private and Encrypted Pastes',
    'description': 'Password protection and end-to-end encryption',
    'explanation': '''
## Private and Encrypted Pastes Architecture

### What This System Does
Protects sensitive pastes with passwords or encryption so even the server cannot read them.

### Icons Explained

**Web Browser** - Where encryption/decryption happens (client-side)

**Security Gateway** - Handles client-side encryption before sending to server

**API Gateway** - Receives encrypted data, never sees the actual content

**Content Storage** - Stores encrypted blobs, cannot decrypt them

**Authentication** - Hashes passwords for password-protected pastes

**Expiration Service** - Handles "burn after reading" - deletes after first view

**SQL Database** - Stores encrypted content and password hashes

### How They Work Together

1. User types paste in **Web Browser** and sets password
2. **Security Gateway** encrypts content in browser, generates key
3. Encrypted blob sent through **API Gateway** to **Content Storage**
4. **Authentication** hashes the password (never stores plaintext)
5. Data stored in **SQL Database** (server only has encrypted blob)
6. For "burn after reading", **Expiration Service** deletes after first view

### Why This Design Works
- Encryption happens in browser (server never sees plaintext)
- Password hashing means even admins cannot see passwords
- Burn after reading guarantees single recipient
- Key in URL fragment never reaches server
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('Security Gateway', 'Security,Monitoring', 200, 250),
      _createIcon('API Gateway', 'Networking', 200, 450),
      _createIcon('Content Storage', 'Application Services', 400, 350),
      _createIcon('Authentication', 'Security,Monitoring', 600, 250),
      _createIcon('Expiration Service', 'Application Services', 600, 450),
      _createIcon('SQL Database', 'Database & Storage', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Encrypt'),
      _createConnection(1, 2, label: 'Send Blob'),
      _createConnection(2, 3, label: 'Store'),
      _createConnection(3, 4, label: 'Hash Pass'),
      _createConnection(3, 5, label: 'Burn Flag'),
      _createConnection(3, 6, label: 'Store'),
    ],
  };

  // DESIGN 6: API and Integrations
  static Map<String, dynamic> get apiArchitecture => {
    'name': 'API and Integrations',
    'description': 'Developer API for programmatic paste creation',
    'explanation': '''
## API and Integrations Architecture

### What This System Does
Lets developers create pastes from CLI tools, IDE plugins, and apps using a REST API.

### Icons Explained

**Desktop Client** (top) - CLI tool (command line interface)

**Desktop Client** (bottom) - IDE plugin (VS Code, IntelliJ)

**API Gateway** - Receives all API requests, routes them to services

**Authentication** - Validates API keys (pk_live_abc123...)

**Rate Limiter** - Limits requests per minute to prevent abuse

**Content Storage** - Creates and stores pastes

**Metrics Collector** - Logs every API call for billing and analytics

**Notification Service** - Sends webhooks when pastes are created/viewed

### How They Work Together

1. Developer's **Desktop Client** (CLI or IDE) makes API call
2. **API Gateway** receives request
3. **Authentication** verifies API key is valid
4. **Rate Limiter** checks if under limit (60 req/min free, 1000 paid)
5. If allowed, **Content Storage** creates the paste
6. **Metrics Collector** logs the request for billing
7. **Notification Service** sends webhook to developer's server (optional)

### Why This Design Works
- API keys identify who is making requests
- Rate limiting prevents abuse and ensures fair usage
- Usage tracking enables pay-per-use billing
- Webhooks enable real-time integrations
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 250),
      _createIcon('Desktop Client', 'Client & Interface', 50, 450),
      _createIcon('API Gateway', 'Networking', 250, 350),
      _createIcon('Authentication', 'Security,Monitoring', 450, 200),
      _createIcon('Rate Limiter', 'Networking', 450, 350),
      _createIcon('Content Storage', 'Application Services', 450, 500),
      _createIcon('Metrics Collector', 'Data Processing', 650, 350),
      _createIcon('Notification Service', 'Message Systems', 850, 350),
    ],
    'connections': [
      _createConnection(0, 2, label: 'API Call'),
      _createConnection(1, 2, label: 'API Call'),
      _createConnection(2, 3, label: 'Verify Key'),
      _createConnection(2, 4, label: 'Check Rate'),
      _createConnection(4, 5, label: 'Process'),
      _createConnection(5, 6, label: 'Log'),
      _createConnection(5, 7, label: 'Notify'),
    ],
  };

  // DESIGN 7: Search and Discovery
  static Map<String, dynamic> get searchArchitecture => {
    'name': 'Search and Discovery',
    'description': 'Finding public pastes by content or metadata',
    'explanation': '''
## Search and Discovery Architecture

### What This System Does
Lets users search public pastes by content, title, or tags. Shows trending pastes on homepage.

### Icons Explained

**Web Browser** - User searching for pastes

**API Gateway** - Routes search queries to the right service

**Search Engine** (main) - Handles search queries, ranks results by relevance

**Search Engine** (top right) - The search index storing all indexed paste content

**Analytics Engine** - Calculates trending pastes based on views/time

**Configuration Service** - Manages categories and browse filters

**Search Engine** (bottom) - Indexer that adds new pastes to the search index

### How They Work Together

1. User types search in **Web Browser**: "python sort algorithm"
2. Query goes through **API Gateway** to **Search Engine**
3. **Search Engine** queries the **Search Engine** index for matches
4. Results ranked by: title match, content match, recency, popularity
5. **Analytics Engine** adds trending boost (viral pastes rank higher)
6. **Configuration Service** allows filtering by category (syntax, tags)
7. When new pastes are created, bottom **Search Engine** indexes them

### Why This Design Works
- Full-text search finds content inside pastes
- Trending algorithm surfaces popular content
- Categories help users browse by topic
- Indexer keeps search up-to-date
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Search Engine', 'Application Services', 400, 350),
      _createIcon('Search Engine', 'Database & Storage', 600, 250),
      _createIcon('Analytics Engine', 'Data Processing', 600, 450),
      _createIcon('Configuration Service', 'Application Services', 800, 350),
      _createIcon('Search Engine', 'Data Processing', 400, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Search'),
      _createConnection(1, 2, label: 'Query'),
      _createConnection(2, 3, label: 'Search'),
      _createConnection(2, 4, label: 'Trending'),
      _createConnection(4, 5, label: 'Categories'),
      _createConnection(6, 3, label: 'Index'),
    ],
  };

  // DESIGN 8: Analytics and Metrics
  static Map<String, dynamic> get analyticsArchitecture => {
    'name': 'Analytics and Metrics',
    'description': 'Tracking paste views, referrers, and usage patterns',
    'explanation': '''
## Analytics and Metrics Architecture

### What This System Does
Tracks how many views each paste gets, where visitors come from, and when they view.

### Icons Explained

**Web Browser** - Viewer accessing a paste

**Metrics Collector** - Captures every view event (paste ID, time, referrer, country)

**Message Queue** - Buffers events for async processing (doesn't slow page load)

**Stream Processor** - Updates real-time counters (total views, views this hour)

**Batch Processor** - Runs nightly for complex analytics (unique visitors, trends)

**Time Series Database** - Stores metrics over time (views per hour/day/month)

**Analytics Service** - Serves dashboard showing charts and graphs

### How They Work Together

1. User views paste in **Web Browser**
2. **Metrics Collector** captures: paste ID, timestamp, referrer, country
3. Event published to **Message Queue** (async, fast response)
4. **Stream Processor** updates live counters immediately
5. **Batch Processor** runs hourly/daily for deeper analysis
6. Both store results in **Time Series Database**
7. Paste owner views **Analytics Service** dashboard

### Why This Design Works
- Async processing keeps page loads fast
- Real-time counts available instantly
- Batch processing handles complex analytics
- Time series DB efficiently stores metrics over time
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('Metrics Collector', 'Data Processing', 250, 350),
      _createIcon('Message Queue', 'Message Systems', 450, 350),
      _createIcon('Stream Processor', 'Data Processing', 650, 250),
      _createIcon('Batch Processor', 'Data Processing', 650, 450),
      _createIcon('Time Series Database', 'Database & Storage', 850, 350),
      _createIcon('Analytics Service', 'Application Services', 850, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'View Event'),
      _createConnection(1, 2, label: 'Publish'),
      _createConnection(2, 3, label: 'Stream'),
      _createConnection(2, 4, label: 'Batch'),
      _createConnection(3, 5, label: 'Store'),
      _createConnection(4, 5, label: 'Store'),
      _createConnection(5, 6, label: 'Query'),
    ],
  };

  // DESIGN 9: Storage Optimization
  static Map<String, dynamic> get storageArchitecture => {
    'name': 'Storage Optimization',
    'description': 'Compression, deduplication, and tiered storage',
    'explanation': '''
## Storage Optimization Architecture

### What This System Does
Saves storage costs by compressing pastes, avoiding duplicates, and moving old data to cheaper storage.

### Icons Explained

**Content Storage** - Receives new pastes for storage

**Batch Processor** - Compresses paste content (10KB → 2KB)

**Duplicate Detection** - Checks if identical content already exists

**Configuration Service** - Tier manager that decides where to store data

**Object Storage** (Hot) - Fast SSD storage for recent/popular pastes

**Object Storage** (Warm) - Slower HDD for older but occasionally accessed

**Object Storage** (Cold) - Cheap archive for rarely accessed old pastes

**Metrics Collector** - Tracks access patterns to decide tier placement

### How They Work Together

1. New paste arrives at **Content Storage**
2. **Batch Processor** compresses content (saves 60-80% space)
3. **Duplicate Detection** hashes content - if already exists, just reference it
4. **Configuration Service** decides tier based on age/popularity
5. New/popular → **Hot Storage** (fast, expensive)
6. Older → **Warm Storage** (medium speed, cheaper)
7. Old/unused → **Cold Storage** (slow, very cheap)
8. **Metrics Collector** watches access patterns and updates tier decisions

### Why This Design Works
- Compression: 5x space savings
- Deduplication: Identical pastes stored once
- Tiering: 75% cost reduction by using appropriate storage
''',
    'icons': [
      _createIcon('Content Storage', 'Application Services', 50, 350),
      _createIcon('Batch Processor', 'Data Processing', 250, 250),
      _createIcon('Duplicate Detection', 'Data Processing', 250, 450),
      _createIcon('Configuration Service', 'System Utilities', 450, 350),
      _createIcon('Object Storage', 'Database & Storage', 650, 200, id: 'Hot'),
      _createIcon('Object Storage', 'Database & Storage', 650, 350, id: 'Warm'),
      _createIcon('Object Storage', 'Database & Storage', 650, 500, id: 'Cold'),
      _createIcon('Metrics Collector', 'Data Processing', 850, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Compress'),
      _createConnection(0, 2, label: 'Dedup'),
      _createConnection(1, 3, label: 'Store'),
      _createConnection(2, 3, label: 'Check'),
      _createConnection(3, 4, label: 'Hot'),
      _createConnection(3, 5, label: 'Warm'),
      _createConnection(3, 6, label: 'Cold'),
      _createConnection(7, 3, label: 'Tier'),
    ],
  };

  // DESIGN 10: Complete Pastebin System
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete Pastebin System',
    'description': 'Full-featured pastebin with all components',
    'explanation': '''
## Complete Pastebin System Architecture

### What This System Does
Production-ready Pastebin with all features: scalable storage, moderation, API, search, and analytics.

### Icons Explained

**Web Browser** - Users creating/viewing pastes via website

**Desktop Client** - CLI tools and IDE plugins using the API

**CDN** - Caches popular pastes at edge servers worldwide

**API Gateway** - Entry point for all requests, routes to services

**Rate Limiter** - Prevents abuse by limiting requests per user

**Content Storage** - Core service that creates and retrieves pastes

**Content Moderation** - Scans for malware, spam, illegal content

**Search Engine** - Indexes pastes for full-text search

**Redis Cache** - Fast in-memory cache for frequently accessed pastes

**SQL Database** - Stores paste metadata and content

**Object Storage** - Stores large paste content cheaply

**Analytics Engine** - Tracks views, generates statistics

### How They Work Together

1. **Web Browser** users request through **CDN** (cache hit = instant response)
2. **Desktop Client** (API users) connect via **API Gateway**
3. **Rate Limiter** checks usage limits before processing
4. **Content Storage** handles create/read, uses **Content Moderation** for safety
5. **Search Engine** enables finding pastes by content
6. **Redis Cache** speeds up reads, **SQL Database** persists data
7. **Object Storage** holds large content, **Analytics Engine** tracks everything

### Why This Design Works
- CDN handles 90% of reads at edge
- Cache handles remaining reads fast
- Moderation prevents abuse
- Tiered storage controls costs
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 200),
      _createIcon('Desktop Client', 'Client & Interface', 50, 400),
      _createIcon('CDN', 'Networking', 200, 300),
      _createIcon('API Gateway', 'Networking', 350, 300),
      _createIcon('Rate Limiter', 'Networking', 350, 450),
      _createIcon('Content Storage', 'Application Services', 500, 200),
      _createIcon('Content Moderation', 'Security,Monitoring', 500, 350),
      _createIcon('Search Engine', 'Application Services', 500, 500),
      _createIcon('Redis Cache', 'Caching,Performance', 700, 200),
      _createIcon('SQL Database', 'Database & Storage', 700, 350),
      _createIcon('Object Storage', 'Database & Storage', 700, 500),
      _createIcon('Analytics Engine', 'Data Processing', 900, 350),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 3, label: 'API'),
      _createConnection(2, 3, label: 'Forward'),
      _createConnection(3, 4, label: 'Check'),
      _createConnection(3, 5, label: 'Create'),
      _createConnection(5, 6, label: 'Moderate'),
      _createConnection(3, 7, label: 'Search'),
      _createConnection(5, 8, label: 'Cache'),
      _createConnection(5, 9, label: 'Store'),
      _createConnection(9, 10, label: 'Blob'),
      _createConnection(9, 11, label: 'Analyze'),
    ],
  };

  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      scalableArchitecture,
      moderationArchitecture,
      syntaxHighlightingArchitecture,
      encryptedArchitecture,
      apiArchitecture,
      searchArchitecture,
      analyticsArchitecture,
      storageArchitecture,
      completeArchitecture,
    ];
  }

  static List<Map<String, dynamic>> connectionsToLines(
    Map<String, dynamic> design,
  ) {
    final icons = design['icons'] as List<dynamic>;
    final connections = design['connections'] as List<dynamic>;
    final lines = <Map<String, dynamic>>[];
    for (final conn in connections) {
      final fromIndex = conn['fromIconIndex'] as int;
      final toIndex = conn['toIconIndex'] as int;
      if (fromIndex >= 0 &&
          fromIndex < icons.length &&
          toIndex >= 0 &&
          toIndex < icons.length) {
        final fromIcon = icons[fromIndex] as Map<String, dynamic>;
        final toIcon = icons[toIndex] as Map<String, dynamic>;
        const iconSize = 70.0;
        lines.add({
          'startX': (fromIcon['positionX'] as num).toDouble() + iconSize / 2,
          'startY': (fromIcon['positionY'] as num).toDouble() + iconSize / 2,
          'endX': (toIcon['positionX'] as num).toDouble() + iconSize / 2,
          'endY': (toIcon['positionY'] as num).toDouble() + iconSize / 2,
          'color': conn['color'] ?? 0xFF795548,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
        });
      }
    }
    return lines;
  }
}
