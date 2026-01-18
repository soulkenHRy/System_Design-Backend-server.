// News Feed System - Canvas Design Data
// Contains predefined system designs using available canvas icons

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined News Feed system designs for the canvas
class NewsFeedCanvasDesigns {
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
    int color = 0xFF3F51B5,
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

  // DESIGN 1: Basic News Feed
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic News Feed',
    'description': 'Simple chronological feed of posts',
    'explanation': '''
## Basic News Feed Architecture

### What This System Does
Shows posts from people you follow in chronological order (newest first).

### Icons Explained

**Mobile Client** - User's phone app showing the feed

**API Gateway** - Entry point that receives feed requests

**Feed Generation** - Fetches and merges posts from followed users

**Social Graph Service** - Stores who follows whom (Alice follows Bob, Carol...)

**Content Storage** - Stores all posts with content, timestamps, media

**Redis Cache** - Caches user profiles for fast display (names, avatars)

### How They Work Together

1. User opens app on **Mobile Client**
2. Request goes to **API Gateway** → **Feed Generation**
3. **Feed Generation** asks **Social Graph Service**: "Who does this user follow?"
4. Gets list: [Bob, Carol, Dave...]
5. **Feed Generation** fetches posts from **Content Storage** for each followed user
6. User profiles loaded from **Redis Cache** (fast)
7. Posts merged, sorted by time, returned to **Mobile Client**

### Why This Design Works
- Simple to understand and implement
- Works well for small follow counts
- Limitation: Slow when following many users (1000+ queries)
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Feed Generation', 'Application Services', 400, 350),
      _createIcon('Social Graph Service', 'Database & Storage', 600, 200),
      _createIcon('Content Storage', 'Database & Storage', 600, 350),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 500),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Request Feed'),
      _createConnection(1, 2, label: 'Get Feed'),
      _createConnection(2, 3, label: 'Who I Follow'),
      _createConnection(2, 4, label: 'Their Posts'),
      _createConnection(2, 5, label: 'User Info'),
    ],
  };

  // DESIGN 2: Fan-out on Write
  static Map<String, dynamic> get fanoutWriteArchitecture => {
    'name': 'Fan-out on Write',
    'description': 'Pre-compute feeds when posts are created',
    'explanation': '''
## Fan-out on Write Architecture

### What This System Does
Instead of computing feed on every read (slow), we pre-compute feeds when posts are created. When Bob posts, we add it to all his followers' feeds immediately.

### How It Works Step-by-Step

**Step 1: User Creates Post**
Bob writes: "Hello World!"
Post stored in Posts table.

**Step 2: Get All Followers**
Fetch Bob's follower list:
```json
{
  "followers": ["alice", "carol", "dave", ...1000 more]
}
```

**Step 3: Fan Out to Feeds**
Add Bob's post ID to each follower's feed:
```
alice_feed: [bob_post_123, ...]
carol_feed: [bob_post_123, ...]
dave_feed: [bob_post_123, ...]
```

**Step 4: Feed Stored in Cache**
Each user's feed is a list in Redis:
```
LPUSH alice_feed bob_post_123
LTRIM alice_feed 0 999  # Keep last 1000
```

**Step 5: User Requests Feed**
When Alice opens app:
- Read her pre-computed feed from Redis
- Fetch post content for each ID
- Return instantly!

**Step 6: Trade-off**
Write is slow (fan to many followers)
Read is fast (just read from cache)
Great for apps with more reads than writes.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Post Service | Handles new posts | Create posts |
| Message Queue | Distributes to feeds | Pre-computation |
| Social Graph Service | Quick follower lookup | Fast fan-out |
| Redis Cache | Stores user feeds | Fast reads |
| Content Storage | Stores post content | Content storage |

### The Celebrity Problem
Elon Musk has 180M followers - can't fan-out to all!
Solution: Hybrid approach for celebrities (see Design 4)
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('Content Publishing', 'Application Services', 200, 250),
      _createIcon('Message Queue', 'Application Services', 400, 250),
      _createIcon('Social Graph Service', 'Database & Storage', 400, 450),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 250),
      _createIcon('Content Storage', 'Database & Storage', 600, 450),
    ],
    'connections': [
      _createConnection(0, 1, label: 'New Post'),
      _createConnection(1, 2, label: 'Fan Out'),
      _createConnection(2, 3, label: 'Get Followers'),
      _createConnection(2, 4, label: 'Write Feeds'),
      _createConnection(1, 5, label: 'Store Post'),
      _createConnection(0, 4, label: 'Read Feed'),
    ],
  };

  // DESIGN 2 EXPLANATION UPDATE
  // Fan-out on Write Architecture
  // Icons: Mobile Client, Content Publishing, Message Queue, Social Graph Service, Redis Cache, Content Storage
  // Flow: User posts → Content Publishing stores post → Message Queue fans out to all followers
  //       → Social Graph Service provides follower list → Redis Cache stores each follower's feed
  //       → When reading, just fetch from Redis Cache (instant!)

  // DESIGN 3: Fan-out on Read
  static Map<String, dynamic> get fanoutReadArchitecture => {
    'name': 'Fan-out on Read',
    'description': 'Compute feed when user requests it',
    'explanation': '''
## Fan-out on Read Architecture

### What This System Does
Computes the feed when user requests it, instead of pre-computing. Great for celebrity accounts.

### Icons Explained

**Mobile Client** - User's phone requesting their feed

**Feed Generation** - Fetches and assembles the feed on-demand

**Social Graph Service** - Provides list of who user follows

**Redis Cache** - Caches recent posts from each user

**Stream Processor** - Merges and sorts posts from multiple sources

**Content Storage** - Database storing all posts

### How They Work Together

1. User opens app on **Mobile Client**, requests feed
2. **Feed Generation** asks **Social Graph Service**: "Who do I follow?"
3. Gets back: [Bob, Carol, Celebrity...]
4. Fetches recent posts from **Redis Cache** for each followed user
5. Cache misses go to **Content Storage**
6. **Stream Processor** merges all posts, sorts by time
7. Returns assembled feed to **Mobile Client**

### Why This Design Works
- Celebrity posts don't need fan-out (saves massive writes)
- Trade-off: Read is slower (must compute each time)
- Good when: More writes than reads, or following celebrities
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('Feed Generation', 'Application Services', 250, 350),
      _createIcon('Social Graph Service', 'Application Services', 450, 200),
      _createIcon('Redis Cache', 'Caching,Performance', 450, 350),
      _createIcon('Stream Processor', 'Data Processing', 450, 500),
      _createIcon('Content Storage', 'Database & Storage', 650, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Get Feed'),
      _createConnection(1, 2, label: 'Following'),
      _createConnection(1, 3, label: 'Posts'),
      _createConnection(3, 5, label: 'Fetch'),
      _createConnection(2, 4, label: 'Merge'),
      _createConnection(3, 4, label: 'Merge'),
      _createConnection(4, 0, label: 'Feed'),
    ],
  };

  // DESIGN 4: Hybrid Approach
  static Map<String, dynamic> get hybridArchitecture => {
    'name': 'Hybrid Approach',
    'description': 'Fan-out on write for regular users, read for celebrities',
    'explanation': '''
## Hybrid News Feed Architecture

### What This System Does
Combines both approaches: Fan-out on write for regular users, fan-out on read for celebrities. Best of both worlds!

### How It Works Step-by-Step

**Step 1: Classify Users**
When user gains followers:
- < 10K followers: Regular user
- ≥ 10K followers: Celebrity

**Step 2: Regular User Posts**
Bob (1000 followers) posts:
- Fan out to all 1000 followers' feeds
- Just like fan-out on write

**Step 3: Celebrity Posts**
Taylor (50M followers) posts:
- DO NOT fan out (too expensive)
- Just store post with "celebrity" flag

**Step 4: User Requests Feed**
When Alice requests feed:
1. Read her pre-computed feed (from regular users)
2. Separately fetch celebrity posts she follows
3. Merge both lists

**Step 5: Merge at Read Time**
```
Pre-computed: [bob_post, carol_post, dave_post]
Celebrity live: [taylor_post, kim_post]
Merged: [taylor_post, bob_post, kim_post, carol_post, ...]
```

**Step 6: Cache Celebrity Posts**
Popular celebrity posts cached heavily:
- CDN for content
- Redis for metadata
- Reduces database load

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| User Classifier | Identifies celebrities | Route differently |
| Fan-out Service | For regular users | Pre-compute |
| Celebrity Cache | Caches popular posts | Fast reads |
| Merge Service | Combines feeds | Final assembly |
| Feed Cache | Pre-computed feeds | Regular users |

### Decision Logic
```python
def on_new_post(post, author):
    if author.followers < 10000:
        # Fan out on write
        fan_out_to_all_followers(post)
    else:
        # Celebrity - just store
        store_with_celebrity_flag(post)

def get_feed(user):
    regular_posts = read_cached_feed(user)
    celebrity_posts = fetch_celebrity_posts(user.following_celebrities)
    return merge_and_rank(regular_posts, celebrity_posts)
```

### Twitter's Approach
```
Twitter uses this hybrid:
- 99% users: Fan-out on write
- 1% celebrities: Fan-out on read

When you open Twitter:
- Read pre-computed timeline
- Inject latest celebrity tweets
- Merge in real-time
```

### Icons Explained

**Mobile Client** - The phone or tablet app where users view their feeds and create posts.

**Analytics Engine** - Classifies users as regular (fan-out on write) or celebrity (fan-out on read) based on follower count.

**Message Queue** - Handles fan-out jobs for regular users, distributing posts to all their followers' feeds.

**Redis Cache (top)** - Stores pre-computed feeds for regular users so they load instantly.

**Redis Cache (bottom)** - Caches celebrity posts separately since they're fetched on-demand at read time.

**Stream Processor** - Merges the pre-computed regular feed with live celebrity posts when user requests their feed.

**Content Storage** - The main database storing all posts, user data, and the social graph of who follows whom.

### How They Work Together

1. User posts → Analytics Engine checks follower count to classify them
2. Regular user posts → Message Queue fans out to all followers' Redis Caches
3. Celebrity posts → Stored only in Content Storage (no fan-out)
4. User opens app → Mobile Client requests feed
5. Stream Processor reads from both Redis Caches (regular + celebrity)
6. Stream Processor merges and ranks posts
7. Combined feed returned to Mobile Client
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('Analytics Engine', 'Data Processing', 200, 200),
      _createIcon('Message Queue', 'Application Services', 400, 200),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 200),
      _createIcon('Redis Cache', 'Caching,Performance', 400, 500),
      _createIcon('Stream Processor', 'Data Processing', 600, 350),
      _createIcon('Content Storage', 'Database & Storage', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Post'),
      _createConnection(1, 2, label: 'Regular'),
      _createConnection(1, 4, label: 'Celebrity'),
      _createConnection(2, 3, label: 'Write'),
      _createConnection(0, 5, label: 'Read'),
      _createConnection(3, 5, label: 'Cached'),
      _createConnection(4, 5, label: 'Live'),
      _createConnection(5, 6, label: 'Fetch'),
    ],
  };

  // DESIGN 5: Ranked Feed with ML
  static Map<String, dynamic> get rankedFeedArchitecture => {
    'name': 'Ranked Feed with ML',
    'description': 'ML-powered relevance ranking',
    'explanation': '''
## Ranked Feed with ML Architecture

### What This System Does
Instead of chronological order, use machine learning to show the most relevant posts first. Facebook, Instagram, and TikTok all do this.

### How It Works Step-by-Step

**Step 1: Collect Candidates**
Gather potential posts for user's feed:
- Posts from followed accounts
- Suggested posts
- Ads
- Typically 500-1000 candidates

**Step 2: Extract Features**
For each post, compute features:
```json
{
  "post_age_hours": 2.5,
  "author_interaction_score": 0.8,
  "post_engagement_rate": 0.15,
  "content_type": "image",
  "is_from_close_friend": true,
  "user_interest_match": 0.7
}
```

**Step 3: User Features**
User's preferences and behavior:
```json
{
  "prefers_images": true,
  "active_time_of_day": "evening",
  "engagement_rate": 0.3,
  "close_friends": ["bob", "carol"]
}
```

**Step 4: ML Model Scores**
Model predicts probability of engagement:
```
Post A: P(like) = 0.85, P(comment) = 0.12
Post B: P(like) = 0.45, P(comment) = 0.02
Post C: P(like) = 0.92, P(comment) = 0.25

Final score = weighted combination
```

**Step 5: Rank and Diversify**
Sort by score, but add diversity:
- Don't show 10 posts from same author
- Mix content types
- Spread ads evenly

**Step 6: A/B Testing**
Continuously improve:
- Test different ranking formulas
- Measure user engagement
- Update model weights

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Candidate Generator | Gets potential posts | Raw material |
| Feature Extractor | Computes features | Model input |
| ML Ranker | Scores posts | Relevance |
| Diversity Filter | Prevents monotony | User experience |
| A/B Test Framework | Experiments | Improvement |

### Common Features for Ranking
```
Post Features:
- Age, engagement rate, content type
- Author's overall popularity
- Comments, likes, shares

User Features:
- Past interactions with author
- Content type preferences
- Active times

Contextual:
- Time of day
- Device type
- Session length
```

### Ranking Formula Example
```python
score = (
    0.3 * author_interaction_score +
    0.2 * content_type_preference +
    0.2 * engagement_prediction +
    0.15 * recency_score +
    0.1 * social_proof_score +
    0.05 * diversity_bonus
)
```

### Icons Explained

**Mobile Client** - The user's phone app requesting a personalized, ranked feed.

**Recommendation Engine** - Gathers all potential posts (candidates) from followed accounts and suggestions.

**Analytics Engine (top)** - Extracts features from each post: age, engagement rate, content type, author popularity.

**Analytics Engine (bottom)** - Extracts user features: preferences, past interactions, active times, close friends.

**Recommendation Engine (middle)** - The ML model that scores each post based on predicted engagement probability.

**Recommendation Engine (right)** - Adds diversity filtering so users don't see 10 posts from the same author.

**Analytics Service** - Runs A/B experiments to test different ranking formulas and improve the model.

### How They Work Together

1. Mobile Client requests feed
2. Recommendation Engine gathers 500-1000 candidate posts
3. Analytics Engine (top) extracts post features
4. Analytics Engine (bottom) extracts user preferences
5. Both feature sets feed into ML Recommendation Engine for scoring
6. Diversity Recommendation Engine ensures variety in final feed
7. Analytics Service runs experiments to continuously improve rankings
8. Ranked, diverse feed returned to Mobile Client
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('Recommendation Engine', 'Application Services', 200, 350),
      _createIcon('Analytics Engine', 'Data Processing', 400, 200),
      _createIcon('Analytics Engine', 'Database & Storage', 400, 350),
      _createIcon('Recommendation Engine', 'Data Processing', 600, 350),
      _createIcon('Recommendation Engine', 'Data Processing', 800, 350),
      _createIcon('Analytics Service', 'Application Services', 600, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Request'),
      _createConnection(1, 2, label: 'Posts'),
      _createConnection(1, 3, label: 'User'),
      _createConnection(2, 4, label: 'Features'),
      _createConnection(3, 4, label: 'Features'),
      _createConnection(4, 5, label: 'Ranked'),
      _createConnection(5, 0, label: 'Feed'),
      _createConnection(6, 4, label: 'Experiment'),
    ],
  };

  // DESIGN 6: Real-time Feed Updates
  static Map<String, dynamic> get realtimeArchitecture => {
    'name': 'Real-time Feed Updates',
    'description': 'Push new posts to users instantly',
    'explanation': '''
## Real-time Feed Updates Architecture

### What This System Does
Instead of users refreshing to see new posts, push new posts to them instantly. Like Twitter's "X new posts" notification.

### How It Works Step-by-Step

**Step 1: User Opens App**
User connects via WebSocket:
```javascript
ws.connect("wss://feed.app.com/stream")
ws.send({ type: "subscribe", user_id: "alice" })
```

**Step 2: Connection Registered**
Presence Service tracks connected users:
```
alice: connected to server-5
bob: connected to server-12
carol: offline
```

**Step 3: New Post Created**
Bob posts something.
Post Service publishes event:
```json
{
  "type": "new_post",
  "author": "bob",
  "post_id": "123"
}
```

**Step 4: Find Online Followers**
Stream Service queries:
- Who follows Bob?
- Who is currently online?
- Intersection: [alice, dave]

**Step 5: Push to Connected Users**
Send update via WebSocket:
```javascript
// To Alice's connection
ws.send({ 
  type: "new_post_notification",
  author: "bob",
  preview: "Check out my..."
})
```

**Step 6: Client Updates UI**
App shows notification:
- "1 new post" banner at top
- User taps to refresh feed
- New post appears instantly

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| WebSocket Server | Maintains connections | Real-time |
| Presence Service | Tracks online users | Target delivery |
| Stream Service | Routes updates | Distribution |
| Pub/Sub | Message broadcast | Scale |
| Connection Registry | Maps users to servers | Routing |

### Connection Management
```
Challenges:
- Millions of concurrent connections
- Users reconnect frequently
- Mobile connections unstable

Solutions:
- Sticky sessions to same server
- Automatic reconnection
- Fallback to polling
- Connection heartbeats
```

### Pub/Sub for Scale
```
Without Pub/Sub:
Bob posts → Server 5 notifies followers
But Alice is on Server 12!

With Pub/Sub (Redis):
Bob posts → Publish to "bob_posts" channel
All servers subscribe → Each notifies local users
```

### Icons Explained

**Mobile Client** - The user's phone app that maintains a persistent WebSocket connection for real-time updates.

**WebSocket Server** - Keeps long-lived connections open with all connected users for instant push delivery.

**User Presence** - Tracks which users are currently online and which server they're connected to.

**Content Publishing** - Handles new posts being created and publishes events about them.

**Event Stream** - Routes new post events to the right users by checking who follows the author and is online.

**Message Queue** - Broadcasts messages across all servers so every online follower gets notified regardless of which server they're on.

**Configuration Service** - Maps user IDs to their WebSocket connections so updates reach the correct client.

### How They Work Together

1. User opens app → Mobile Client connects to WebSocket Server
2. WebSocket Server registers connection with User Presence
3. When someone posts → Content Publishing creates event
4. Event sent to Message Queue for broadcast
5. Event Stream checks User Presence: who follows author and is online?
6. Event Stream looks up Configuration Service to find connection IDs
7. WebSocket Server pushes "1 new post" notification to Mobile Client
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('WebSocket Server', 'Networking', 200, 350),
      _createIcon('User Presence', 'Application Services', 400, 200),
      _createIcon('Content Publishing', 'Application Services', 400, 350),
      _createIcon('Event Stream', 'Application Services', 400, 500),
      _createIcon('Message Queue', 'Message Systems', 600, 350),
      _createIcon('Configuration Service', 'Caching,Performance', 600, 500),
    ],
    'connections': [
      _createConnection(0, 1, label: 'WebSocket'),
      _createConnection(1, 2, label: 'Online'),
      _createConnection(3, 5, label: 'New Post'),
      _createConnection(5, 4, label: 'Event'),
      _createConnection(2, 4, label: 'Who Online'),
      _createConnection(4, 6, label: 'Find Conn'),
      _createConnection(4, 1, label: 'Push'),
    ],
  };

  // DESIGN 7: Notification System
  static Map<String, dynamic> get notificationArchitecture => {
    'name': 'Notification System',
    'description': 'Push notifications for likes, comments, mentions',
    'explanation': '''
## Notification System Architecture

### What This System Does
When someone likes your post, comments, or mentions you, you get a notification. This system handles all notification types and delivery channels.

### How It Works Step-by-Step

**Step 1: Action Occurs**
Bob likes Alice's photo.
Event generated:
```json
{
  "type": "like",
  "actor": "bob",
  "target_user": "alice",
  "object": "photo_123"
}
```

**Step 2: Notification Created**
Notification Service creates record:
```json
{
  "id": "notif_456",
  "user": "alice",
  "type": "like",
  "message": "Bob liked your photo",
  "read": false,
  "created_at": 1642000000
}
```

**Step 3: Aggregation**
Multiple similar notifications grouped:
```
"Bob and 5 others liked your photo"
Instead of 6 separate notifications
```

**Step 4: Delivery Routing**
Check user's preferences:
- In-app: Always
- Push notification: If not active
- Email: Daily digest only
- SMS: Critical only

**Step 5: Push to Device**
Send via APNS (iOS) or FCM (Android):
```json
{
  "to": "device_token_xyz",
  "notification": {
    "title": "New Like",
    "body": "Bob liked your photo"
  }
}
```

**Step 6: Track Delivery**
Monitor notification status:
- Sent, delivered, opened
- Optimize timing for engagement
- Honor do-not-disturb

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Event Collector | Captures actions | Source events |
| Notification Service | Creates notifications | Core logic |
| Aggregator | Groups similar | Reduce noise |
| Router | Decides channels | User preferences |
| Push Service | Sends to devices | Mobile delivery |
| Email Service | Sends emails | Digest/alerts |

### Notification Types
```
Type          Priority    Default Delivery
──────────────────────────────────────────────
Mention       High        Push + In-app
Comment       Medium      Push + In-app
Like          Low         In-app only
Follower      Low         In-app only
Friend post   Low         In-app only
```

### Aggregation Rules
```
Within 1 hour:
- Multiple likes → "X and Y others liked"
- Multiple follows → "X and Y others followed"

Different rules per type:
- Comments: Never aggregate (each unique)
- Likes: Aggregate after 2
- Follows: Aggregate after 5
```

### Icons Explained

**Metrics Collector** - Captures all user actions (likes, comments, mentions, follows) as notification-triggering events.

**Notification Service** - Core service that creates notification records and decides what message to show.

**Stream Processor** - Aggregates similar notifications (e.g., "Bob and 5 others liked your photo" instead of 6 separate notifications).

**Load Balancer** - Routes notifications to the right delivery channel based on user preferences and notification type.

**Push Notification** - Sends mobile push notifications via APNS (iOS) or FCM (Android) for urgent alerts.

**Email Service** - Handles email notifications for digests and alerts when users prefer email.

**SMS Service** - Sends text messages for critical notifications only (security alerts, account issues).

**NoSQL Database** - Stores all notification records with read/unread status for in-app notification history.

### How They Work Together

1. User action (like, comment, mention) → Metrics Collector captures event
2. Notification Service creates notification record
3. Stream Processor aggregates if multiple similar notifications exist
4. Notification stored in NoSQL Database for in-app viewing
5. Load Balancer checks user preferences and routes to appropriate channel
6. Depending on settings: Push Notification, Email Service, or SMS Service delivers
''',
    'icons': [
      _createIcon('Metrics Collector', 'Data Processing', 50, 350),
      _createIcon('Notification Service', 'Application Services', 200, 350),
      _createIcon('Stream Processor', 'Data Processing', 400, 350),
      _createIcon('Load Balancer', 'Networking', 600, 350),
      _createIcon('Push Notification', 'Application Services', 800, 200),
      _createIcon('Email Service', 'Application Services', 800, 350),
      _createIcon('SMS Service', 'Application Services', 800, 500),
      _createIcon('NoSQL Database', 'Database & Storage', 400, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Event'),
      _createConnection(1, 2, label: 'Create'),
      _createConnection(2, 7, label: 'Store'),
      _createConnection(2, 3, label: 'Route'),
      _createConnection(3, 4, label: 'Push'),
      _createConnection(3, 5, label: 'Email'),
      _createConnection(3, 6, label: 'SMS'),
    ],
  };

  // DESIGN 8: Feed Caching Strategy
  static Map<String, dynamic> get cachingArchitecture => {
    'name': 'Feed Caching Strategy',
    'description': 'Multi-layer caching for fast feed delivery',
    'explanation': '''
## Feed Caching Strategy Architecture

### What This System Does
Reading from database for every feed request is slow. This system uses multiple cache layers to serve feeds in milliseconds.

### How It Works Step-by-Step

**Step 1: Request Arrives**
Alice opens app, requests feed.

**Step 2: Check Edge Cache (CDN)**
CDN has cached feeds for anonymous/public content.
Not useful for personalized feeds.

**Step 3: Check Application Cache**
Local in-memory cache on app server:
- Very fast (microseconds)
- Limited size
- Contains recent requests

**Step 4: Check Distributed Cache (Redis)**
User's feed cached in Redis:
```
LRANGE alice_feed 0 19
→ ["post_1", "post_2", ..., "post_20"]
```

**Step 5: Cache Miss → Compute**
If not in cache:
- Compute feed (fan-out on read)
- Store in Redis for next time
- Set TTL (e.g., 5 minutes)

**Step 6: Warm Cache on Post**
When new post created:
- Invalidate affected feeds
- Or append to cached feeds
- Keep cache fresh

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| CDN | Edge caching | Static content |
| App Cache | In-memory local | Hot data |
| Redis Cluster | Distributed cache | Shared state |
| Cache Warmer | Pre-populates cache | Cold start |
| Invalidator | Clears stale data | Consistency |

### Cache Hierarchy
```
Layer          Latency    Size      Scope
───────────────────────────────────────────
L1 (App)       <1ms       1GB       Per server
L2 (Redis)     1-5ms      100GB     Shared
L3 (DB)        10-50ms    10TB      Persistent

Request path: L1 → L2 → L3
```

### Cache Keys
```
Feed cache:
feed:{user_id}:latest → [post_ids]
feed:{user_id}:page:{n} → [post_ids]

Post cache:
post:{post_id} → {title, content, author...}

User cache:
user:{user_id} → {name, avatar, followers...}
```

### Invalidation Strategies
```
1. TTL-based:
   - Feed expires every 5 minutes
   - Simple but can be stale

2. Event-based:
   - New post → Invalidate followers' feeds
   - More complex but fresher

3. Append-only:
   - New post → Prepend to cached feed
   - Never invalidate, just update
```

### Icons Explained

**Mobile Client** - The user's phone app requesting their feed as fast as possible.

**CDN** - Edge cache close to users, great for static content but not personalized feeds.

**Redis Cache (L1)** - Local in-memory cache on the app server (microsecond access, limited size).

**Redis Cache (L2)** - Distributed Redis cache shared across all servers (millisecond access, large capacity).

**Feed Generation** - Service that computes the feed when there's a cache miss (fan-out on read).

**Scheduler** - Cache warmer that pre-populates caches for active users before they request feeds.

**SQL Database** - The source of truth storing all posts, follows, and user data.

### How They Work Together

1. Mobile Client requests feed → hits CDN first
2. CDN miss → Check Redis Cache L1 (local, ultra-fast)
3. L1 miss → Check Redis Cache L2 (distributed, still fast)
4. L2 miss → Feed Generation computes feed from SQL Database
5. Generated feed stored back in Redis Cache L2 for next time
6. Scheduler proactively warms caches for active users
7. Result: 95%+ cache hit rate, <200ms feed delivery
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('CDN', 'Networking', 200, 350),
      _createIcon('Redis Cache', 'Caching,Performance', 400, 200),
      _createIcon('Redis Cache', 'Caching,Performance', 400, 350),
      _createIcon('Feed Generation', 'Application Services', 400, 500),
      _createIcon('Scheduler', 'System Utilities', 600, 200),
      _createIcon('SQL Database', 'Database & Storage', 600, 450),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Request'),
      _createConnection(1, 2, label: 'Check L1'),
      _createConnection(2, 3, label: 'Check L2'),
      _createConnection(3, 4, label: 'Miss'),
      _createConnection(4, 6, label: 'Fetch'),
      _createConnection(4, 3, label: 'Populate'),
      _createConnection(5, 3, label: 'Warm'),
    ],
  };

  // DESIGN 9: Analytics and Metrics
  static Map<String, dynamic> get analyticsArchitecture => {
    'name': 'Analytics and Metrics',
    'description': 'Tracking engagement and feed performance',
    'explanation': '''
## Analytics and Metrics Architecture

### What This System Does
Measure everything: what users see, what they engage with, how long they stay. This data improves the ranking algorithm and product decisions.

### How It Works Step-by-Step

**Step 1: Impression Logged**
When post appears on screen:
```json
{
  "event": "impression",
  "user": "alice",
  "post": "123",
  "position": 3,
  "timestamp": 1642000000
}
```

**Step 2: Engagement Logged**
When user interacts:
```json
{
  "event": "like",
  "user": "alice",
  "post": "123",
  "time_to_engage": 5.2
}
```

**Step 3: Events Streamed**
All events sent to Kafka:
- High throughput (millions/second)
- Durable for replay
- Partitioned by user

**Step 4: Real-time Processing**
Stream processor computes live metrics:
- Active users right now
- Trending posts
- Engagement rates

**Step 5: Batch Analytics**
Daily/weekly jobs compute:
- Daily active users
- Average session length
- Feed completion rate
- A/B test results

**Step 6: Dashboard & Alerts**
Metrics displayed and monitored:
- Real-time dashboards
- Alerts on anomalies
- Reports for product team

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Event Collector | Captures all events | Data source |
| Kafka | Event streaming | Scale & durability |
| Stream Processor | Real-time metrics | Live data |
| Batch Processor | Historical analytics | Deep analysis |
| Data Warehouse | Stores all data | Query & report |
| Dashboard | Visualizes metrics | Decision making |

### Key Metrics
```
Engagement:
- Likes per post, comments per post
- Engagement rate (actions / impressions)
- Time to first engagement

Feed Health:
- Feed completion rate (% who scroll to end)
- Time spent in feed
- Posts seen per session

Ranking Quality:
- Click-through rate by position
- Engagement vs. prediction
- A/B test lift
```

### Event Volume
```
100M daily active users
Average 50 impressions per session
2 sessions per day

= 10 billion impressions/day
+ billions of actions

Need serious scale!
```

### Icons Explained

**Mobile Client** - The user's phone app that tracks every impression, tap, scroll, and engagement action.

**Metrics Collector** - Gathers all events from clients and tags them with metadata (user, timestamp, position).

**Message Queue** - High-throughput event streaming (like Kafka) that handles millions of events per second durably.

**Stream Processor** - Processes events in real-time to compute live metrics: active users, trending posts, engagement rates.

**Batch Processor** - Runs daily/weekly jobs for deep analytics: daily active users, session lengths, A/B test results.

**Data Warehouse** - Stores all historical data for querying, reporting, and training ML models.

**Analytics Service** - Dashboards and alerting that visualize metrics and notify teams of anomalies.

### How They Work Together

1. Every action on Mobile Client generates events (impressions, likes, scrolls)
2. Metrics Collector captures and enriches events with context
3. All events stream through Message Queue for durability and scale
4. Stream Processor provides real-time dashboards (who's online right now?)
5. Batch Processor runs overnight for comprehensive reports
6. Both write results to Data Warehouse for historical analysis
7. Analytics Service displays dashboards and sends alerts to product teams
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('Metrics Collector', 'Data Processing', 200, 350),
      _createIcon('Message Queue', 'Message Systems', 400, 350),
      _createIcon('Stream Processor', 'Data Processing', 600, 200),
      _createIcon('Batch Processor', 'Data Processing', 600, 500),
      _createIcon('Data Warehouse', 'Database & Storage', 800, 350),
      _createIcon('Analytics Service', 'Client & Interface', 950, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Events'),
      _createConnection(1, 2, label: 'Stream'),
      _createConnection(2, 3, label: 'Real-time'),
      _createConnection(2, 4, label: 'Batch'),
      _createConnection(3, 5, label: 'Store'),
      _createConnection(4, 5, label: 'Store'),
      _createConnection(5, 6, label: 'Query'),
    ],
  };

  // DESIGN 10: Complete News Feed System
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete News Feed System',
    'description': 'Full-featured social media feed',
    'explanation': '''
## Complete News Feed System Architecture

### What This System Does
This is a production news feed combining: hybrid fan-out, ML ranking, real-time updates, notifications, caching, and analytics. Think Facebook or Twitter scale.

### How It Works Step-by-Step

**Step 1: Post Created**
User creates post → Stored → Fan-out begins (hybrid approach)

**Step 2: Feed Requested**
User opens app → Check cache → Merge regular + celebrity → ML rank → Return

**Step 3: Real-time Updates**
New posts → Push to online users → "N new posts" notification

**Step 4: Engagement**
User likes/comments → Create notification → Update analytics

**Step 5: Continuous Improvement**
Analytics → Train ML → Better ranking → Happier users

### Full Component List

| Category | Components |
|----------|------------|
| Client | Mobile App, Web App |
| Ingestion | Post Service, Media Service |
| Distribution | Fan-out, Merge, Cache |
| Ranking | ML Model, Feature Store |
| Real-time | WebSocket, Pub/Sub |
| Engagement | Likes, Comments, Shares |
| Notifications | Push, Email, In-app |
| Analytics | Events, Metrics, Dashboard |
| Storage | Posts, Feeds, Social Graph |

### Scale Numbers
```
Daily Active Users: 100 million
Posts per day: 50 million
Feed reads per day: 500 million
Notifications per day: 2 billion
Cache hit rate: 95%
Feed latency: <200ms (p99)
```

### Architecture Principles
1. **Hybrid Fan-out**: Balance write and read
2. **Cache Everything**: Feeds, posts, users
3. **Rank Smart**: ML-powered relevance
4. **Push Updates**: Real-time experience
5. **Measure All**: Data-driven decisions

### Icons Explained

**Mobile Client** - Phone app users access the feed through.

**Web Browser** - Desktop/laptop users access the feed through.

**API Gateway** - Single entry point that routes all requests to the right internal services.

**Content Publishing** - Handles creating and storing new posts with media.

**Feed Generation** - Builds personalized feeds using hybrid fan-out (write for regular users, read for celebrities).

**Notification Service** - Sends push notifications for likes, comments, and new posts from followed accounts.

**Redis Cache** - Stores pre-computed feeds and hot data for fast access.

**Recommendation Engine** - ML model that ranks posts by predicted engagement and relevance.

**Content Storage** - Main database for all posts, media references, and content metadata.

**Social Graph Service** - Stores who follows whom, friend relationships, and social connections.

**Analytics Engine** - Tracks all user activity for improving rankings and making product decisions.

### How They Work Together

1. Mobile Client or Web Browser sends request to API Gateway
2. For posting: API Gateway → Content Publishing → Content Storage
3. For reading: API Gateway → Feed Generation
4. Feed Generation checks Redis Cache, uses Social Graph Service for follows
5. Recommendation Engine ranks the posts by relevance
6. Notification Service pushes real-time updates to Mobile Client
7. Analytics Engine tracks everything to improve the ML model
8. Result: Fast, personalized, real-time feed at Facebook/Twitter scale
''',
    'icons': [
      _createIcon('Mobile Client', 'Client & Interface', 50, 200),
      _createIcon('Web Browser', 'Client & Interface', 50, 400),
      _createIcon('API Gateway', 'Networking', 200, 300),
      _createIcon('Content Publishing', 'Application Services', 400, 150),
      _createIcon('Feed Generation', 'Application Services', 400, 300),
      _createIcon('Notification Service', 'Application Services', 400, 450),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 200),
      _createIcon('Recommendation Engine', 'Data Processing', 600, 350),
      _createIcon('Content Storage', 'Database & Storage', 800, 200),
      _createIcon('Social Graph Service', 'Database & Storage', 800, 350),
      _createIcon('Analytics Engine', 'Data Processing', 800, 500),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      _createConnection(2, 3, label: 'Create'),
      _createConnection(2, 4, label: 'Feed'),
      _createConnection(3, 8, label: 'Store'),
      _createConnection(4, 6, label: 'Cache'),
      _createConnection(4, 7, label: 'Rank'),
      _createConnection(4, 9, label: 'Graph'),
      _createConnection(5, 0, label: 'Push'),
      _createConnection(4, 10, label: 'Events'),
    ],
  };

  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      fanoutWriteArchitecture,
      fanoutReadArchitecture,
      hybridArchitecture,
      rankedFeedArchitecture,
      realtimeArchitecture,
      notificationArchitecture,
      cachingArchitecture,
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
          'color': conn['color'] ?? 0xFF3F51B5,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
        });
      }
    }
    return lines;
  }
}
