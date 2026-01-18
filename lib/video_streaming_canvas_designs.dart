// Video Streaming Service System - Canvas Design Data
// Contains predefined system designs using available canvas icons

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined Video Streaming Service system designs for the canvas
class VideoStreamingCanvasDesigns {
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
    int color = 0xFFE53935,
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

  // DESIGN 1: Basic Video Streaming
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic Video Streaming',
    'description': 'Simple VOD streaming like early Netflix',
    'explanation': '''
## Basic Video Streaming Architecture

### What This System Does
This is Video-on-Demand (VOD) streaming - like Netflix, Hulu, or Amazon Prime Video. Unlike live streaming, content is pre-recorded. Users can pause, rewind, fast-forward, and watch whenever they want.

### How It Works Step-by-Step

**Step 1: User Opens the App**
User opens the Netflix app on their TV. The app requests the homepage, which shows personalized content rows.

**Step 2: User Selects a Movie**
User clicks on "Inception". The app requests movie details: description, cast, ratings, available languages, and subtitles.

**Step 3: Playback Begins**
User clicks "Play". The Video Service returns a manifest file (a playlist of video chunks). The player downloads and plays chunks sequentially.

**Step 4: Adaptive Streaming Kicks In**
The player monitors download speed:
- Fast internet → Request 4K chunks
- Medium internet → Request 1080p chunks
- Slow internet → Request 720p or lower

Quality changes seamlessly without buffering.

**Step 5: CDN Delivers Content**
Video files are stored on CDN servers worldwide. User in Tokyo gets video from a Tokyo server, not from US origin. This reduces latency from 200ms to 20ms.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Web/Mobile Client | User interface and player | Watch content |
| API Gateway | Routes API requests | Entry point |
| Video Service | Handles playback logic | Core functionality |
| Content Catalog | Movie/show metadata | What's available |
| CDN | Caches video files globally | Fast delivery |
| Object Storage | Stores original files | Permanent storage |

### Netflix-style Manifest File
```
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
video_360p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720
video_720p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080
video_1080p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=14000000,RESOLUTION=3840x2160
video_4k.m3u8
```

The player picks the appropriate quality based on bandwidth.

### Icons Explained
**Web Browser** - Users watching videos through their web browser on desktop or laptop.

**Mobile Client** - Users watching on mobile apps (iOS/Android phones and tablets).

**API Gateway** - The entry point that routes all API requests to appropriate services.

**Video Streaming** - Core service handling playback logic, manifest generation, and streaming URLs.

**Data Warehouse** - Database storing all movie/show metadata: titles, descriptions, ratings, genres.

**CDN** - Content Delivery Network caching video files at edge locations worldwide for fast delivery.

**Object Storage** - Permanent storage for all video files and transcoded versions.

### How They Work Together
1. User opens app on **Web Browser** or **Mobile Client**
2. Request goes through **API Gateway** to **Video Streaming**
3. **Video Streaming** fetches movie details from **Data Warehouse**
4. When user clicks play, **Video Streaming** returns a manifest URL pointing to **CDN**
5. **CDN** fetches video from **Object Storage** if not cached
6. **CDN** streams video directly to user's device
7. Player adapts quality based on bandwidth using the manifest
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 300),
      _createIcon('Mobile Client', 'Client & Interface', 50, 450),
      _createIcon('API Gateway', 'Networking', 250, 375),
      _createIcon('Video Streaming', 'Application Services', 450, 375),
      _createIcon('Data Warehouse', 'Database & Storage', 450, 550),
      _createIcon('CDN', 'Networking', 650, 300),
      _createIcon('Object Storage', 'Database & Storage', 650, 450),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      _createConnection(2, 3, label: 'Route'),
      _createConnection(3, 4, label: 'Get Metadata'),
      _createConnection(3, 5, label: 'Stream URL'),
      _createConnection(5, 6, label: 'Fetch'),
      _createConnection(5, 0, label: 'Video Stream'),
    ],
  };

  // DESIGN 2: Content Ingestion Pipeline
  static Map<String, dynamic> get ingestionArchitecture => {
    'name': 'Content Ingestion Pipeline',
    'description': 'How new content is uploaded, processed, and prepared',
    'explanation': '''
## Content Ingestion Pipeline Architecture

### What This System Does
Before users can watch a movie, it needs to be uploaded, validated, transcoded into multiple formats, and distributed worldwide. This pipeline handles the journey from studio delivery to user-ready content.

### How It Works Step-by-Step

**Step 1: Studio Uploads Content**
A movie studio uploads the "master" file - the highest quality version:
- Resolution: 8K (7680x4320)
- Format: ProRes or DNxHR (lossless)
- Size: 500GB - 2TB for a 2-hour movie
- Includes multiple audio tracks (English, Spanish, etc.)

**Step 2: Upload Service Handles Large Files**
The Upload Service uses chunked uploads:
- File is split into 100MB chunks
- Each chunk uploaded separately
- If one fails, only that chunk is retried
- Checksums verify integrity

**Step 3: Validation Service Checks Quality**
Before processing, the video is validated:
- No corruption in file
- Audio/video sync is correct
- Color space is as expected
- No unexpected artifacts

**Step 4: Transcoding Farm Processes Video**
The Transcoding Cluster (hundreds of machines) creates all needed versions:
- 4K HDR at 15 Mbps
- 1080p at 5 Mbps
- 720p at 3 Mbps
- 480p at 1.5 Mbps
- Each with multiple audio tracks
- Each with subtitle options

This can take 12-24 hours for a movie.

**Step 5: Quality Assurance**
Automated and manual QA:
- Automated: Check encoding metrics
- Manual: Human reviewers spot-check
- A/B testing with focus groups

**Step 6: Distribution to CDN**
Finally, all versions are pushed to CDN edge locations worldwide. Content is now ready for viewers.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Upload Service | Receives large files | Reliable ingestion |
| Raw Storage | Stores original masters | Archive quality |
| Validation Service | Checks file integrity | Quality assurance |
| Transcoding Cluster | Creates all formats | Device compatibility |
| QA Service | Verifies output | Quality control |
| Distribution Service | Pushes to CDN | Global availability |

### Transcoding Time Estimates
```
Content Length    Transcoding Time
──────────────────────────────────
30-min episode    2-4 hours
2-hour movie      8-16 hours
4K content        2x longer
HDR content       1.5x longer
```

### Why So Many Formats?
- Smart TV: 4K HDR
- Laptop: 1080p
- Phone on WiFi: 720p
- Phone on LTE: 480p
- Old device: 480p H.264
- New device: 4K HEVC/AV1

### Icons Explained
**Admin User** - Interface for content managers to upload and manage videos.

**File Upload Service** - Handles large file uploads using chunked transfer for reliability.

**Object Storage** (Raw Storage) - Stores original master files in highest quality for archival.

**Content Moderation** - Checks uploaded files for corruption, audio sync, and quality issues.

**Message Queue** - Queues transcoding jobs for reliable asynchronous processing.

**Video Transcoding** - Hundreds of machines that convert videos to multiple formats and qualities.

**Monitoring System** - Automated and manual quality assurance checking encoded outputs.

**CDN** - Pushes approved content to CDN edge locations worldwide.

**CDN** - Content Delivery Network that caches transcoded videos for fast global delivery.

### How They Work Together
1. Content manager uploads via **Admin User** to **File Upload Service**
2. **File Upload Service** stores original in **Object Storage** (Raw Storage)
3. **Content Moderation** checks the upload for issues
4. Valid files get queued in **Message Queue** for processing
5. **Video Transcoding** creates all quality versions (4K, 1080p, 720p, etc.)
6. **Monitoring System** verifies output quality
7. Approved content goes to **CDN**
8. **CDN** pushes to **CDN** for user access
''',
    'icons': [
      _createIcon('Admin User', 'Client & Interface', 50, 350),
      _createIcon('File Upload Service', 'Application Services', 250, 350),
      _createIcon(
        'Object Storage',
        'Database & Storage',
        250,
        550,
        id: 'Raw Storage',
      ),
      _createIcon('Content Moderation', 'Application Services', 450, 350),
      _createIcon('Message Queue', 'Message Systems', 450, 550),
      _createIcon('Video Transcoding', 'Application Services', 650, 350),
      _createIcon('Monitoring System', 'Application Services', 850, 350),
      _createIcon('CDN', 'Application Services', 1050, 350),
      _createIcon('CDN', 'Networking', 1050, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Upload'),
      _createConnection(1, 2, label: 'Store Raw'),
      _createConnection(1, 3, label: 'Validate'),
      _createConnection(3, 4, label: 'Queue Job'),
      _createConnection(4, 5, label: 'Process'),
      _createConnection(5, 6, label: 'QA Check'),
      _createConnection(6, 7, label: 'Approved'),
      _createConnection(7, 8, label: 'Distribute'),
    ],
  };

  // DESIGN 3: Personalization Engine
  static Map<String, dynamic> get personalizationArchitecture => {
    'name': 'Personalization Engine',
    'description': 'Netflix-style recommendations and personalization',
    'explanation': '''
## Personalization Engine Architecture

### What This System Does
Netflix's homepage looks different for every user. The recommendation engine analyzes viewing history, ratings, and behavior to show content you're likely to enjoy. This system is responsible for that "magic".

### How It Works Step-by-Step

**Step 1: Collect User Signals**
Every action is a signal:
- Watched 90% of a movie → Liked it
- Stopped at 10% → Didn't like it
- Browsed but didn't click → Not interesting enough
- Searched for "action movies" → Interested in action
- Watched at 2 AM → Night owl

**Step 2: Build User Profile**
The User Profile Service aggregates signals into a profile:
- Favorite genres: [Sci-Fi: 85%, Action: 70%, Comedy: 60%]
- Favorite actors: [Tom Hanks, Margot Robbie]
- Viewing patterns: Weekend binger, likes series
- Taste clusters: Similar to users X, Y, Z

**Step 3: Generate Recommendations**
The ML Recommendation Engine uses multiple algorithms:
- Collaborative filtering: "Users like you also watched..."
- Content-based: "Because you watched Inception..."
- Trending: "Popular in your country..."
- Personalized ranking: Order within each row

**Step 4: Personalize Everything**
Not just recommendations, but:
- Which thumbnail to show (A/B tested per user)
- Which synopsis to display
- Row ordering on homepage
- Search result ranking

**Step 5: Serve in Real-time**
When user opens app, the Personalization API returns a fully personalized homepage in <100ms. This is cached and precomputed for speed.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Event Collector | Captures user actions | Signal gathering |
| User Profile Service | Stores user preferences | Know the user |
| ML Training Pipeline | Trains recommendation models | Learning |
| Recommendation Engine | Generates suggestions | Core personalization |
| A/B Testing Service | Tests variations | Optimization |
| Personalization API | Serves personalized content | Real-time delivery |

### Recommendation Signals
```
Signal Type       Weight    Example
────────────────────────────────────────────
Watch completion  High      Finished 95% of movie
Explicit rating   High      5-star rating
Add to My List    Medium    Saved for later
Browse time       Low       Lingered on title
Search query      Medium    Searched "horror"
Device type       Low       Watching on TV
Time of day       Low       Late night viewing
```

### Netflix's Famous Algorithm
Netflix estimates that 80% of content watched comes from recommendations, not search. The algorithm saves billions in content costs by surfacing the right content to the right users.

### Icons Explained
**Web Browser** - User watching content and generating behavioral signals.

**API Gateway** - Routes user requests and events to backend services.

**Metrics Collector** - Captures every user action: plays, pauses, skips, searches, etc.

**Analytics Service** - Aggregates events into user profiles with preferences and taste clusters.

**Recommendation Engine** - ML-powered system that generates personalized suggestions.

**ML Model** - Training pipeline that continuously improves recommendation models.

**A/B Testing Service** - Tests different thumbnails, descriptions, and algorithms per user.

**Data Warehouse** - Database of all available content to recommend from.

**API Server** - Real-time API that serves personalized homepages in <100ms.

### How They Work Together
1. User browses on **Web Browser**, actions captured by **API Gateway**
2. **Metrics Collector** receives all events (watched, paused, searched)
3. Events update **Analytics Service** with preferences
4. **Recommendation Engine** uses profile to generate suggestions
5. **ML Model** trains models from aggregated user data
6. **A/B Testing Service** determines which variant to show
7. **Data Warehouse** provides the actual titles
8. **API Server** returns fully personalized homepage
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Metrics Collector', 'Data Processing', 400, 200),
      _createIcon('Analytics Service', 'Application Services', 400, 350),
      _createIcon('Recommendation Engine', 'Data Processing', 400, 500),
      _createIcon('ML Model', 'Data Processing', 600, 500),
      _createIcon('Analytics Service', 'Application Services', 600, 200),
      _createIcon('Data Warehouse', 'Database & Storage', 600, 350),
      _createIcon('API Server', 'Application Services', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Request'),
      _createConnection(1, 2, label: 'Events'),
      _createConnection(1, 3, label: 'Get Profile'),
      _createConnection(2, 3, label: 'Update'),
      _createConnection(3, 4, label: 'Generate'),
      _createConnection(4, 5, label: 'Train'),
      _createConnection(4, 7, label: 'Fetch'),
      _createConnection(6, 8, label: 'Variant'),
      _createConnection(4, 8, label: 'Personalize'),
    ],
  };

  // DESIGN 4: Search System
  static Map<String, dynamic> get searchArchitecture => {
    'name': 'Search System',
    'description': 'Full-text search with autocomplete and filters',
    'explanation': '''
## Search System Architecture

### What This System Does
Users need to find specific content. This search system handles text queries, autocomplete suggestions, filters (genre, year, rating), and typo correction.

### How It Works Step-by-Step

**Step 1: User Starts Typing**
User types "incep..." in the search box. After 2-3 characters, the Autocomplete Service kicks in.

**Step 2: Autocomplete Suggests**
The Autocomplete Service uses a prefix tree (trie) data structure:
- "inc" → [Inception, Incredibles, Incantation...]
- Ranked by popularity and user preference
- Returns in <50ms

**Step 3: User Submits Search**
User presses enter with "inception". The Search Service queries the Search Index.

**Step 4: Search Index Returns Results**
Elasticsearch (or similar) finds all matching content:
- Title matches: "Inception" (exact match)
- Description matches: Movies about dreams
- Actor matches: Leonardo DiCaprio films
- Similar titles: "Interstellar" (same director)

**Step 5: Personalized Ranking**
Results are re-ranked based on user profile:
- User loves Nolan films → Boost Nolan content
- User prefers action → Boost action movies
- User's region → Boost locally available content

**Step 6: Filters Applied**
User adds filters:
- Genre: Sci-Fi
- Year: 2010-2020
- Rating: 4+ stars
Results are filtered accordingly.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Autocomplete Service | Suggests as you type | Faster search |
| Search Service | Handles full queries | Core search |
| Search Index | Inverted index of content | Fast lookups |
| Filter Service | Applies faceted filters | Refined results |
| Ranking Service | Personalizes order | Relevance |
| Spelling Correction | Fixes typos | User-friendly |

### Search Ranking Factors
```
Factor              Weight    Example
──────────────────────────────────────────────
Title exact match   Highest   "Inception" → Inception
Title partial       High      "incep" → Inception
Description match   Medium    "dreams" → Inception
Actor/Director      Medium    "Nolan" → Inception
User preference     Medium    Watched similar content
Popularity          Low       Top 100 movie
Recency             Low       Released recently
```

### Typo Correction
```
User types: "inceptoin"
System knows:
- "inceptoin" is 1 edit away from "inception"
- "inception" is a known title
- Suggests: "Did you mean: Inception?"
```

### Icons Explained
**Web Browser** - User typing search queries and viewing results.

**API Gateway** - Routes search requests to appropriate search services.

**Search Engine** - Suggests completions as user types using prefix matching.

**Search Engine** - Handles full-text search queries against the search index.

**Content Moderation** - Applies filters like genre, year, and rating to results.

**Data Warehouse** - Inverted index (like Elasticsearch) for fast full-text lookups.

**Ranking Engine** - Personalizes result order based on user preferences.

**NoSQL Database** - Stores user preferences for personalized ranking.

**Data Warehouse** - Enriches results with full metadata (descriptions, images).

### How They Work Together
1. User types in search box on **Web Browser**
2. After 2-3 characters, **API Gateway** queries **Search Engine**
3. **Search Engine** checks **Data Warehouse** for prefix matches
4. User submits full query to **Search Engine**
5. **Search Engine** queries **Data Warehouse** for matching content
6. **Content Moderation** applies any active filters
7. **Ranking Engine** personalizes order using **NoSQL Database**
8. Results enriched from **Data Warehouse** and returned to user
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Search Engine', 'Application Services', 400, 200),
      _createIcon('Search Engine', 'Application Services', 400, 350),
      _createIcon('Content Moderation', 'Application Services', 400, 500),
      _createIcon('Data Warehouse', 'Database & Storage', 600, 200),
      _createIcon('Ranking Engine', 'Data Processing', 600, 350),
      _createIcon('NoSQL Database', 'Database & Storage', 600, 500),
      _createIcon('Data Warehouse', 'Database & Storage', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Search Query'),
      _createConnection(1, 2, label: 'Autocomplete'),
      _createConnection(1, 3, label: 'Search'),
      _createConnection(2, 5, label: 'Prefix Match'),
      _createConnection(3, 5, label: 'Full-text'),
      _createConnection(3, 4, label: 'Filters'),
      _createConnection(5, 6, label: 'Rank'),
      _createConnection(6, 7, label: 'Personalize'),
      _createConnection(6, 8, label: 'Enrich'),
    ],
  };

  // DESIGN 5: Subscription and Billing
  static Map<String, dynamic> get billingArchitecture => {
    'name': 'Subscription and Billing',
    'description': 'Subscription plans, payments, and account management',
    'explanation': '''
## Subscription and Billing Architecture

### What This System Does
Netflix makes money through subscriptions. This system handles plan selection, payment processing, recurring billing, trials, and account management.

### How It Works Step-by-Step

**Step 1: User Signs Up**
New user selects a plan:
- Basic: \$6.99/month, 1 screen, 720p
- Standard: \$15.49/month, 2 screens, 1080p
- Premium: \$22.99/month, 4 screens, 4K + HDR

**Step 2: Payment Processing**
User enters credit card. The Payment Gateway:
- Validates card number (Luhn algorithm)
- Tokenizes card (stores token, not full number)
- Authorizes first charge
- If successful, activates subscription

**Step 3: Account Provisioned**
Upon successful payment:
- Account Service creates the account
- Sets plan features (screens, quality)
- Creates user profiles (up to 5)
- Triggers welcome email

**Step 4: Monthly Billing Cycle**
On billing date (e.g., 15th of each month):
- Billing Service generates invoice
- Attempts to charge saved payment method
- If success: Continue service
- If fail: Retry 3 times over 7 days
- If still failing: Suspend account

**Step 5: Plan Changes**
User upgrades from Standard to Premium:
- Prorated credit for remaining Standard days
- New Premium rate starts immediately
- Features unlock instantly

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Subscription Service | Manages plans | Plan logic |
| Account Service | User account management | Account data |
| Payment Gateway | Processes transactions | Money flow |
| Billing Service | Recurring charges | Automated billing |
| Invoice Service | Generates receipts | Record keeping |
| Dunning Service | Handles failed payments | Revenue recovery |

### Payment Failure Handling (Dunning)
```
Day 0:  Payment fails
        → Send email "Update your payment"
        → Retry in 2 days

Day 2:  Retry fails
        → Send urgent email
        → Retry in 3 days

Day 5:  Retry fails
        → Send final warning
        → Retry in 2 days

Day 7:  Retry fails
        → Suspend account
        → Keep data for 30 days
```

### Subscription Metrics
```
Key Metrics:
- MRR (Monthly Recurring Revenue): \$1.5B
- ARPU (Average Revenue Per User): \$12.50
- Churn Rate: 2.5% monthly
- LTV (Lifetime Value): \$500/subscriber
- Trial Conversion: 70%
```

### Icons Explained
**Web Browser** - User signing up or managing their subscription.

**API Gateway** - Routes subscription and payment requests.

**Payment Gateway** - Manages plan selection, upgrades, and downgrades.

**Authentication** - Creates and manages user accounts and profiles.

**Payment Gateway** - Processes credit cards, tokenizes payment info, authorizes charges.

**Payment Gateway** - Handles recurring monthly charges and retry logic.

**Logging Service** - Generates receipts and billing history.

**SQL Database** - Stores subscription data, payment tokens, and billing history.

**Notification Service** - Sends emails for receipts, failed payments, and renewals.

### How They Work Together
1. User visits signup page on **Web Browser**
2. **API Gateway** routes to **Payment Gateway** for plan selection
3. **Payment Gateway** creates account via **Authentication**
4. Payment sent to **Payment Gateway** for authorization
5. On success, **Payment Gateway** schedules monthly charges
6. **Logging Service** generates receipt
7. **Authentication** stores data in **SQL Database**
8. **Notification Service** sends confirmation email
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Payment Gateway', 'Application Services', 400, 250),
      _createIcon('Authentication', 'Application Services', 400, 450),
      _createIcon('Payment Gateway', 'Networking', 600, 250),
      _createIcon('Payment Gateway', 'Application Services', 600, 450),
      _createIcon('Logging Service', 'Application Services', 800, 350),
      _createIcon('SQL Database', 'Database & Storage', 800, 550),
      _createIcon('Notification Service', 'Message Systems', 1000, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Subscribe'),
      _createConnection(1, 2, label: 'Select Plan'),
      _createConnection(2, 3, label: 'Create Account'),
      _createConnection(2, 4, label: 'Charge'),
      _createConnection(4, 5, label: 'Schedule'),
      _createConnection(5, 6, label: 'Generate'),
      _createConnection(3, 7, label: 'Store'),
      _createConnection(6, 8, label: 'Send Receipt'),
    ],
  };

  // DESIGN 6: DRM and Content Protection
  static Map<String, dynamic> get drmArchitecture => {
    'name': 'DRM and Content Protection',
    'description': 'Preventing piracy and protecting licensed content',
    'explanation': '''
## DRM and Content Protection Architecture

### What This System Does
Studios license content for specific regions and time periods. This system ensures content can only be played by authorized users, in authorized regions, for the authorized duration.

### How It Works Step-by-Step

**Step 1: Content is Encrypted**
Before storing on CDN, video is encrypted:
- AES-128 encryption for each segment
- Each title has unique encryption keys
- Keys stored separately from content

**Step 2: User Requests Playback**
User clicks "Play" on a movie. The player needs a decryption key to play the encrypted video.

**Step 3: License Server Validates Request**
The DRM License Server checks:
- Is this a valid, paying subscriber?
- Is this content available in their region?
- Have they exceeded device limits?
- Is their device trusted (not jailbroken)?

**Step 4: License Issued**
If all checks pass, a time-limited license is issued:
- Contains decryption key
- Valid for 24 hours (or until stopped)
- Bound to specific device
- Cannot be transferred

**Step 5: Secure Playback**
The video player uses a "Trusted Execution Environment":
- Decryption happens in secure hardware
- Decrypted video never exposed to OS
- Screen recording blocked
- HDCP required for external displays

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Encryption Service | Encrypts content | Protect at rest |
| License Server | Issues decryption keys | Authorization |
| Key Management | Stores encryption keys | Security |
| Device Attestation | Verifies device integrity | Prevent tampering |
| Geo-Restriction | Checks viewer location | Regional licensing |
| Watermarking | Invisible content marks | Trace leaks |

### DRM Technologies
```
Platform          DRM System
────────────────────────────
Chrome, Android   Widevine (Google)
Safari, iOS       FairPlay (Apple)
Edge, Xbox        PlayReady (Microsoft)
```

Netflix uses all three to cover all devices.

### Geo-Restriction
```
Content: "The Office" (US only)

Request from US IP:     ✓ Allowed
Request from UK IP:     ✗ Blocked
Request via VPN:        ✗ VPN detected, blocked
```

### Watermarking (Forensic Tracking)
```
If pirated content appears online:
1. Extract invisible watermark
2. Watermark contains: User ID + Timestamp
3. Identify exactly who leaked
4. Terminate their account
5. Legal action if warranted
```

### Icons Explained
**Web Browser** - User requesting to play protected content.

**API Gateway** - Routes playback requests through security layers.

**DRM System** - Issues time-limited decryption keys after validation.

**Security Gateway** - Verifies user's location matches content licensing agreements.

**Authorization** - Securely stores and manages encryption keys.

**Authentication** - Verifies the device is trusted and not jailbroken.

**CDN** - Delivers encrypted video content from edge locations.

**Object Storage** - Stores encrypted video files at rest.

### How They Work Together
1. User clicks play on **Web Browser**
2. **API Gateway** routes to **DRM System** for decryption key
3. **DRM System** checks **Security Gateway** for location compliance
4. **Authentication** verifies the device is trusted
5. **Authorization** provides the decryption key
6. License issued to user's device (time-limited, device-bound)
7. **CDN** serves encrypted video from **Object Storage**
8. Device decrypts and plays in secure environment
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('DRM System', 'Security,Monitoring', 400, 250),
      _createIcon('Security Gateway', 'Security,Monitoring', 400, 450),
      _createIcon('Authorization', 'Security,Monitoring', 600, 250),
      _createIcon('Authentication', 'Security,Monitoring', 600, 450),
      _createIcon('CDN', 'Networking', 800, 350),
      _createIcon('Object Storage', 'Database & Storage', 800, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Play Request'),
      _createConnection(1, 2, label: 'Get License'),
      _createConnection(2, 3, label: 'Check Region'),
      _createConnection(2, 4, label: 'Get Key'),
      _createConnection(2, 5, label: 'Verify Device'),
      _createConnection(5, 0, label: 'License'),
      _createConnection(6, 0, label: 'Encrypted Video'),
      _createConnection(7, 6, label: 'Serve'),
    ],
  };

  // DESIGN 7: Multi-Region Deployment
  static Map<String, dynamic> get multiRegionArchitecture => {
    'name': 'Multi-Region Deployment',
    'description': 'Global infrastructure for worldwide availability',
    'explanation': '''
## Multi-Region Deployment Architecture

### What This System Does
Netflix serves 200+ million subscribers across 190+ countries. This architecture ensures everyone gets fast, reliable service regardless of location.

### How It Works Step-by-Step

**Step 1: User Request Enters System**
User in Tokyo opens the Netflix app. DNS routes them to the nearest edge server.

**Step 2: Global Load Balancer Routes Traffic**
The Global Load Balancer considers:
- Geographic proximity (closest region)
- Current load (avoid overloaded regions)
- Health status (skip unhealthy regions)

Tokyo user is routed to AWS Tokyo region.

**Step 3: Regional Services Handle Request**
Each region has a complete stack:
- API servers
- Databases (replicated)
- Caching (Redis)
- CDN edge nodes

Most requests are handled entirely within the region.

**Step 4: Cross-Region Data Sync**
Some data must be globally consistent:
- User account (can log in anywhere)
- Watch history (continue watching on any device)
- Subscriptions (payment status)

This data is replicated across all regions with eventual consistency.

**Step 5: CDN Edge Optimization**
Netflix uses Open Connect - their own CDN:
- Servers placed inside ISPs
- Video served from within your ISP's network
- Reduces internet backbone traffic
- Better quality and reliability

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Global Load Balancer | Routes to nearest region | Low latency |
| Regional Stack | Complete service in each region | Independence |
| Cross-Region Replication | Syncs critical data | Consistency |
| Open Connect (CDN) | ISP-embedded servers | Best video delivery |
| Health Monitoring | Detects outages | Reliability |
| Failover Service | Redirects during outages | High availability |

### Netflix's Open Connect
```
Traditional CDN:
User → ISP → Internet backbone → CDN → Content

Open Connect:
User → ISP → [Open Connect box inside ISP] → Content

Benefits:
- Zero backbone traffic for video
- Lower latency (server is nearby)
- Better quality (no congestion)
- Cost savings for ISPs
```

### Regional Failover
```
Normal: Tokyo users → AWS Tokyo
Tokyo outage: Tokyo users → AWS Singapore
Recovery: Tokyo users → AWS Tokyo

Failover time: <30 seconds
User impact: Brief interruption, then normal service
```

### Icons Explained
**Web Browser** - User accessing the streaming service from anywhere in the world.

**Global Load Balancer** - Routes users to the nearest healthy region for lowest latency.

**Application Server** (Region USA, EU, Asia) - Complete application stacks in each region.

**SQL Database** (DB USA, EU, Asia) - Regional databases with cross-region replication.

**CDN** - Open Connect network with edge servers inside ISPs worldwide.

### How They Work Together
1. User in Tokyo opens app on **Web Browser**
2. **Global Load Balancer** routes to nearest region (Asia)
3. **Application Server** (Region Asia) handles the request
4. **SQL Database** (DB Asia) provides data locally
5. Critical data replicates between **DB USA**, **DB EU**, and **DB Asia**
6. **CDN** serves video from edge location inside user's ISP
7. If Asia region fails, **Global Load Balancer** redirects to next nearest region
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('Global Load Balancer', 'Networking', 200, 350),
      _createIcon(
        'Application Server',
        'Application Services',
        400,
        200,
        id: 'Region USA',
      ),
      _createIcon(
        'Application Server',
        'Application Services',
        400,
        350,
        id: 'Region EU',
      ),
      _createIcon(
        'Application Server',
        'Application Services',
        400,
        500,
        id: 'Region Asia',
      ),
      _createIcon('SQL Database', 'Database & Storage', 600, 200, id: 'DB USA'),
      _createIcon('SQL Database', 'Database & Storage', 600, 350, id: 'DB EU'),
      _createIcon(
        'SQL Database',
        'Database & Storage',
        600,
        500,
        id: 'DB Asia',
      ),
      _createIcon('CDN', 'Networking', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Request'),
      _createConnection(1, 2, label: 'Route USA'),
      _createConnection(1, 3, label: 'Route EU'),
      _createConnection(1, 4, label: 'Route Asia'),
      _createConnection(2, 5, label: 'Store'),
      _createConnection(3, 6, label: 'Store'),
      _createConnection(4, 7, label: 'Store'),
      _createConnection(5, 6, label: 'Replicate'),
      _createConnection(6, 7, label: 'Replicate'),
      _createConnection(8, 0, label: 'Video'),
    ],
  };

  // DESIGN 8: Offline Download System
  static Map<String, dynamic> get offlineArchitecture => {
    'name': 'Offline Download System',
    'description': 'Download content for offline viewing',
    'explanation': '''
## Offline Download System Architecture

### What This System Does
Users want to watch on planes, subways, and places without internet. This system enables downloading content to devices for offline viewing, while still protecting against piracy.

### How It Works Step-by-Step

**Step 1: User Initiates Download**
User taps "Download" on a movie. The Download Manager starts:
- Checks available storage
- Verifies content is downloadable (some content can't be)
- Selects appropriate quality for device

**Step 2: DRM License for Offline**
Unlike streaming (24-hour license), offline needs a longer license:
- Download license: Valid for 30 days
- Playback license: Valid for 48 hours after first play
- Device-bound: Can't transfer to another device

**Step 3: Content Downloaded**
The Segment Downloader:
- Downloads video segments sequentially
- Handles interruptions (resume from last segment)
- Validates checksums
- Shows progress to user

**Step 4: Encrypted Storage**
Downloaded content is stored encrypted:
- Device-specific encryption key
- Cannot be copied to another device
- Cannot be played outside the Netflix app

**Step 5: Offline Playback**
On the plane, user opens Netflix:
- App works in offline mode
- Downloaded content is available
- License is checked (valid for 48 hours)
- Content decrypted and played locally

**Step 6: License Renewal**
After 48 hours of playback (or 30 days since download):
- Content becomes unavailable
- User must connect to internet
- New license is fetched automatically
- Content plays again

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Download Manager | Coordinates downloads | User experience |
| License Service | Issues offline licenses | DRM compliance |
| Segment Downloader | Downloads video chunks | Efficient download |
| Secure Storage | Encrypted local storage | Piracy protection |
| License Checker | Validates playback rights | Offline DRM |
| Sync Service | Renews licenses when online | Continued access |

### Download Restrictions
```
Restriction         Reason
─────────────────────────────────────
Max 100 downloads   Storage limits
Select devices      Piracy prevention
30-day expiry       License renewal
48-hour playback    Force online check
Some content unavailable  Studio restrictions
```

### Smart Downloads
```
Netflix Smart Downloads:
1. User finishes Episode 3
2. Episode 3 auto-deleted
3. Episode 4 auto-downloaded
4. Always ready, never full storage
```

### Icons Explained
**Mobile Client** - User downloading content for offline viewing on their phone/tablet.

**File Upload Service** - Coordinates downloads, manages queue, shows progress.

**DRM System** - Issues extended offline licenses (30-day validity).

**Video Processing** - Downloads video in chunks with resume support.

**CDN** - Serves video segments for download.

**Blob Storage** - Encrypted local storage on device, cannot be copied.

**Sync Service** - Renews licenses when device goes online.

### How They Work Together
1. User taps download on **Mobile Client**
2. **File Upload Service** checks storage and requests license from **DRM System**
3. **DRM System** issues 30-day offline license
4. **Video Processing** fetches video segments from **CDN**
5. Segments encrypted and saved to **Blob Storage**
6. User watches offline using local license
7. When online, **Sync Service** renews expiring licenses
8. After 48 hours of playback, license must be renewed via **DRM System**
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('File Upload Service', 'Application Services', 250, 350),
      _createIcon('DRM System', 'Security,Monitoring', 450, 250),
      _createIcon('Video Processing', 'Application Services', 450, 450),
      _createIcon('CDN', 'Networking', 650, 350),
      _createIcon('Blob Storage', 'Database & Storage', 250, 550),
      _createIcon('Sync Service', 'Application Services', 450, 600),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Download'),
      _createConnection(1, 2, label: 'Get License'),
      _createConnection(1, 3, label: 'Start Download'),
      _createConnection(3, 4, label: 'Fetch Segments'),
      _createConnection(3, 5, label: 'Store Encrypted'),
      _createConnection(2, 5, label: 'Store License'),
      _createConnection(0, 6, label: 'When Online'),
      _createConnection(6, 2, label: 'Renew'),
    ],
  };

  // DESIGN 9: Analytics Platform
  static Map<String, dynamic> get analyticsArchitecture => {
    'name': 'Analytics Platform',
    'description': 'Tracking viewing behavior and platform metrics',
    'explanation': '''
## Analytics Platform Architecture

### What This System Does
Every second of viewing data is valuable. This system collects, processes, and analyzes viewing behavior to improve recommendations, guide content investments, and measure success.

### How It Works Step-by-Step

**Step 1: Events Collected from Every Device**
Every device sends events:
- Session started (device, user, time)
- Playback started (title, quality, position)
- Playback events (pause, seek, quality change)
- Session ended (total watch time)

Millions of events per second flow in.

**Step 2: Real-time Processing**
Apache Kafka (or similar) ingests all events. Stream processors compute real-time metrics:
- Current viewers per title
- Global platform load
- Quality issues by region

**Step 3: Batch Processing**
Nightly batch jobs analyze deeper patterns:
- Completion rates by title (did people finish?)
- Drop-off points (where do people stop?)
- A/B test results (which thumbnail worked?)

**Step 4: Data Warehouse Stores Everything**
All processed data goes to a data warehouse (like Snowflake):
- 10+ years of historical data
- Petabytes of viewing history
- Queryable by analysts

**Step 5: Business Intelligence**
Dashboards and reports for:
- Content team: What shows should we make?
- Product team: How is the new feature performing?
- Finance team: Revenue and subscriber metrics
- Engineering: System health and performance

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Event Collector | Ingests device events | Data capture |
| Stream Processor | Real-time analysis | Immediate metrics |
| Batch Processor | Deep analysis | Complex insights |
| Data Warehouse | Long-term storage | Historical analysis |
| BI Dashboard | Visualizations | Decision making |
| A/B Platform | Experiment analysis | Optimization |

### Key Content Metrics
```
Metric                  What It Measures
───────────────────────────────────────────────
Completion Rate         % who finish a title
Retention               Did they come back?
Acquisition             New subs from this title
Cost Per Hour           Production cost / hours watched
Stickiness              How often users return
```

### A/B Testing at Scale
```
Netflix runs 100s of A/B tests simultaneously:
- Different thumbnails
- Different descriptions
- Different row orders
- Different algorithms

Each user is in many experiments.
Data analysts measure impact on engagement.
Winning variants become the default.
```

### Icons Explained
**Web Browser** - User watching content and generating events.

**Mobile Client** - Mobile user generating viewing events.

**Metrics Collector** - Ingests millions of events per second from all devices.

**Stream Processor** - Real-time processing for live metrics (current viewers, quality issues).

**Batch Processor** - Nightly deep analysis (completion rates, drop-off points).

**Message Queue** - Kafka-like queue routing events to processors.

**Data Warehouse** - Petabytes of historical viewing data (10+ years).

**Admin User** - Business Intelligence dashboards for all teams.

**A/B Platform** - Analyzes experiment results to determine winners.

### How They Work Together
1. Events flow from **Web Browser** and **Mobile Client** to **Metrics Collector**
2. **Metrics Collector** publishes to **Message Queue**
3. **Stream Processor** computes real-time metrics (live viewers, issues)
4. **Batch Processor** runs nightly for deep analysis
5. Both processors store results in **Data Warehouse**
6. **Admin User** queries warehouse for visualizations
7. **A/B Platform** analyzes experiment data from warehouse
8. Insights drive content and product decisions
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 250),
      _createIcon('Mobile Client', 'Client & Interface', 50, 450),
      _createIcon('Metrics Collector', 'Data Processing', 250, 350),
      _createIcon('Stream Processor', 'Data Processing', 450, 250),
      _createIcon('Batch Processor', 'Data Processing', 450, 450),
      _createIcon('Message Queue', 'Message Systems', 450, 350),
      _createIcon('Data Warehouse', 'Database & Storage', 650, 350),
      _createIcon('Admin User', 'Client & Interface', 850, 250),
      _createIcon('Analytics Service', 'Application Services', 850, 450),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Events'),
      _createConnection(1, 2, label: 'Events'),
      _createConnection(2, 5, label: 'Publish'),
      _createConnection(5, 3, label: 'Real-time'),
      _createConnection(5, 4, label: 'Batch'),
      _createConnection(3, 6, label: 'Store'),
      _createConnection(4, 6, label: 'Store'),
      _createConnection(6, 7, label: 'Query'),
      _createConnection(6, 8, label: 'Experiments'),
    ],
  };

  // DESIGN 10: Complete Video Streaming Platform
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete Video Streaming Platform',
    'description': 'Full Netflix-like architecture with all components',
    'explanation': '''
## Complete Video Streaming Platform Architecture

### What This System Does
This is the complete Netflix-like platform combining all subsystems: content ingestion, personalization, playback, billing, analytics, and global distribution.

### How It Works Step-by-Step

**Step 1: Content Pipeline**
Studios upload content → Transcoding → Quality check → CDN distribution

**Step 2: User Browses**
Request hits global load balancer → Routed to nearest region → Personalization engine generates homepage → Content served

**Step 3: User Searches**
Query goes to Search Service → Elasticsearch returns results → Personalized ranking applied → Results displayed

**Step 4: User Watches**
Play request → DRM license check → Manifest URL returned → Player fetches from CDN → Adaptive streaming kicks in → Analytics events collected

**Step 5: User Subscribes**
Payment processed → Account created → Features unlocked → Monthly billing scheduled

**Step 6: Data Analyzed**
Events flow to analytics → Real-time and batch processing → Insights drive product and content decisions

### Full Component List

| Layer | Components |
|-------|------------|
| Clients | Web, Mobile, TV, Game Console |
| Edge | CDN, Global Load Balancer |
| API | Gateway, Rate Limiting |
| Services | Video, Search, Profile, Subscription |
| Intelligence | Recommendations, Personalization, A/B Testing |
| Data | SQL, NoSQL, Search Index, Cache |
| Analytics | Events, Processing, Warehouse |
| Infrastructure | Multi-region, DRM, Monitoring |

### Netflix Scale Numbers
```
Subscribers: 230+ million
Countries: 190+
Hours streamed daily: 300+ million
Content library: 15,000+ titles
CDN capacity: 100+ Tbps
Cloud spend: \$1.5+ billion/year
```

### Architecture Principles
1. **Microservices**: Each function is a separate service
2. **Resilience**: Circuit breakers, retries, fallbacks
3. **Global**: Available everywhere, low latency
4. **Personalized**: Every user sees different content
5. **Data-Driven**: Every decision backed by analytics

### Icons Explained
**Web Browser** - Users watching on web browsers (Chrome, Firefox, Safari).

**Mobile Client** - Users on iOS/Android mobile apps.

**Desktop Client** - Smart TV and streaming device users.

**CDN** - Content Delivery Network caching video at edge locations globally.

**Global Load Balancer** - Routes users to nearest healthy region.

**API Gateway** - Central entry point routing all API requests.

**Video Streaming** - Handles playback logic and manifest generation.

**Search Engine** - Full-text search with autocomplete and filters.

**Recommendation Engine** - ML-powered personalization for each user.

**DRM System** - DRM license management for content protection.

**SQL Database** - Stores metadata, user data, and billing info.

**Analytics Engine** - Processes viewing data for insights.

**Object Storage** - Permanent storage for all video content.

### How They Work Together
1. Users from **Web Browser**, **Mobile Client**, or **Desktop Client** connect
2. **CDN** handles video delivery, **Global Load Balancer** routes API requests
3. **API Gateway** directs to appropriate service
4. **Video Streaming** handles playback with **DRM System** for DRM
5. **Search Engine** helps users find content
6. **Recommendation Engine** personalizes the homepage
7. **SQL Database** stores all operational data
8. **Object Storage** serves video files through **CDN**
9. **Analytics Engine** processes all viewing events for insights
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 200),
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('Desktop Client', 'Client & Interface', 50, 500),
      _createIcon('CDN', 'Networking', 200, 350),
      _createIcon('Global Load Balancer', 'Networking', 350, 350),
      _createIcon('API Gateway', 'Networking', 500, 350),
      _createIcon('Video Streaming', 'Application Services', 700, 200),
      _createIcon('Search Engine', 'Application Services', 700, 350),
      _createIcon('Recommendation Engine', 'Data Processing', 700, 500),
      _createIcon('DRM System', 'Security,Monitoring', 900, 200),
      _createIcon('SQL Database', 'Database & Storage', 900, 350),
      _createIcon('Analytics Engine', 'Data Processing', 900, 500),
      _createIcon('Object Storage', 'Database & Storage', 1100, 350),
    ],
    'connections': [
      _createConnection(0, 3, label: 'Request'),
      _createConnection(1, 3, label: 'Request'),
      _createConnection(2, 3, label: 'Request'),
      _createConnection(3, 4, label: 'Route'),
      _createConnection(4, 5, label: 'Forward'),
      _createConnection(5, 6, label: 'Play'),
      _createConnection(5, 7, label: 'Search'),
      _createConnection(5, 8, label: 'Recommend'),
      _createConnection(6, 9, label: 'DRM'),
      _createConnection(6, 10, label: 'Metadata'),
      _createConnection(8, 11, label: 'Track'),
      _createConnection(6, 12, label: 'Stream'),
    ],
  };

  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      ingestionArchitecture,
      personalizationArchitecture,
      searchArchitecture,
      billingArchitecture,
      drmArchitecture,
      multiRegionArchitecture,
      offlineArchitecture,
      analyticsArchitecture,
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
          'color': conn['color'] ?? 0xFFE53935,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
        });
      }
    }
    return lines;
  }
}
