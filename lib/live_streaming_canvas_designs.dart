// Live Streaming Platform System - Canvas Design Data
// Contains predefined system designs using available canvas icons

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined Live Streaming Platform system designs for the canvas
class LiveStreamingCanvasDesigns {
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
    int color = 0xFFE91E63,
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

  // DESIGN 1: Basic Live Streaming
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic Live Streaming',
    'description': 'Simple live streaming setup for a single streamer',
    'explanation': '''
## Basic Live Streaming Architecture

### What This System Does
This is the simplest live streaming setup. A streamer broadcasts video, and viewers watch it in real-time. Think of it like a one-way video call from the streamer to potentially thousands of viewers.

### How It Works Step-by-Step

**Step 1: Streamer Captures Video**
The streamer's software (like OBS) captures their screen, webcam, and microphone. This creates a continuous stream of video and audio data.

**Step 2: Video is Sent via RTMP**
RTMP (Real-Time Messaging Protocol) is designed for live video. The broadcaster's computer connects to the RTMP Ingest Server and continuously sends video chunks (usually 2-4 seconds each).

**Step 3: Media Server Processes the Stream**
The Media Server receives the raw video and:
- Encodes it into multiple quality levels (1080p, 720p, 480p, 360p)
- Packages it for web delivery using HLS or DASH formats
- Creates tiny segments (2-6 seconds each) for adaptive streaming

**Step 4: CDN Distributes to Viewers**
CDN (Content Delivery Network) servers cache the video segments worldwide. A viewer in Japan gets video from a Tokyo server, not from the original server in the US.

**Step 5: Viewers Watch in Real-Time**
The viewer's app requests video segments from the CDN. It continuously downloads the next segment while playing the current one. If their internet slows down, it automatically switches to a lower quality.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Broadcaster | Streamer's app (OBS, Streamlabs) | Creates the content |
| RTMP Ingest | Receives live video from broadcaster | Reliable upload protocol |
| Media Server | Transcodes and packages video | Multiple qualities |
| CDN | Distributes video globally | Low latency worldwide |
| Web Viewer | Browser-based player | Watch without app |
| Mobile Viewer | Phone/tablet app | Watch on mobile |

### Latency in Basic Streaming
```
Broadcaster captures frame    → 0ms
Encode and send to server     → +1,000ms
Server transcodes             → +2,000ms
CDN distributes               → +500ms
Viewer buffers and plays      → +2,000ms
─────────────────────────────────────
Total latency: ~5-10 seconds
```

This delay is why chat messages seem "behind" the video.

### Icons Explained

**User** - The broadcaster (streamer) capturing and sending video from their computer.

**Video Ingest** - RTMP Ingest Server that receives the raw video stream from broadcaster software like OBS.

**Stream Management** - Media Server that transcodes video into multiple quality levels and packages it for web delivery.

**CDN** - Content Delivery Network that caches and distributes video segments to viewers worldwide.

**Web Browser** - Desktop viewer watching the stream in a browser-based player.

**Mobile Client** - Phone/tablet viewer watching via the mobile app.

### How They Work Together

1. User (Broadcaster) sends video via RTMP to Video Ingest server
2. Video Ingest passes raw video to Stream Management
3. Stream Management transcodes into multiple qualities (1080p, 720p, 480p)
4. Stream Management creates HLS/DASH segments for web delivery
5. CDN caches segments at edge locations worldwide
6. Web Browser and Mobile Client fetch segments from nearest CDN
''',
    'icons': [
      _createIcon('User', 'Client & Interface', 50, 350),
      _createIcon('Video Ingest', 'Networking', 250, 350),
      _createIcon('Stream Management', 'Application Services', 450, 350),
      _createIcon('CDN', 'Networking', 650, 350),
      _createIcon('Web Browser', 'Client & Interface', 850, 250),
      _createIcon('Mobile Client', 'Client & Interface', 850, 450),
    ],
    'connections': [
      _createConnection(0, 1, label: 'RTMP Push'),
      _createConnection(1, 2, label: 'Raw Video'),
      _createConnection(2, 3, label: 'HLS/DASH'),
      _createConnection(3, 4, label: 'Stream'),
      _createConnection(3, 5, label: 'Stream'),
    ],
  };

  // DESIGN 2: Scalable Streaming Platform
  static Map<String, dynamic> get scalableArchitecture => {
    'name': 'Scalable Streaming Platform',
    'description': 'Multi-streamer platform with horizontal scaling',
    'explanation': '''
## Scalable Streaming Platform Architecture

### What This System Does
This platform handles thousands of streamers simultaneously, each potentially having millions of viewers. It scales horizontally - as load increases, we add more servers.

### How It Works Step-by-Step

**Step 1: Multiple Broadcasters Connect**
Each broadcaster is assigned to an available ingest server. A smart "Ingest Router" directs them to the least-loaded server in their region.

**Step 2: Global Ingest Network**
Instead of one server, there's a network of ingest servers worldwide:
- USA West: 10 ingest servers
- USA East: 10 ingest servers
- Europe: 15 ingest servers
- Asia: 20 ingest servers

**Step 3: Transcoding Cluster Processes Video**
A cluster of transcoding servers shares the load. Each stream is assigned to a specific transcoder. If a transcoder fails, the stream is quickly reassigned.

**Step 4: Stream Metadata in Redis**
Redis stores real-time information:
- Which streams are live
- How many viewers each stream has
- Stream quality and health status
This enables instant updates when browsing streams.

**Step 5: Origin Servers Store Segments**
Before hitting CDN, video segments are stored on Origin Servers. These act as the "source of truth" - CDN servers fetch from here when they don't have a segment cached.

**Step 6: Multi-CDN Strategy**
Large platforms use multiple CDN providers (Cloudflare, Akamai, Fastly). If one has problems, traffic shifts to others. Viewers are routed to the fastest CDN for their location.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Load Balancer | Distributes broadcaster connections | Prevents overload |
| Ingest Cluster | Multiple RTMP receivers | Handle many streamers |
| Transcoding Cluster | Parallel video processing | Scale processing |
| Redis | Stream metadata cache | Real-time info |
| Origin Servers | Segment storage | CDN source |
| Multi-CDN | Multiple content networks | Redundancy |

### Scaling Example
```
10 concurrent streamers:
- 1 ingest server, 2 transcoders

1,000 concurrent streamers:
- 10 ingest servers, 50 transcoders

100,000 concurrent streamers:
- 200 ingest servers, 2,000 transcoders
- All auto-scaled based on demand
```

### Icons Explained

**User (Broadcaster1 & Broadcaster2)** - Multiple streamers broadcasting simultaneously from different locations.

**Global Load Balancer** - Ingest Router that assigns each broadcaster to the nearest, least-loaded ingest server.

**Video Ingest (Ingest1 & Ingest2)** - Cluster of RTMP ingest servers handling different broadcasters.

**Stream Management** - Transcoding Cluster that processes all incoming streams in parallel.

**Redis Cache** - Real-time metadata storage for stream status, viewer counts, and health.

**Object Storage** - Origin Servers storing all video segments as the source for CDNs.

**CDN** - Multi-CDN setup (Cloudflare, Akamai, Fastly) for redundant global delivery.

**Web Browser** - Viewers watching streams from any of the broadcasters.

### How They Work Together

1. Multiple broadcasters connect → Global Load Balancer routes each to nearest server
2. Video Ingest servers handle their assigned streams
3. All streams fed to Stream Management (transcoding cluster)
4. Metadata (who's live, viewer count) stored in Redis Cache
5. Video segments stored in Object Storage (origin)
6. CDN pulls from Object Storage and delivers to Web Browser viewers
''',
    'icons': [
      _createIcon('User', 'Client & Interface', 50, 250),
      _createIcon('User', 'Client & Interface', 50, 450, id: 'Broadcaster2'),
      _createIcon('Global Load Balancer', 'Networking', 200, 350),
      _createIcon('Video Ingest', 'Networking', 400, 250, id: 'Ingest1'),
      _createIcon('Video Ingest', 'Networking', 400, 450, id: 'Ingest2'),
      _createIcon('Stream Management', 'Application Services', 600, 350),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 550),
      _createIcon('Object Storage', 'Database & Storage', 800, 250),
      _createIcon('CDN', 'Networking', 800, 450),
      _createIcon('Web Browser', 'Client & Interface', 1000, 350),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Connect'),
      _createConnection(1, 2, label: 'Connect'),
      _createConnection(2, 3, label: 'Route'),
      _createConnection(2, 4, label: 'Route'),
      _createConnection(3, 5, label: 'Transcode'),
      _createConnection(4, 5, label: 'Transcode'),
      _createConnection(5, 6, label: 'Metadata'),
      _createConnection(5, 7, label: 'Store'),
      _createConnection(7, 8, label: 'Pull'),
      _createConnection(8, 9, label: 'Deliver'),
    ],
  };

  // DESIGN 3: Low Latency Streaming
  static Map<String, dynamic> get lowLatencyArchitecture => {
    'name': 'Low Latency Streaming',
    'description': 'Sub-second latency for interactive streams',
    'explanation': '''
## Low Latency Streaming Architecture

### What This System Does
Traditional streaming has 5-30 second delay. This architecture achieves sub-second latency (under 1 second), enabling real-time interaction. Essential for gaming, auctions, and interactive shows.

### How It Works Step-by-Step

**Step 1: WebRTC for Broadcasting**
Instead of RTMP, we use WebRTC (Web Real-Time Communication). It's the same technology that powers video calls. Lower latency but more complex.

**Step 2: SFU Routes Video**
SFU (Selective Forwarding Unit) is a smart router for video. It receives one stream from the broadcaster and forwards it to all viewers without re-encoding. This saves the 2-3 second transcoding delay.

**Step 3: Edge Servers Close to Users**
Edge Servers are placed in every major city. A viewer connects to the nearest edge server (maybe 10ms away) instead of a far origin (maybe 200ms away).

**Step 4: LL-HLS/LL-DASH as Fallback**
Some viewers can't use WebRTC (corporate firewalls, old browsers). For them, we use Low-Latency HLS (LL-HLS) which achieves ~2-3 second latency instead of traditional HLS's 10+ seconds.

**Step 5: Real-time Chat Integration**
Chat messages go through a separate WebSocket system. They arrive in ~50ms, synchronized with the sub-second video delay.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| WebRTC Gateway | Direct browser-to-server video | Lowest latency |
| SFU | Forwards without processing | Avoids transcoding delay |
| Edge Servers | Servers in every city | Minimal network hop |
| LL-HLS Server | Fallback for non-WebRTC | Compatibility |
| WebSocket | Real-time chat | Interactive features |
| Quality Selector | Adapts to bandwidth | Smooth experience |

### Latency Comparison
```
Traditional HLS:    10-30 seconds
Low-Latency HLS:    2-5 seconds  
WebRTC via SFU:     0.2-1 second
WebRTC direct:      0.1-0.5 second
```

### Trade-offs
- WebRTC: Sub-second latency, but limited to ~1000 viewers per SFU
- LL-HLS: 2-3 second latency, but scales to millions easily
- Hybrid approach uses both depending on the use case

### Icons Explained

**User** - Broadcaster streaming with sub-second latency requirements.

**WebSocket Server (WebRTC)** - WebRTC Gateway for ultra-low-latency video directly from broadcaster.

**Video Ingest** - Traditional RTMP ingest for fallback and LL-HLS processing.

**Stream Management (SFU)** - Selective Forwarding Unit that routes WebRTC without re-encoding.

**Stream Management (LL-HLS)** - Low-Latency HLS Server for viewers who can't use WebRTC.

**Edge Server** - Servers in every major city providing minimal network hops for viewers.

**CDN** - Traditional CDN for LL-HLS segment delivery as fallback.

**WebSocket Server (Chat)** - Real-time chat synchronized with sub-second video.

**Web Browser** - Viewer receiving video via WebRTC (fastest) or LL-HLS (fallback).

### How They Work Together

1. User broadcasts → WebSocket Server (WebRTC) for fastest path
2. User also sends via Video Ingest for LL-HLS fallback
3. SFU forwards WebRTC to Edge Servers without re-encoding
4. LL-HLS Server processes for non-WebRTC viewers via CDN
5. Chat messages via WebSocket Server (Chat) stay synchronized
6. Web Browser uses WebRTC if available, LL-HLS as fallback
''',
    'icons': [
      _createIcon('User', 'Client & Interface', 50, 350),
      _createIcon('WebSocket Server', 'Networking', 250, 250),
      _createIcon('Video Ingest', 'Networking', 250, 450),
      _createIcon('Stream Management', 'Application Services', 450, 250),
      _createIcon('Stream Management', 'Application Services', 450, 450),
      _createIcon('Edge Server', 'Networking', 650, 250),
      _createIcon('CDN', 'Networking', 650, 450),
      _createIcon('WebSocket Server', 'Networking', 450, 600),
      _createIcon('Web Browser', 'Client & Interface', 850, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'WebRTC'),
      _createConnection(0, 2, label: 'RTMP'),
      _createConnection(1, 3, label: 'Forward'),
      _createConnection(2, 4, label: 'Transcode'),
      _createConnection(3, 5, label: '<1s'),
      _createConnection(4, 6, label: 'LL-HLS'),
      _createConnection(5, 8, label: 'WebRTC'),
      _createConnection(6, 8, label: 'HLS'),
      _createConnection(7, 8, label: 'Chat'),
    ],
  };

  // DESIGN 4: Chat and Interaction System
  static Map<String, dynamic> get chatArchitecture => {
    'name': 'Chat and Interaction System',
    'description': 'Real-time chat, donations, and viewer interactions',
    'explanation': '''
## Chat and Interaction System Architecture

### What This System Does
Live streaming isn't just video - it's about interaction. This system handles chat messages, donations/tips, subscription alerts, polls, and all the interactive elements that make streams engaging.

### How It Works Step-by-Step

**Step 1: Viewer Sends Chat Message**
The viewer types "Hello streamer! 🎉" and hits enter. This message goes through a WebSocket connection.

**Step 2: Chat Gateway Receives Message**
The Chat Gateway is like a post office for chat. It receives messages and routes them appropriately. Each chat room (stream) has its own channel.

**Step 3: Moderation Service Checks Content**
Before broadcasting, the message is checked:
- Banned words filter (profanity, slurs)
- Spam detection (same message repeated)
- Rate limiting (max 3 messages per 5 seconds)
- Machine learning for toxic content

If it fails, the message is blocked or held for review.

**Step 4: Message Broadcast to Room**
Approved messages are published to the room's channel. All viewers watching that stream receive the message within ~100ms.

**Step 5: Events Service Handles Special Actions**
When someone donates \$10 with a message:
- Payment Service processes the payment
- Events Service creates a "donation alert"
- Alert is sent to the streamer's overlay software
- The donation message appears on-screen

**Step 6: Persistence for VOD Chat**
Messages are also stored in the database. When someone watches the VOD (recorded stream), chat is replayed at the correct timestamps.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Chat Gateway | Manages chat connections | Real-time messaging |
| Moderation Service | Filters harmful content | Safe environment |
| Pub/Sub System | Broadcasts to all viewers | Scalable messaging |
| Events Service | Special interactions | Donations, alerts |
| Payment Service | Processes money | Monetization |
| Message Store | Saves chat history | VOD replay |

### Chat Message Flow
```
Viewer types message
       ↓ (50ms)
WebSocket to Chat Gateway
       ↓ (10ms)
Moderation check
       ↓ (20ms)
Publish to Pub/Sub
       ↓ (10ms)
Delivered to 50,000 viewers
───────────────────────
Total: ~100ms from send to see
```

### Moderation Tiers
1. **AutoMod**: AI-powered blocking of obvious violations
2. **Mod Actions**: Trusted users can timeout/ban
3. **Streamer Controls**: Configure chat settings
4. **Appeals**: Users can request review of bans

### Icons Explained

**Web Browser** - Desktop viewer sending chat messages and viewing the stream.

**Mobile Client** - Phone viewer participating in chat via the mobile app.

**WebSocket Server** - Chat Gateway that maintains persistent connections with all chatters.

**Chat Service** - Core chat logic that processes, routes, and stores messages.

**Content Moderation** - AI-powered service that filters spam, profanity, and toxic content.

**Message Queue** - Pub/Sub system that broadcasts approved messages to all viewers in the room.

**Event Stream** - Events Service handling donations, subscriptions, and special alerts.

**Payment Gateway** - Processes monetary transactions for donations and tips.

**NoSQL Database** - Message Store for chat history and VOD replay.

### How They Work Together

1. Viewer types message → WebSocket Server receives it
2. Chat Service sends to Content Moderation for filtering
3. If approved → Message Queue broadcasts to all viewers
4. WebSocket Server delivers to everyone watching (~100ms total)
5. Special actions (donations) → Event Stream → Payment Gateway
6. All messages stored in NoSQL Database for VOD chat replay
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 300),
      _createIcon('Mobile Client', 'Client & Interface', 50, 450),
      _createIcon('WebSocket Server', 'Networking', 250, 375),
      _createIcon('Chat Service', 'Application Services', 450, 300),
      _createIcon('Content Moderation', 'Security,Monitoring', 450, 475),
      _createIcon('Message Queue', 'Message Systems', 650, 300),
      _createIcon('Event Stream', 'Application Services', 650, 475),
      _createIcon('Payment Gateway', 'Networking', 850, 475),
      _createIcon('NoSQL Database', 'Database & Storage', 850, 300),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Message'),
      _createConnection(1, 2, label: 'Message'),
      _createConnection(2, 3, label: 'Process'),
      _createConnection(3, 4, label: 'Moderate'),
      _createConnection(4, 5, label: 'Approved'),
      _createConnection(5, 2, label: 'Broadcast'),
      _createConnection(3, 6, label: 'Events'),
      _createConnection(6, 7, label: 'Payments'),
      _createConnection(3, 8, label: 'Store'),
    ],
  };

  // DESIGN 5: Video Processing Pipeline
  static Map<String, dynamic> get videoProcessingArchitecture => {
    'name': 'Video Processing Pipeline',
    'description': 'Complete video transcoding and adaptive streaming',
    'explanation': '''
## Video Processing Pipeline Architecture

### What This System Does
When a streamer sends video, it arrives in one format (maybe 1080p60 H.264). This system converts it into multiple formats and qualities so every viewer gets the best experience for their device and internet speed.

### How It Works Step-by-Step

**Step 1: Raw Video Ingested**
The RTMP Ingest Server receives raw video from the broadcaster. This is typically:
- Resolution: 1920x1080 (1080p)
- Frame rate: 60 fps
- Bitrate: 6-8 Mbps
- Codec: H.264

**Step 2: Transcoder Farm Processes**
The Transcoding Cluster runs multiple encoders in parallel. Each encoder creates a different quality:
- 1080p60 @ 6 Mbps (source quality)
- 720p60 @ 3 Mbps (high quality)
- 720p30 @ 1.5 Mbps (medium)
- 480p30 @ 800 Kbps (low)
- 360p30 @ 400 Kbps (mobile)
- 160p30 @ 200 Kbps (audio-only essentially)

**Step 3: Segmenter Creates Chunks**
The video stream is cut into small chunks (segments):
- 2-6 seconds each
- Each quality has its own segments
- Manifest file lists all available segments

**Step 4: ABR (Adaptive Bitrate) Logic**
The player on the viewer's device constantly measures download speed. If a 720p segment downloads faster than real-time, it might try 1080p. If it's slower, it drops to 480p. This happens seamlessly.

**Step 5: Thumbnails Generated**
Every few seconds, a thumbnail is captured. These appear:
- When hovering over the progress bar
- In the stream preview cards
- For VOD navigation

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| RTMP Ingest | Receives broadcaster video | Entry point |
| Transcoding Cluster | Multi-quality encoding | Device compatibility |
| Segmenter | Cuts into chunks | HTTP delivery |
| Thumbnail Generator | Preview images | Navigation |
| Origin Server | Stores all segments | CDN source |
| Manifest Generator | Lists available qualities | Player navigation |

### Transcoding Ladder Example
```
Quality    Resolution   FPS   Bitrate   For Who
────────────────────────────────────────────────
Source     1080p        60    6 Mbps    Fast internet
High       720p         60    3 Mbps    Good internet
Medium     720p         30    1.5 Mbps  Average
Low        480p         30    800 Kbps  Slow mobile
Mobile     360p         30    400 Kbps  2G/3G
Audio      Audio only   -     128 Kbps  Data saving
```

### Why Multiple Qualities Matter
A viewer on fiber internet (100 Mbps) wants 1080p60.
A viewer on mobile data (5 Mbps) needs 720p30.
A viewer in a subway (unstable) needs 360p that buffers ahead.
Without ABR, only one group would be happy.

### Icons Explained

**User** - Broadcaster sending raw video (typically 1080p60 @ 6 Mbps).

**Video Ingest** - RTMP Ingest Server receiving the raw video stream.

**Video Transcoding (1080p, 720p, 480p)** - Transcoding Farm with parallel encoders creating multiple quality levels.

**Video Processing** - Segmenter that cuts video into small chunks for HTTP streaming.

**Thumbnail Generator** - Creates preview images captured every few seconds.

**Object Storage** - Origin Server storing all video segments and thumbnails.

**CDN** - Distributes all qualities to viewers who request them.

### How They Work Together

1. User sends 1080p60 video → Video Ingest receives
2. Video Ingest fans out to multiple Video Transcoding workers
3. Each transcoder creates one quality level (1080p, 720p, 480p)
4. All transcoded streams → Video Processing (Segmenter)
5. Segmenter creates 2-6 second chunks + manifest files
6. Thumbnail Generator captures preview images
7. All segments/thumbnails → Object Storage
8. CDN delivers to viewers with adaptive bitrate selection
''',
    'icons': [
      _createIcon('User', 'Client & Interface', 50, 350),
      _createIcon('Video Ingest', 'Networking', 200, 350),
      _createIcon('Video Transcoding', 'Application Services', 400, 200),
      _createIcon(
        'Video Transcoding',
        'Application Services',
        400,
        350,
        id: 'Transcoder2',
      ),
      _createIcon(
        'Video Transcoding',
        'Application Services',
        400,
        500,
        id: 'Transcoder3',
      ),
      _createIcon('Video Processing', 'Data Processing', 600, 350),
      _createIcon('Thumbnail Generator', 'Data Processing', 600, 550),
      _createIcon('Object Storage', 'Database & Storage', 800, 350),
      _createIcon('CDN', 'Networking', 1000, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: '1080p60'),
      _createConnection(1, 2, label: '1080p'),
      _createConnection(1, 3, label: '720p'),
      _createConnection(1, 4, label: '480p'),
      _createConnection(2, 5, label: 'Segments'),
      _createConnection(3, 5, label: 'Segments'),
      _createConnection(4, 5, label: 'Segments'),
      _createConnection(1, 6, label: 'Thumbnails'),
      _createConnection(5, 7, label: 'Store'),
      _createConnection(6, 7, label: 'Store'),
      _createConnection(7, 8, label: 'Distribute'),
    ],
  };

  // DESIGN 6: Stream Discovery and Recommendations
  static Map<String, dynamic> get discoveryArchitecture => {
    'name': 'Stream Discovery & Recommendations',
    'description': 'Helping viewers find interesting live streams',
    'explanation': '''
## Stream Discovery & Recommendations Architecture

### What This System Does
With thousands of live streams, how do viewers find content they'll enjoy? This system handles browsing, searching, and personalized recommendations.

### How It Works Step-by-Step

**Step 1: Browse Active Streams**
When a viewer opens the app, they see live streams sorted by viewer count. The Browse API fetches this from a cache that's updated every few seconds.

**Step 2: Search by Keywords**
Viewer types "Minecraft speedrun". The Search Service queries an index of:
- Stream titles
- Streamer names
- Game/category names
- Tags and descriptions

Results ranked by relevance AND current viewer count.

**Step 3: Category Browsing**
Streams are organized into categories:
- Games: Minecraft, Fortnite, League of Legends
- IRL: Just Chatting, Cooking, Travel
- Music, Art, Sports, etc.

**Step 4: Recommendation Engine Personalizes**
Based on the viewer's history:
- Watched a lot of Minecraft → Show more Minecraft
- Follows streamer X → Show similar streamers
- Watches at 8 PM → Show streams starting at 8 PM
- Collaborative filtering: "People like you also watched..."

**Step 5: Real-time Popularity Signals**
The system tracks:
- Viewer count changes (is this stream growing fast?)
- Chat activity (engaged audience?)
- New follows during stream (going viral?)

Rapidly growing streams get boosted in recommendations.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Browse API | Lists live streams | Main discovery |
| Search Service | Full-text search | Find specific content |
| Search Index | Indexed stream data | Fast queries |
| Category Service | Organizes by topic | Browsing |
| Recommendation Engine | Personalized suggestions | Engagement |
| User Profile | Viewing history | Personalization |
| Analytics | Tracks popularity | Trending content |

### Recommendation Signals
```
Signal                  Weight    Example
──────────────────────────────────────────────
Followed streamer       High      You follow them
Similar to followed     Medium    Same game/category
Trending now           Medium    Viewer count growing
Past viewing history   Medium    Watched similar before
Geographic proximity   Low       Same region/language
Time of day pattern    Low       Usually watch at 8 PM
```

### Cold Start Problem
New users have no history. Solutions:
1. Ask interests during signup
2. Show trending/popular content
3. Build profile from first few views
4. Use demographic defaults

### Icons Explained

**Web Browser** - Viewer browsing to discover new streams to watch.

**API Gateway** - Routes browse, search, and category requests to appropriate services.

**Search Engine (Browse)** - Browse API that lists live streams sorted by viewer count.

**Search Engine (Search)** - Full-text Search Service for finding specific content.

**Configuration Service** - Category Service organizing streams by games and topics.

**Recommendation Engine** - ML-powered personalization based on viewing history.

**Search Engine (Index)** - Search Index storing stream titles, tags, and descriptions.

**Redis Cache** - Caches user profiles and viewing history for fast recommendations.

**NoSQL Database** - Stores user preferences and complete viewing history.

**Analytics Engine** - Tracks popularity signals (viewer growth, chat activity) for trending.

### How They Work Together

1. Viewer opens app → API Gateway routes to Browse API
2. Search requests → Search Engine queries Search Index
3. Category browsing → Configuration Service filters by topic
4. Recommendation Engine personalizes using Redis Cache (user profile)
5. Analytics Engine feeds popularity signals to recommendations
6. All data backed by NoSQL Database for persistence
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Search Engine', 'Application Services', 400, 200),
      _createIcon('Search Engine', 'Application Services', 400, 350),
      _createIcon('Configuration Service', 'Application Services', 400, 500),
      _createIcon('Recommendation Engine', 'Data Processing', 600, 350),
      _createIcon('Search Engine', 'Database & Storage', 600, 200),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 500),
      _createIcon('NoSQL Database', 'Database & Storage', 800, 350),
      _createIcon('Analytics Engine', 'Data Processing', 800, 500),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Browse'),
      _createConnection(1, 2, label: 'List Streams'),
      _createConnection(1, 3, label: 'Search'),
      _createConnection(1, 4, label: 'Categories'),
      _createConnection(3, 6, label: 'Query'),
      _createConnection(2, 7, label: 'Cache'),
      _createConnection(5, 8, label: 'User Data'),
      _createConnection(2, 5, label: 'Personalize'),
      _createConnection(9, 5, label: 'Signals'),
    ],
  };

  // DESIGN 7: Monetization System
  static Map<String, dynamic> get monetizationArchitecture => {
    'name': 'Monetization System',
    'description': 'Subscriptions, donations, ads, and revenue sharing',
    'explanation': '''
## Monetization System Architecture

### What This System Does
Streamers need to earn money. This system handles subscriptions (monthly support), bits/donations (one-time tips), advertisements, and revenue sharing calculations.

### How It Works Step-by-Step

**Step 1: Viewer Subscribes to Streamer**
Viewer clicks "Subscribe for \$4.99/month". The Subscription Service:
- Authenticates the viewer
- Processes payment via Payment Gateway
- Grants subscriber benefits (emotes, badge, ad-free)
- Sets up recurring billing

**Step 2: Platform Takes Cut**
The revenue is split:
- \$4.99 subscription
- Platform takes 50%: \$2.50
- Streamer receives 50%: \$2.49

Top streamers negotiate better splits (70/30 or even 80/20).

**Step 3: Donations/Bits Processing**
Viewer sends \$10 donation with message. The Donation Service:
- Processes payment
- Triggers on-screen alert for streamer
- Records in donation ledger
- Platform takes 0-30% depending on method

**Step 4: Ad System Inserts Commercials**
During natural breaks, the Ad Service:
- Selects appropriate ads (viewer demographics)
- Inserts into stream for non-subscribers
- Tracks impressions and clicks
- Calculates streamer's ad revenue share

**Step 5: Payout Service Calculates Earnings**
Monthly, the system:
- Sums all revenue sources (subs, donations, ads)
- Deducts platform fees
- Calculates tax withholding
- Initiates bank transfer to streamer

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Subscription Service | Recurring payments | Stable income |
| Donation Service | One-time tips | Viewer support |
| Ad Service | Commercial insertion | Platform revenue |
| Payment Gateway | Processes transactions | Money flow |
| Revenue Calculator | Splits and calculates | Fair distribution |
| Payout Service | Pays streamers | Money to creators |
| Tax Service | Handles tax docs | Legal compliance |

### Revenue Sources Breakdown
```
Source          Platform Cut    Streamer Cut
───────────────────────────────────────────
Subscriptions   50%             50%
Bits/Donations  25%             75%
Advertisements  45%             55%
Sponsorships    0%              100%
Merchandise     10%             90%
```

### Subscription Tiers
```
Tier 1: \$4.99/month - Basic support
Tier 2: \$9.99/month - Extra emotes
Tier 3: \$24.99/month - Premium badge
Gift subs: Buy for others
Prime: Free monthly sub for Prime members
```

### Icons Explained

**Web Browser** - Viewer making purchases (subscriptions, donations).

**API Gateway** - Routes monetization requests to appropriate services.

**Payment Gateway (Subscription)** - Subscription Service handling recurring monthly payments.

**Payment Gateway (Donation)** - Donation Service processing one-time tips with messages.

**Analytics Service** - Ad Service inserting commercials for non-subscribers.

**Payment Gateway (External)** - External payment processor (Stripe, PayPal) charging cards.

**Analytics Engine** - Revenue Calculator that splits earnings between platform and streamer.

**Payment Gateway (Payout)** - Payout Service transferring money to streamer bank accounts.

**SQL Database** - Stores all transaction records, subscription status, and revenue data.

### How They Work Together

1. Viewer subscribes → API Gateway → Payment Gateway (Subscription)
2. Viewer donates → API Gateway → Payment Gateway (Donation)
3. Both charge via Payment Gateway (External)
4. Non-subscribers see ads via Analytics Service
5. All revenue → Analytics Engine calculates splits
6. Analytics Engine → Payment Gateway (Payout) for monthly payouts
7. All transactions recorded in SQL Database
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Payment Gateway', 'Application Services', 400, 200),
      _createIcon('Payment Gateway', 'Application Services', 400, 350),
      _createIcon('Analytics Service', 'Application Services', 400, 500),
      _createIcon('Payment Gateway', 'Networking', 600, 275),
      _createIcon('Analytics Engine', 'Data Processing', 600, 425),
      _createIcon('Payment Gateway', 'Application Services', 800, 350),
      _createIcon('SQL Database', 'Database & Storage', 800, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Subscribe'),
      _createConnection(1, 2, label: 'Sub Request'),
      _createConnection(1, 3, label: 'Donate'),
      _createConnection(1, 4, label: 'Ad Request'),
      _createConnection(2, 5, label: 'Charge'),
      _createConnection(3, 5, label: 'Charge'),
      _createConnection(4, 6, label: 'Ad Revenue'),
      _createConnection(2, 6, label: 'Sub Revenue'),
      _createConnection(6, 7, label: 'Calculate'),
      _createConnection(7, 8, label: 'Store'),
    ],
  };

  // DESIGN 8: VOD and Clip System
  static Map<String, dynamic> get vodArchitecture => {
    'name': 'VOD and Clip System',
    'description': 'Recording, storing, and replaying past streams',
    'explanation': '''
## VOD and Clip System Architecture

### What This System Does
Live streams are ephemeral - once they end, viewers who missed it are out of luck. VOD (Video on Demand) records streams so they can be watched later. Clips are short highlight moments.

### How It Works Step-by-Step

**Step 1: Stream is Recorded**
While the stream is live, the recording service saves a copy of all video segments. This happens in parallel to live delivery.

**Step 2: Stream Ends, VOD Created**
When the stream ends:
- All segments are concatenated
- Metadata is attached (title, game, duration)
- Chat replay is synced to timestamps
- Thumbnail is generated
- VOD becomes available for viewing

**Step 3: Viewer Creates Clip**
Viewer sees an amazing moment and clicks "Clip". The Clip Service:
- Extracts the specified 30-60 seconds
- Creates a shareable URL
- Generates thumbnail at the best frame
- Adds to streamer's clip gallery

**Step 4: VOD Transcoding**
Unlike live (which is transcoded in real-time), VODs can be processed offline with better quality settings:
- Higher quality encoding (slower but better)
- Multiple audio tracks (different languages)
- Chapter markers for navigation

**Step 5: Long-term Storage**
VODs are expensive to store. Lifecycle policy:
- First 7 days: Hot storage (fast access)
- 7-60 days: Warm storage (slower, cheaper)
- 60+ days: Archive storage (very slow, very cheap)
- Some are deleted after 60 days to save costs

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Recording Service | Captures live stream | Creates VOD |
| VOD Processor | Post-stream processing | Better quality |
| Clip Service | Creates short highlights | Viral moments |
| Object Storage | Stores video files | Durability |
| CDN | Delivers to viewers | Fast playback |
| Metadata Store | VOD information | Searchability |

### VOD Storage Tiers
```
Tier     Access Time    Cost/GB    Use Case
───────────────────────────────────────────
Hot      Instant        \$0.023    Recent VODs
Warm     Seconds        \$0.0125   Older VODs
Archive  Hours          \$0.004    Rarely watched
```

### Clip Viral Loop
```
1. Amazing moment happens live
2. Viewer clips 30 seconds
3. Shares on Twitter/Reddit
4. Clip goes viral
5. New viewers discover streamer
6. Come back for next stream
```

### Icons Explained

**User** - Broadcaster whose stream is being recorded and clipped.

**Stream Management** - Live stream processing that also saves for recording.

**Content Storage** - Recording Service capturing all video segments during the stream.

**Video Processing (Clip)** - Clip Service extracting short highlights on demand.

**Video Processing (VOD)** - VOD Processor encoding recorded streams with high quality.

**Object Storage** - Stores all VOD files and clips with tiered storage policies.

**NoSQL Database** - Metadata Store for VOD info, timestamps, and chat sync.

**CDN** - Distributes VODs and clips to viewers worldwide.

**Web Browser** - Viewer watching VODs or clips after the live stream ends.

### How They Work Together

1. User streams → Stream Management processes live video
2. Content Storage records in parallel during stream
3. Viewer requests clip → Video Processing (Clip) extracts segment
4. Stream ends → Video Processing (VOD) creates high-quality VOD
5. Everything stored in Object Storage with lifecycle policies
6. Metadata (title, duration, chat sync) in NoSQL Database
7. CDN delivers VODs and clips to Web Browser viewers
''',
    'icons': [
      _createIcon('User', 'Client & Interface', 50, 350),
      _createIcon('Stream Management', 'Application Services', 250, 350),
      _createIcon('Content Storage', 'Application Services', 450, 250),
      _createIcon('Video Processing', 'Application Services', 450, 450),
      _createIcon('Video Processing', 'Data Processing', 650, 250),
      _createIcon('Object Storage', 'Database & Storage', 650, 450),
      _createIcon('NoSQL Database', 'Database & Storage', 850, 350),
      _createIcon('CDN', 'Networking', 1050, 350),
      _createIcon('Web Browser', 'Client & Interface', 1250, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Live Stream'),
      _createConnection(1, 2, label: 'Record'),
      _createConnection(1, 3, label: 'Clip Request'),
      _createConnection(2, 4, label: 'Process'),
      _createConnection(3, 5, label: 'Store'),
      _createConnection(4, 5, label: 'Store'),
      _createConnection(4, 6, label: 'Metadata'),
      _createConnection(5, 7, label: 'Distribute'),
      _createConnection(7, 8, label: 'Watch'),
    ],
  };

  // DESIGN 9: Analytics and Insights
  static Map<String, dynamic> get analyticsArchitecture => {
    'name': 'Analytics and Insights',
    'description':
        'Streamer analytics, platform metrics, and business intelligence',
    'explanation': '''
## Analytics and Insights Architecture

### What This System Does
Streamers need data to grow. The platform needs data to make business decisions. This system collects every event and transforms it into actionable insights.

### How It Works Step-by-Step

**Step 1: Events are Collected**
Every action is an event:
- Viewer joined stream (timestamp, user_id, stream_id)
- Viewer left stream (watch_duration)
- Viewer subscribed (tier, amount)
- Chat message sent (content, timestamp)
- Ad was shown (ad_id, clicked?)

Millions of events per second flow into the Event Collector.

**Step 2: Real-time Stream Processing**
For live dashboards, events are processed in real-time:
- Current viewer count
- Chat messages per minute
- New follows in the last hour
- Revenue so far today

**Step 3: Batch Processing for Deep Analysis**
Nightly batch jobs analyze deeper patterns:
- Viewer retention curves
- Peak streaming hours
- Subscriber churn rate
- Content performance comparison

**Step 4: Data Warehouse Stores History**
All processed data goes to a Data Warehouse (like Snowflake or BigQuery). Analysts can write SQL queries to answer complex questions.

**Step 5: Dashboard Visualizes**
Streamers see their Creator Dashboard:
- Daily/weekly/monthly views
- Follower growth chart
- Top clips performance
- Revenue breakdown

Platform sees internal dashboards:
- Total platform viewers
- Revenue by category
- Infrastructure costs
- Growth metrics

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Event Collector | Ingests all events | Raw data capture |
| Stream Processor | Real-time analysis | Live metrics |
| Batch Processor | Deep analysis | Complex insights |
| Data Warehouse | Historical storage | SQL analysis |
| Dashboard Service | Visualizations | User-facing |
| ML Pipeline | Predictions | Churn, recommendations |

### Streamer Dashboard Metrics
```
Today's Stats:
- Peak viewers: 1,234
- Average viewers: 456
- Total watch hours: 789
- New followers: 123
- Revenue: \$567

Growth:
- 30-day trend: +15%
- vs. last month: +22%
- Category rank: #47
```

### Platform Business Metrics
```
Key Performance Indicators:
- MAU (Monthly Active Users): 140M
- DAU/MAU ratio: 42%
- Average session: 95 minutes
- Revenue per user: \$2.47
- Streamer payout: \$1.2B/year
```

### Icons Explained

**Web Browser** - Viewer generating events by watching, chatting, and interacting.

**User** - Broadcaster generating stream events and content metrics.

**Metrics Collector** - Event Collector ingesting millions of events per second.

**Message Queue** - High-throughput streaming (Kafka) for durable event delivery.

**Stream Processor** - Real-time analysis for live dashboards and current metrics.

**Batch Processor** - Nightly jobs for deep analysis like retention curves and churn.

**Data Warehouse** - Historical storage for all processed data and SQL queries.

**Analytics Service** - Dashboard Service visualizing metrics for streamers and platform.

**ML Model** - Machine learning pipeline for predictions and recommendations.

### How They Work Together

1. Every action from Web Browser and User → Metrics Collector
2. Events published to Message Queue for durability
3. Stream Processor provides real-time metrics (current viewers, revenue today)
4. Batch Processor runs overnight for complex analysis
5. Both write to Data Warehouse for historical storage
6. Analytics Service displays charts and dashboards
7. ML Model trains on Data Warehouse data for predictions
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 250),
      _createIcon('User', 'Client & Interface', 50, 450),
      _createIcon('Metrics Collector', 'Data Processing', 250, 350),
      _createIcon('Message Queue', 'Message Systems', 450, 350),
      _createIcon('Stream Processor', 'Data Processing', 650, 250),
      _createIcon('Batch Processor', 'Data Processing', 650, 450),
      _createIcon('Data Warehouse', 'Database & Storage', 850, 350),
      _createIcon('Analytics Service', 'Application Services', 1050, 250),
      _createIcon('ML Model', 'Data Processing', 1050, 450),
    ],
    'connections': [
      _createConnection(0, 2, label: 'View Events'),
      _createConnection(1, 2, label: 'Stream Events'),
      _createConnection(2, 3, label: 'Publish'),
      _createConnection(3, 4, label: 'Real-time'),
      _createConnection(3, 5, label: 'Batch'),
      _createConnection(4, 6, label: 'Store'),
      _createConnection(5, 6, label: 'Store'),
      _createConnection(6, 7, label: 'Query'),
      _createConnection(6, 8, label: 'Train'),
    ],
  };

  // DESIGN 10: Complete Live Streaming Platform
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete Live Streaming Platform',
    'description': 'Enterprise-grade platform like Twitch or YouTube Live',
    'explanation': '''
## Complete Live Streaming Platform Architecture

### What This System Does
This is a full-featured streaming platform like Twitch, YouTube Live, or Facebook Gaming. It combines all previous systems into one massive, interconnected platform.

### How It Works Step-by-Step

**Step 1: Broadcaster Starts Stream**
Broadcaster software connects to RTMP Ingest. Load Balancer routes to nearest, least-loaded server.

**Step 2: Video Processing Pipeline**
Media Server transcodes to multiple qualities. Segmenter creates HLS/DASH chunks. Thumbnails generated for preview.

**Step 3: Global Distribution**
Origin Servers store segments. Multi-CDN delivers worldwide. Edge Servers provide low-latency options.

**Step 4: Viewers Discover and Watch**
Discovery Service shows recommendations. Players fetch video from CDN. Quality adapts to bandwidth automatically.

**Step 5: Real-time Interaction**
WebSocket Gateway handles chat. Events Service processes donations. Moderation keeps chat safe.

**Step 6: Monetization Flows**
Subscriptions and bits processed. Ads inserted for non-subscribers. Revenue calculated and split.

**Step 7: Recording and VOD**
Stream is recorded in parallel. VOD available after stream ends. Clips created for highlights.

**Step 8: Analytics Pipeline**
All events collected. Real-time metrics shown. Batch analysis provides insights.

### Full Component List

| Layer | Components |
|-------|------------|
| Ingest | Load Balancer, RTMP Ingest, WebRTC Gateway |
| Processing | Media Server, Transcoder, Segmenter |
| Distribution | Origin, CDN, Edge Servers |
| Interaction | Chat, Events, Moderation |
| Monetization | Subscriptions, Donations, Ads |
| Storage | VOD, Clips, Object Storage |
| Analytics | Events, Processing, Warehouse |
| Support | Auth, Search, Recommendations |

### Scale Numbers (Major Platform)
```
Concurrent streamers: 100,000+
Concurrent viewers: 30,000,000+
Peak bandwidth: 100+ Tbps
Daily VOD hours created: 1,000,000+
Chat messages per second: 1,000,000+
Data centers: 20+
Edge locations: 200+
```

### Architecture Principles
1. **Horizontal Scaling**: Add servers, not bigger servers
2. **Geographic Distribution**: Close to users globally
3. **Graceful Degradation**: If one component fails, others continue
4. **Real-time Priority**: Video and chat must be instant
5. **Cost Optimization**: Balance quality vs. infrastructure cost

### Icons Explained

**User** - Broadcaster starting their live stream.

**Global Load Balancer** - Routes broadcaster to nearest, least-loaded ingest server.

**Video Ingest** - RTMP Ingest receiving video for traditional streaming path.

**WebSocket Server (WebRTC)** - WebRTC Gateway for ultra-low-latency streaming.

**Stream Management** - Media Server transcoding and packaging video.

**CDN** - Global distribution of video segments to viewers.

**WebSocket Server (Real-time)** - Handles chat and real-time interactions.

**Chat Service** - Processes chat messages with moderation.

**Search Engine** - Discovery Service for finding and recommending streams.

**Payment Gateway** - Handles subscriptions, donations, and monetization.

**Video Streaming** - VOD/Clip Service for recording and highlights.

**Analytics Engine** - Collects and analyzes all platform events.

**Web Browser** - Desktop viewer watching streams.

**Mobile Client** - Mobile viewer watching via app.

### How They Work Together

1. User connects via Global Load Balancer
2. RTMP → Video Ingest → Stream Management (transcode) → CDN
3. WebRTC → WebSocket Server → Stream Management (forward) → faster delivery
4. WebSocket Server (Real-time) + Chat Service handle interaction
5. Search Engine enables discovery, Payment Gateway handles money
6. Video Streaming records for VODs and clips
7. Analytics Engine tracks everything for insights
8. Web Browser and Mobile Client receive video from CDN
''',
    'icons': [
      _createIcon('User', 'Client & Interface', 50, 300),
      _createIcon('Global Load Balancer', 'Networking', 200, 300),
      _createIcon('Video Ingest', 'Networking', 350, 200),
      _createIcon('WebSocket Server', 'Networking', 350, 400),
      _createIcon('Stream Management', 'Application Services', 500, 300),
      _createIcon('CDN', 'Networking', 650, 200),
      _createIcon('WebSocket Server', 'Networking', 650, 400),
      _createIcon('Chat Service', 'Application Services', 800, 400),
      _createIcon('Search Engine', 'Application Services', 800, 250),
      _createIcon('Payment Gateway', 'Application Services', 950, 350),
      _createIcon('Video Streaming', 'Application Services', 950, 500),
      _createIcon('Analytics Engine', 'Data Processing', 1100, 350),
      _createIcon('Web Browser', 'Client & Interface', 1100, 200),
      _createIcon('Mobile Client', 'Client & Interface', 1100, 500),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Connect'),
      _createConnection(1, 2, label: 'RTMP'),
      _createConnection(1, 3, label: 'WebRTC'),
      _createConnection(2, 4, label: 'Transcode'),
      _createConnection(3, 4, label: 'Forward'),
      _createConnection(4, 5, label: 'Distribute'),
      _createConnection(4, 6, label: 'Real-time'),
      _createConnection(6, 7, label: 'Chat'),
      _createConnection(5, 8, label: 'Browse'),
      _createConnection(8, 9, label: 'Subscribe'),
      _createConnection(4, 10, label: 'Record'),
      _createConnection(9, 11, label: 'Revenue'),
      _createConnection(5, 12, label: 'Watch'),
      _createConnection(5, 13, label: 'Watch'),
    ],
  };

  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      scalableArchitecture,
      lowLatencyArchitecture,
      chatArchitecture,
      videoProcessingArchitecture,
      discoveryArchitecture,
      monetizationArchitecture,
      vodArchitecture,
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
          'color': conn['color'] ?? 0xFFE91E63,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
        });
      }
    }
    return lines;
  }
}
