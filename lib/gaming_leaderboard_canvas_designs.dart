// Gaming Leaderboard System - Canvas Design Data
// Contains predefined system designs using available canvas icons

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined Gaming Leaderboard system designs for the canvas
class GamingLeaderboardCanvasDesigns {
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
    int color = 0xFF00BCD4,
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

  // DESIGN 1: Basic Leaderboard
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic Gaming Leaderboard',
    'description': 'Simple leaderboard with real-time score updates',
    'explanation': '''
## Basic Gaming Leaderboard Architecture

### What This System Does
This is the simplest form of a gaming leaderboard. When players finish a game, their scores are recorded and ranked against all other players. Anyone can view the top players at any time.

### How It Works Step-by-Step

**Step 1: Player Submits Score**
When a player finishes a game, their Game Client (the app on their phone or PC) sends the score to the system. For example: "Player123 scored 5,000 points".

**Step 2: Request Reaches API Gateway**
The API Gateway is like a receptionist - it receives all incoming requests and checks if they're valid. It makes sure the request has proper authentication (is this really Player123?) and routes it to the right service.

**Step 3: Leaderboard Service Processes the Score**
This is the brain of the system. It takes the score and decides what to do:
- If it's a new score submission: Add it to the database
- If someone wants to see rankings: Fetch and return them

**Step 4: Redis Sorted Set Stores Rankings**
Redis is an ultra-fast in-memory database. It uses a "Sorted Set" data structure which automatically keeps scores in order. When you add "Player123: 5000", Redis instantly knows where they rank among millions of players. The commands used are:
- ZADD leaderboard 5000 "Player123" (add/update score)
- ZREVRANGE leaderboard 0 99 (get top 100 players)

**Step 5: SQL Database Stores Permanent Data**
While Redis handles real-time rankings, the SQL Database stores permanent data like player profiles, game history, and detailed statistics that need to survive server restarts.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Game Client | Player's app that sends scores | Users need an interface |
| Mobile Client | Same as above, for phones | Support multiple platforms |
| API Gateway | Receives and validates requests | Security and routing |
| Leaderboard Service | Business logic for rankings | Core functionality |
| Redis Sorted Set | Fast score storage and ranking | O(log N) operations |
| SQL Database | Permanent data storage | Data persistence |

### Data Flow Summary
```
Player finishes game
       ↓
Game Client sends score via HTTP POST
       ↓
API Gateway validates request
       ↓
Leaderboard Service processes
       ↓
Redis ZADD updates ranking instantly
       ↓
SQL stores game history
       ↓
Response sent back to player with new rank
```

### Icons Explained

**Desktop Client** - The game running on PC/console that sends score submissions after gameplay.

**Mobile Client** - The game running on phones/tablets that also submits scores and views rankings.

**API Gateway** - Entry point that validates requests, checks authentication, and routes to the right service.

**Ranking Engine** - Core Leaderboard Service that processes score submissions and ranking queries.

**Redis Cache** - Ultra-fast in-memory storage using Sorted Sets to maintain rankings with O(log N) operations.

**SQL Database** - Permanent storage for player profiles, game history, and detailed statistics.

### How They Work Together

1. Player finishes game → Desktop/Mobile Client sends score via HTTP
2. API Gateway validates the request (is this a real player?)
3. Ranking Engine processes the score submission
4. Redis Cache stores score using ZADD (auto-ranks among all players)
5. SQL Database stores detailed game history and profile data
6. Player receives response with their new rank instantly
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 300),
      _createIcon('Mobile Client', 'Client & Interface', 50, 450),
      _createIcon('API Gateway', 'Networking', 250, 375),
      _createIcon('Ranking Engine', 'Application Services', 450, 375),
      _createIcon('Redis Cache', 'Caching,Performance', 650, 300),
      _createIcon('SQL Database', 'Database & Storage', 650, 450),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Submit Score'),
      _createConnection(1, 2, label: 'Get Rankings'),
      _createConnection(2, 3, label: 'Route'),
      _createConnection(3, 4, label: 'ZADD Score'),
      _createConnection(3, 5, label: 'Store Profile'),
      _createConnection(4, 3, label: 'ZREVRANGE'),
    ],
  };

  // DESIGN 2: Scalable Leaderboard
  static Map<String, dynamic> get scalableArchitecture => {
    'name': 'Scalable Gaming Leaderboard',
    'description': 'Horizontally scalable leaderboard for millions of players',
    'explanation': '''
## Scalable Gaming Leaderboard Architecture

### What This System Does
This design handles millions of players submitting scores simultaneously. It distributes the load across multiple servers and regions so no single component becomes a bottleneck.

### How It Works Step-by-Step

**Step 1: Request Hits CDN**
Before anything else, the CDN (Content Delivery Network) intercepts the request. CDNs have servers worldwide, so a player in Tokyo connects to a nearby CDN server instead of one far away. This reduces latency from 200ms to 20ms.

**Step 2: Global Load Balancer Routes Traffic**
The Load Balancer looks at incoming traffic and decides which server cluster should handle it. It considers:
- Which servers are least busy
- Which servers are geographically closest
- Which servers are healthy (not crashed)

**Step 3: Rate Limiter Prevents Abuse**
Before processing, the Rate Limiter checks if this user is sending too many requests. Rules might be:
- Max 10 score submissions per minute per user
- Max 100 leaderboard views per minute per user
This prevents hackers from overwhelming the system.

**Step 4: Message Queue Buffers Spikes**
During a game tournament, you might get 100,000 score submissions in 1 second. The Message Queue (like Kafka or RabbitMQ) acts as a buffer - it accepts all requests instantly and lets the backend process them at its own pace. No data is lost.

**Step 5: Multiple Server Clusters Process in Parallel**
Instead of one server, we have many clusters (groups of servers). Each cluster processes a portion of the traffic. If one cluster fails, others continue working.

**Step 6: Redis Cluster Shards Data**
One Redis instance can't hold 100 million players. So we "shard" the data:
- Shard 1: Players A-M
- Shard 2: Players N-Z
Each shard handles fewer players, making lookups fast.

**Step 7: Leaderboard Cache Stores Hot Data**
The top 1000 players are requested constantly. Instead of hitting Redis every time, we cache this list and refresh it every few seconds.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| CDN | Caches content at edge locations | Reduces global latency |
| Global Load Balancer | Distributes traffic across regions | Prevents overload |
| Rate Limiter | Blocks excessive requests | Prevents abuse/DDoS |
| Message Queue | Buffers traffic spikes | Handles bursts |
| Leaderboard Service | Processes requests in parallel | Horizontal scaling |
| Score Aggregator | Batches score updates | Reduces database writes |
| Redis Cluster | Sharded score storage | Scales to billions |
| Leaderboard Cache | Caches top players | Faster common queries |
| NoSQL Database | Stores all historical data | Permanent storage |

### Scaling Strategy
```
Current: 1 million players
Add more server clusters when CPU > 70%
Add more Redis shards when memory > 80%
Add more regions when latency > 100ms for users

Future: 100 million players
- 10 server clusters
- 20 Redis shards
- 5 geographic regions
```

### Icons Explained

**Desktop Client** - PC/console game clients submitting scores and viewing leaderboards.

**Mobile Client** - Phone/tablet game clients with the same functionality.

**CDN** - Edge servers worldwide that cache static content close to players for faster loading.

**Global Load Balancer** - Distributes traffic across multiple server clusters by proximity and load.

**Rate Limiter** - Prevents abuse by limiting requests (e.g., max 10 score submissions per minute).

**Message Queue** - Buffers traffic spikes (like during tournaments) so backend isn't overwhelmed.

**Ranking Engine** - Main Leaderboard Service processing scores and queries in parallel clusters.

**Score Processing** - Aggregator that batches score updates to reduce database write load.

**Redis Cache (Shard 1 & 2)** - Sharded Redis cluster where each shard handles a subset of players.

**NoSQL Database** - Permanent storage for all historical data and player information.

### How They Work Together

1. Request hits CDN → cached content served instantly
2. Dynamic requests → Global Load Balancer routes to nearest healthy cluster
3. Rate Limiter checks for abuse before processing
4. Write requests → Message Queue buffers the spike
5. Score Processing batches updates → Redis Shards updated efficiently
6. Read requests → Ranking Engine queries Redis Cache directly
7. All data persisted to NoSQL Database for durability
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 250),
      _createIcon('Mobile Client', 'Client & Interface', 50, 400),
      _createIcon('CDN', 'Networking', 200, 325),
      _createIcon('Global Load Balancer', 'Networking', 350, 325),
      _createIcon('Rate Limiter', 'Networking', 500, 200),
      _createIcon('Message Queue', 'Message Systems', 500, 450),
      _createIcon('Ranking Engine', 'Application Services', 650, 325),
      _createIcon('Score Processing', 'Data Processing', 650, 500),
      _createIcon('Redis Cache', 'Caching,Performance', 850, 250),
      _createIcon('Redis Cache', 'Caching,Performance', 850, 400),
      _createIcon('NoSQL Database', 'Database & Storage', 1050, 325),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      _createConnection(2, 3, label: 'Forward'),
      _createConnection(3, 4, label: 'Check Rate'),
      _createConnection(3, 6, label: 'Read Path'),
      _createConnection(4, 5, label: 'Queue Score'),
      _createConnection(5, 7, label: 'Batch Process'),
      _createConnection(7, 8, label: 'Update Scores'),
      _createConnection(6, 9, label: 'Get Top N'),
      _createConnection(6, 8, label: 'Direct Read'),
      _createConnection(8, 10, label: 'Persist'),
    ],
  };

  // DESIGN 3: Real-time Leaderboard
  static Map<String, dynamic> get realtimeArchitecture => {
    'name': 'Real-time Leaderboard',
    'description': 'WebSocket-based live leaderboard updates',
    'explanation': '''
## Real-time Leaderboard Architecture

### What This System Does
Instead of players refreshing the page to see updates, this system PUSHES ranking changes to them instantly. When someone takes the #1 spot, everyone watching sees it within milliseconds.

### How It Works Step-by-Step

**Step 1: Player Opens Leaderboard Page**
When a player opens the leaderboard, their client establishes a WebSocket connection. Unlike HTTP (which closes after each request), WebSocket stays open like a phone call - both sides can send messages anytime.

**Step 2: Connection Manager Tracks Subscribers**
The Connection Manager keeps a list of everyone watching each leaderboard:
- "Leaderboard_GameA": [Player1, Player2, Player3...]
- "Leaderboard_GameB": [Player4, Player5...]
It also handles reconnections when someone's internet drops temporarily.

**Step 3: Player Submits Score via HTTP**
Score submissions still use regular HTTP (more reliable for important data). The score goes through the API Gateway to the Leaderboard Service.

**Step 4: Leaderboard Service Updates Redis**
The score is added to Redis. Redis returns the player's new rank.

**Step 5: Change Detection Monitors Rankings**
A background process constantly watches for ranking changes:
- "Player123 moved from rank 5 to rank 3"
- "Player456 dropped out of top 100"
When a significant change happens, it triggers a notification.

**Step 6: Pub/Sub Broadcasts Changes**
Redis Pub/Sub (Publish/Subscribe) is like a radio broadcast. The Change Detection service "publishes" the update to a channel. All WebSocket Gateways "subscribe" to this channel and receive the update.

**Step 7: WebSocket Pushes to Clients**
Each WebSocket Gateway looks at its connected clients and sends the relevant update. The client's leaderboard updates without any page refresh.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| WebSocket Gateway | Maintains live connections | Real-time communication |
| Connection Manager | Tracks who's watching what | Targeted updates |
| API Gateway | Handles score submissions | Reliable writes |
| Leaderboard Service | Processes scores | Core logic |
| Change Detection | Monitors rank changes | Triggers notifications |
| Redis Sorted Set | Stores rankings | Fast operations |
| Pub/Sub System | Broadcasts updates | Decouples components |
| SQL Database | Permanent storage | Data persistence |

### Real-time Flow Example
```
12:00:00.000 - Player "ProGamer" submits score 10,000
12:00:00.050 - Redis ZADD updates score
12:00:00.051 - ProGamer's rank: 3 → 1 detected
12:00:00.052 - Pub/Sub publishes: "rank_change:ProGamer:1"
12:00:00.053 - WebSocket Gateways receive message
12:00:00.055 - 50,000 connected clients see update
12:00:00.055 - Total time: 55 milliseconds
```

### Why Not Just Poll?
Polling (refreshing every second) would mean:
- 50,000 users × 1 request/second = 50,000 requests/second
- Most requests return "no changes"
- Wastes bandwidth and server resources

With WebSocket:
- 50,000 persistent connections (low overhead)
- Only send data when something changes
- Updates are instant, not delayed by 1 second

### Icons Explained

**Desktop Client** - PC game client that maintains WebSocket connection for live updates.

**Mobile Client** - Phone game client that also uses WebSocket for real-time leaderboard.

**WebSocket Server** - Gateway that keeps persistent connections open with all watching players.

**WebSocket Server (Connection Manager)** - Tracks which players are watching which leaderboards.

**API Gateway** - Handles HTTP score submissions (more reliable than WebSocket for writes).

**Ranking Engine** - Core Leaderboard Service that processes scores and updates rankings.

**Stream Processor** - Change Detection that monitors for ranking changes and triggers notifications.

**Redis Cache** - Sorted Set storage where ranking updates happen instantly.

**Message Queue** - Pub/Sub system that broadcasts ranking changes to all WebSocket servers.

**SQL Database** - Permanent storage for all scores and player history.

### How They Work Together

1. Player opens leaderboard → WebSocket connection established
2. WebSocket Server registers them with Connection Manager
3. Player submits score via HTTP → API Gateway → Ranking Engine
4. Ranking Engine updates Redis Cache with new score
5. Stream Processor detects ranking change
6. Change published to Message Queue (Pub/Sub)
7. All WebSocket Servers receive update → push to watching clients
8. Player's leaderboard updates instantly without refresh
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 300),
      _createIcon('Mobile Client', 'Client & Interface', 50, 450),
      _createIcon('WebSocket Server', 'Networking', 250, 375),
      _createIcon('WebSocket Server', 'System Utilities', 250, 550),
      _createIcon('API Gateway', 'Networking', 450, 250),
      _createIcon('Ranking Engine', 'Application Services', 450, 375),
      _createIcon('Stream Processor', 'Data Processing', 450, 550),
      _createIcon('Redis Cache', 'Caching,Performance', 650, 300),
      _createIcon('Message Queue', 'Message Systems', 650, 450),
      _createIcon('SQL Database', 'Database & Storage', 850, 375),
    ],
    'connections': [
      _createConnection(0, 2, label: 'WebSocket'),
      _createConnection(1, 2, label: 'WebSocket'),
      _createConnection(2, 3, label: 'Register'),
      _createConnection(0, 4, label: 'HTTP Score'),
      _createConnection(4, 5, label: 'Submit'),
      _createConnection(5, 7, label: 'Update'),
      _createConnection(7, 6, label: 'Detect Change'),
      _createConnection(6, 8, label: 'Publish'),
      _createConnection(8, 2, label: 'Notify'),
      _createConnection(5, 9, label: 'Persist'),
    ],
  };

  // DESIGN 4: Segmented Leaderboard
  static Map<String, dynamic> get segmentedArchitecture => {
    'name': 'Segmented Leaderboard',
    'description': 'Multiple leaderboards by time period, region, and tier',
    'explanation': '''
## Segmented Leaderboard Architecture

### What This System Does
Instead of one giant "all-time" leaderboard, this system maintains multiple separate leaderboards:
- Daily leaderboard (resets every day at midnight)
- Weekly leaderboard (resets every Monday)
- Monthly leaderboard (resets on the 1st)
- All-time leaderboard (never resets)
- Regional leaderboards (separate for each country/region)

### How It Works Step-by-Step

**Step 1: Player Submits Score**
The request comes in like normal, but now it contains extra info: timestamp, player's region, player's skill tier, etc.

**Step 2: Leaderboard Router Determines Segments**
The Router looks at the score and decides which leaderboards to update:
- Daily_2024_01_15 ✓
- Weekly_2024_W03 ✓
- Monthly_2024_01 ✓
- AllTime ✓
- Region_USA ✓
- Tier_Gold ✓

One score might update 6 different leaderboards!

**Step 3: Multiple Redis Instances Store Each Segment**
Each segment has its own Redis Sorted Set:
- Redis-Daily: leaderboard:2024-01-15
- Redis-Weekly: leaderboard:2024-W03
- Redis-AllTime: leaderboard:alltime

This keeps each leaderboard small and fast.

**Step 4: Segment Manager Handles Rotation**
At midnight UTC, the Segment Manager:
1. Creates a new daily segment: leaderboard:2024-01-16
2. Archives the old segment to the Data Warehouse
3. Optionally deletes very old segments from Redis

**Step 5: Scheduler Triggers Events**
A cron-like Scheduler runs at specific times:
- 00:00 UTC daily: Rotate daily segment
- 00:00 UTC Monday: Rotate weekly segment
- 00:00 UTC 1st of month: Rotate monthly segment

**Step 6: Analytics Engine Analyzes History**
Historical segments are valuable for analytics:
- "Top players tend to score highest on Saturdays"
- "Region_Asia has 3x more players than Region_EU"

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Leaderboard Router | Routes to correct segments | Multi-segment support |
| Segment Manager | Creates/archives segments | Lifecycle management |
| Scheduler | Triggers time-based events | Automation |
| Redis Daily | Current day's rankings | Fast daily queries |
| Redis Weekly | Current week's rankings | Fast weekly queries |
| Redis AllTime | Forever rankings | Historical best |
| Data Warehouse | Stores archived segments | Long-term analysis |
| Analytics Engine | Processes historical data | Business insights |

### Segment Rotation Example
```
Sunday 23:59:59 - Weekly leaderboard has 500,000 scores
Monday 00:00:00 - Scheduler triggers weekly rotation
Monday 00:00:01 - Segment Manager:
                  1. Renames "weekly_current" to "weekly_2024_W03"
                  2. Creates new empty "weekly_current"
                  3. Exports weekly_2024_W03 to Data Warehouse
Monday 00:00:05 - New weekly leaderboard is live, empty
Monday 00:00:10 - First score of the week is submitted
```

### Why Segment?
1. **Fresh Competition**: Daily resets give casual players a chance to be #1
2. **Reduced Size**: Each segment has fewer entries = faster queries
3. **Historical Analysis**: Track how the game meta changes over time
4. **Regional Fairness**: Players compete against similar timezones

### Icons Explained

**Desktop Client** - Player's game client requesting segmented leaderboard views.

**API Gateway** - Entry point that routes requests to the leaderboard system.

**Load Balancer** - Leaderboard Router that determines which segment(s) a score belongs to.

**Configuration Service** - Segment Manager that handles creation, rotation, and archival of segments.

**Scheduler** - Triggers time-based events like midnight rollovers and weekly resets.

**Redis Cache (Daily)** - Stores current day's leaderboard that resets at midnight.

**Redis Cache (Weekly)** - Stores current week's leaderboard that resets every Monday.

**Redis Cache (AllTime)** - Stores permanent all-time rankings that never reset.

**Data Warehouse** - Archives historical segments for long-term analysis.

**Analytics Engine** - Analyzes historical data to find patterns and trends.

### How They Work Together

1. Player submits score → API Gateway → Load Balancer (Router)
2. Router determines segments: Daily_today, Weekly_current, AllTime
3. Score written to all relevant Redis Cache instances
4. At midnight UTC → Scheduler triggers Configuration Service
5. Configuration Service rotates segments (new day starts fresh)
6. Old segments archived to Data Warehouse
7. Analytics Engine processes historical data for insights
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 375),
      _createIcon('API Gateway', 'Networking', 200, 375),
      _createIcon('Load Balancer', 'Application Services', 400, 375),
      _createIcon('Configuration Service', 'System Utilities', 400, 550),
      _createIcon('Scheduler', 'System Utilities', 250, 550),
      _createIcon(
        'Redis Cache',
        'Caching,Performance',
        600,
        200,
        id: 'Redis Daily',
      ),
      _createIcon(
        'Redis Cache',
        'Caching,Performance',
        600,
        350,
        id: 'Redis Weekly',
      ),
      _createIcon(
        'Redis Cache',
        'Caching,Performance',
        600,
        500,
        id: 'Redis AllTime',
      ),
      _createIcon('Data Warehouse', 'Database & Storage', 800, 375),
      _createIcon('Analytics Engine', 'Data Processing', 800, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Query'),
      _createConnection(1, 2, label: 'Route'),
      _createConnection(2, 5, label: 'Daily'),
      _createConnection(2, 6, label: 'Weekly'),
      _createConnection(2, 7, label: 'All-time'),
      _createConnection(4, 3, label: 'Trigger Rotation'),
      _createConnection(3, 5, label: 'Archive'),
      _createConnection(5, 8, label: 'Store History'),
      _createConnection(8, 9, label: 'Analyze'),
    ],
  };

  // DESIGN 5: Competitive Leaderboard
  static Map<String, dynamic> get competitiveArchitecture => {
    'name': 'Competitive Leaderboard',
    'description': 'Tournament and ranked match leaderboard with ELO ratings',
    'explanation': '''
## Competitive Leaderboard Architecture

### What This System Does
This is for serious competitive games like Chess, League of Legends, or VALORANT. Instead of raw scores, players have a "rating" (like ELO or MMR) that goes up when they win and down when they lose. The system also detects cheaters.

### How It Works Step-by-Step

**Step 1: Match Ends, Result Submitted**
When a match ends, the game server sends the result:
- Match ID: 12345
- Winner: Player_A (current rating: 1500)
- Loser: Player_B (current rating: 1450)
- Game duration: 25 minutes
- Suspicious activity: None

**Step 2: Anti-Cheat Service Validates**
Before calculating ratings, the Anti-Cheat Service checks:
- Did the match actually happen? (verify with game server)
- Was it suspiciously short? (possible win-trading)
- Did player stats look impossible? (aimbot, speedhack)
- Is this player's win rate abnormally high?

If suspicious, the match is flagged for human review.

**Step 3: Rating Calculator Computes New Ratings**
Using the ELO formula (or similar):
- Expected outcome based on rating difference
- K-factor (how much ratings can change)
- Underdog bonus (beating higher-rated players)

Example:
- Player_A (1500) beats Player_B (1450)
- Expected: Player_A had 57% chance to win
- Actual: Player_A won
- New ratings: Player_A = 1508, Player_B = 1442

**Step 4: Tier System Checks Promotion/Demotion**
Ratings map to visible tiers:
- 0-999: Bronze
- 1000-1499: Silver
- 1500-1999: Gold
- 2000-2499: Platinum
- 2500+: Diamond

If Player_A was Silver (1499) and is now Gold (1508), they get promoted! The system triggers a celebration notification.

**Step 5: Tournament Service Handles Brackets**
For organized competitions:
- Single/double elimination brackets
- Swiss system tournaments
- Round-robin groups
- Prize pool distribution

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Match Service | Records match results | Tracks all games |
| Anti-Cheat Service | Validates match integrity | Fair competition |
| Rating Calculator | Computes ELO/MMR | Skill-based ranking |
| Tournament Service | Manages brackets | Organized events |
| Redis Sorted Set | Stores current ratings | Fast rank lookups |
| SQL Database | Stores match history | Permanent records |
| Notification Service | Sends rank-up alerts | Player engagement |
| Admin Dashboard | Manual review and bans | Moderation |

### ELO Calculation Example
```
Player A: 1500 rating
Player B: 1450 rating

Expected score for A = 1 / (1 + 10^((1450-1500)/400))
                     = 1 / (1 + 10^(-0.125))
                     = 1 / 1.749
                     = 0.572 (57.2% expected win rate)

If A wins:
New rating A = 1500 + 32 * (1 - 0.572) = 1500 + 13.7 = 1514

If B wins (upset!):
New rating B = 1450 + 32 * (1 - 0.428) = 1450 + 18.3 = 1468
(Bigger gain because B was the underdog)
```

### Anti-Cheat Checks
1. **Statistical Analysis**: Is this player's accuracy humanly possible?
2. **Match Verification**: Did the game server confirm this match?
3. **Win Trading Detection**: Same two players playing repeatedly?
4. **Smurf Detection**: New account with pro-level performance?

### Icons Explained

**Desktop Client** - Player's game client where competitive matches happen.

**API Gateway** - Entry point for match result submissions.

**Matching Engine** - Match Service that records match results and coordinates processing.

**Score Processing** - Rating Calculator that computes new ELO/MMR ratings after matches.

**Tournament Manager** - Handles organized competition brackets and prize distribution.

**Anti-cheat System** - Validates match integrity and flags suspicious activity.

**Redis Cache** - Stores current player ratings for fast matchmaking and ranking queries.

**SQL Database** - Permanent storage for match history, ratings, and tournament data.

**Notification Service** - Sends rank-up celebrations and match result notifications.

**Admin User** - Dashboard for moderators to review flagged matches and issue bans.

### How They Work Together

1. Match ends → Desktop Client submits result via API Gateway
2. Matching Engine records match and sends to Anti-cheat System
3. Anti-cheat validates (no cheating, real match, not win-trading)
4. If valid → Score Processing calculates new ratings using ELO formula
5. Redis Cache updated with new ratings
6. SQL Database stores match history permanently
7. If rank changed (Silver → Gold) → Notification Service celebrates
8. Flagged matches appear on Admin User dashboard for review
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Matching Engine', 'Application Services', 400, 250),
      _createIcon('Score Processing', 'Data Processing', 400, 400),
      _createIcon('Tournament Manager', 'Application Services', 400, 550),
      _createIcon('Anti-cheat System', 'Security,Monitoring', 600, 200),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 350),
      _createIcon('SQL Database', 'Database & Storage', 600, 500),
      _createIcon('Notification Service', 'Message Systems', 800, 350),
      _createIcon('Admin User', 'Client & Interface', 800, 500),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Match Result'),
      _createConnection(1, 2, label: 'Record'),
      _createConnection(2, 5, label: 'Validate'),
      _createConnection(5, 3, label: 'If Valid'),
      _createConnection(2, 3, label: 'Calculate'),
      _createConnection(3, 6, label: 'Update Rank'),
      _createConnection(3, 7, label: 'Store History'),
      _createConnection(4, 7, label: 'Tournament Data'),
      _createConnection(6, 8, label: 'Rank Change'),
      _createConnection(7, 9, label: 'Monitor'),
    ],
  };

  // DESIGN 6: Social Leaderboard
  static Map<String, dynamic> get socialArchitecture => {
    'name': 'Social Leaderboard',
    'description': 'Friends-based and guild leaderboards',
    'explanation': '''
## Social Leaderboard Architecture

### What This System Does
Being #50,000 globally doesn't feel great. But being #3 among your friends? That's motivating! This system shows players how they rank compared to friends and guild members.

### How It Works Step-by-Step

**Step 1: Player Requests Friends Leaderboard**
"Show me how I rank among my friends" - the request includes the player's ID and asks for the friends-only view.

**Step 2: Social Graph Service Fetches Relationships**
The Social Graph is a database of who is friends with whom:
- Player_A's friends: [Player_B, Player_C, Player_D, Player_E]
This is stored in a Graph Database optimized for relationship queries.

**Step 3: Leaderboard Service Gets Friend Scores**
Now we know the friend list, we fetch their scores from Redis:
- Player_B: 5,000 points
- Player_C: 3,500 points
- Player_A (you): 4,200 points
- Player_D: 4,100 points
- Player_E: 2,000 points

**Step 4: Calculate Relative Rankings**
Sort and rank:
1. Player_B: 5,000 ← Your friend is #1
2. Player_A (YOU): 4,200 ← You're #2 among friends!
3. Player_D: 4,100
4. Player_C: 3,500
5. Player_E: 2,000

**Step 5: Guild Service Aggregates Team Scores**
Guilds (clans/teams) compete as groups:
- Sum all member scores
- Average member score
- Top 10 members count
Guild rankings show which team is best overall.

**Step 6: Activity Feed Shows Updates**
Social features need a news feed:
- "Player_B just beat your high score!"
- "Your guild moved to #5 in the region!"
- "Player_C challenged you to beat their score"

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Leaderboard Service | Gets scores for specific players | Core ranking |
| Social Graph Service | Manages friend relationships | Know who's connected |
| Guild Service | Aggregates guild scores | Team competition |
| Graph Database | Stores relationships efficiently | Fast graph queries |
| Redis Sorted Set | Stores individual scores | Fast lookups |
| Activity Feed | Shows social updates | Engagement |
| Notification Service | Alerts for friend activity | Real-time social |

### Friends Leaderboard Query
```
1. Get friends: SMEMBERS friends:player_a
   Result: [player_b, player_c, player_d, player_e]

2. Get scores: ZMSCORE leaderboard player_a player_b player_c player_d player_e
   Result: [4200, 5000, 3500, 4100, 2000]

3. Sort and rank locally

4. Return: "You are #2 of 5 friends"
```

### Guild Competition Example
```
Guild "Dragon Slayers":
- Member 1: 10,000 points
- Member 2: 8,500 points
- Member 3: 7,200 points
- ... (50 members)
- Total: 250,000 points

Guild "Phoenix Rising":
- Total: 245,000 points

"Dragon Slayers" is ranked #1!
```

### Icons Explained

**Desktop Client** - Player's game client requesting friends or guild leaderboards.

**API Gateway** - Routes requests to appropriate services based on query type.

**Ranking Engine** - Core Leaderboard Service that fetches scores for specific players.

**Social Graph Service (Friends)** - Manages friend relationships and returns friend lists.

**Social Graph Service (Guild)** - Aggregates guild member scores for team rankings.

**Redis Cache** - Stores individual player scores for fast lookups.

**Graph Database** - Optimized storage for relationship data (who's friends with whom).

**Feed Generation** - Activity Feed that posts social updates ("Player_B beat your score!").

**Notification Service** - Sends real-time alerts for friend activity and challenges.

### How They Work Together

1. Player requests friends leaderboard → API Gateway → Ranking Engine
2. Ranking Engine asks Social Graph Service for friend list
3. Social Graph Service queries Graph Database for relationships
4. Ranking Engine fetches friend scores from Redis Cache
5. Scores sorted and ranked → "You're #2 among 5 friends!"
6. For guilds → Social Graph Service (Guild) aggregates all member scores
7. Activity updates posted via Feed Generation
8. Real-time alerts via Notification Service
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Ranking Engine', 'Application Services', 400, 250),
      _createIcon('Social Graph Service', 'Application Services', 400, 450),
      _createIcon('Social Graph Service', 'Application Services', 600, 350),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 200),
      _createIcon('Graph Database', 'Database & Storage', 600, 550),
      _createIcon('Feed Generation', 'Message Systems', 800, 350),
      _createIcon('Notification Service', 'Message Systems', 800, 500),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Friends Board'),
      _createConnection(1, 2, label: 'Query'),
      _createConnection(2, 3, label: 'Get Friends'),
      _createConnection(3, 6, label: 'Graph Query'),
      _createConnection(2, 5, label: 'Get Scores'),
      _createConnection(3, 4, label: 'Guild Members'),
      _createConnection(4, 5, label: 'Aggregate'),
      _createConnection(2, 7, label: 'Post Update'),
      _createConnection(7, 8, label: 'Notify'),
    ],
  };

  // DESIGN 7: Multi-Game Leaderboard
  static Map<String, dynamic> get multiGameArchitecture => {
    'name': 'Multi-Game Leaderboard',
    'description': 'Cross-game leaderboard platform for multiple titles',
    'explanation': '''
## Multi-Game Leaderboard Architecture

### What This System Does
This is a platform that provides leaderboards for multiple different games. Think of it like Steam achievements or Xbox Live gamerscore - one system serving thousands of games.

### How It Works Step-by-Step

**Step 1: Game Developer Registers Their Game**
Before using the platform, a game developer registers:
- Game name: "Space Shooter 3000"
- Leaderboard type: High score (higher is better)
- Score format: Integer
- Max players: 1,000,000
- Regions: Global, USA, EU, Asia

**Step 2: Game Registry Stores Configuration**
Each game has its own configuration stored in the registry, including scoring rules, segments, anti-cheat settings, and rate limits.

**Step 3: Players Submit Scores with Game ID**
When a player finishes a game, the request includes the game ID so the system knows which leaderboard to update.

**Step 4: Multi-Tenant Isolation**
Each game's data is completely separate using namespaces. No game can see another game's data.

**Step 5: Score Normalizer (Optional)**
Some platforms have cross-game rankings. The Normalizer converts different scoring systems to a common scale for comparison.

**Step 6: Admin Dashboard for Developers**
Each game developer has access to real-time player counts, score distribution charts, cheater reports, and API usage.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| API Gateway | Routes requests by game_id | Multi-tenant entry |
| Game Registry | Stores game configurations | Per-game settings |
| Leaderboard Service | Core ranking logic | Shared infrastructure |
| Score Normalizer | Cross-game comparisons | Unified rankings |
| Redis Cluster | Namespaced by game | Isolated storage |
| NoSQL Database | Stores all game data | Permanent records |
| Admin Dashboard | Developer portal | Self-service management |

### Multi-Tenancy Benefits
1. **For Developers**: No need to build leaderboard from scratch
2. **For Platform**: Economy of scale, one team maintains everything
3. **For Players**: Consistent experience across games
4. **For Business**: Usage-based pricing model

### Icons Explained

**Desktop Client (Game A, B, C)** - Different games all using the same leaderboard platform.

**API Gateway** - Multi-tenant entry point that routes by game_id to isolate each game's data.

**Configuration Service** - Game Registry storing each game's leaderboard configuration and rules.

**Ranking Engine** - Shared Leaderboard Service that processes scores using game-specific settings.

**Score Processing** - Normalizer that converts different scoring systems for cross-game comparisons.

**Redis Cache** - Namespaced storage where each game's data is completely isolated.

**NoSQL Database** - Permanent multi-tenant storage for all game data.

**Admin User** - Developer Dashboard where game creators manage their leaderboard settings.

### How They Work Together

1. Game A, B, C all send scores to same API Gateway (with game_id)
2. API Gateway routes to Ranking Engine (shared infrastructure)
3. Ranking Engine fetches game config from Configuration Service
4. Score processed according to that game's rules
5. Score Processing can normalize across games if needed
6. Redis Cache stores scores namespaced by game (isolated)
7. NoSQL Database persists all data with game prefixes
8. Each developer sees only their game on Admin User dashboard
''',
    'icons': [
      _createIcon(
        'Desktop Client',
        'Client & Interface',
        50,
        250,
        id: 'Game A',
      ),
      _createIcon(
        'Desktop Client',
        'Client & Interface',
        50,
        400,
        id: 'Game B',
      ),
      _createIcon(
        'Desktop Client',
        'Client & Interface',
        50,
        550,
        id: 'Game C',
      ),
      _createIcon('API Gateway', 'Networking', 250, 400),
      _createIcon('Configuration Service', 'System Utilities', 450, 250),
      _createIcon('Ranking Engine', 'Application Services', 450, 400),
      _createIcon('Score Processing', 'Data Processing', 450, 550),
      _createIcon('Redis Cache', 'Caching,Performance', 700, 300),
      _createIcon('NoSQL Database', 'Database & Storage', 700, 500),
      _createIcon('Admin User', 'Client & Interface', 900, 400),
    ],
    'connections': [
      _createConnection(0, 3, label: 'Game A Score'),
      _createConnection(1, 3, label: 'Game B Score'),
      _createConnection(2, 3, label: 'Game C Score'),
      _createConnection(3, 5, label: 'Route'),
      _createConnection(5, 4, label: 'Get Config'),
      _createConnection(5, 6, label: 'Normalize'),
      _createConnection(6, 7, label: 'Store'),
      _createConnection(5, 8, label: 'Persist'),
      _createConnection(4, 9, label: 'Manage'),
    ],
  };

  // DESIGN 8: Analytics Leaderboard
  static Map<String, dynamic> get analyticsArchitecture => {
    'name': 'Analytics Leaderboard',
    'description': 'Leaderboard with deep analytics and player insights',
    'explanation': '''
## Analytics Leaderboard Architecture

### What This System Does
This goes beyond just showing rankings - it provides deep analytics about player behavior, game balance, and business metrics. Game designers use this to make the game better.

### How It Works Step-by-Step

**Step 1: Event Collector Captures Everything**
Every action is an event:
- "Player_A started game at 14:00:00"
- "Player_A scored 500 points at 14:01:30"
- "Player_A paused game at 14:02:00"
- "Player_A finished game with 5000 points at 14:05:00"

The Event Collector ingests millions of events per second.

**Step 2: Stream Processor Analyzes in Real-Time**
As events flow in, the Stream Processor computes real-time player counts, score per minute rates, and anomaly detection.

**Step 3: Leaderboard Service Updates Rankings**
Score events are forwarded to update the actual leaderboard. This is the same as other designs.

**Step 4: Time Series Database Stores Metrics**
Unlike SQL (stores current state), Time Series databases store how things change over time, enabling historical analysis.

**Step 5: Analytics Engine Runs Complex Queries**
Daily batch jobs analyze score distribution, player churn by rank, and game balance issues.

**Step 6: Dashboard Visualizes Insights**
Product managers and game designers see charts of player progression, heatmaps of where players struggle, and cohort analysis.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Event Collector | Captures all player actions | Raw data ingestion |
| Stream Processor | Real-time event analysis | Immediate insights |
| Leaderboard Service | Updates rankings | Core functionality |
| Time Series DB | Stores metrics over time | Historical tracking |
| Analytics Engine | Complex data analysis | Deep insights |
| Data Warehouse | Long-term storage | Business intelligence |
| Admin Dashboard | Visualizations | Decision making |

### Business Value
1. **Game Balance**: Is the scoring system fair?
2. **Player Retention**: At what rank do players quit?
3. **Monetization**: Do paying players rank higher?
4. **Competitive Health**: Is the meta stale?

### Icons Explained

**Desktop Client** - Player's game generating events for every action taken.

**API Gateway** - Routes score updates and game events to appropriate services.

**Ranking Engine** - Core Leaderboard Service that updates rankings as usual.

**Metrics Collector** - Event Collector ingesting millions of player action events per second.

**Stream Processor** - Real-time analysis computing live metrics and detecting anomalies.

**Redis Cache** - Fast score storage for the leaderboard functionality.

**Time Series Database** - Stores metrics over time for historical trend analysis.

**Analytics Engine** - Runs complex batch queries for deep insights and reporting.

**Data Warehouse** - Long-term storage for all historical data and business intelligence.

**Admin User** - Dashboard showing visualizations, charts, and actionable insights.

### How They Work Together

1. Every game action → Metrics Collector captures event
2. Score events → Ranking Engine → Redis Cache (leaderboard updates)
3. All events → Stream Processor for real-time dashboards
4. Stream Processor → Time Series Database for temporal metrics
5. Analytics Engine runs nightly jobs on Time Series data
6. Results stored in Data Warehouse for long-term analysis
7. Admin User views charts: player distribution, churn analysis, balance issues
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Ranking Engine', 'Application Services', 400, 250),
      _createIcon('Metrics Collector', 'Data Processing', 400, 450),
      _createIcon('Stream Processor', 'Data Processing', 600, 450),
      _createIcon('Redis Cache', 'Caching,Performance', 600, 250),
      _createIcon('Time Series Database', 'Database & Storage', 800, 350),
      _createIcon('Analytics Engine', 'Data Processing', 800, 500),
      _createIcon('Data Warehouse', 'Database & Storage', 1000, 450),
      _createIcon('Admin User', 'Client & Interface', 1000, 300),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Events'),
      _createConnection(1, 2, label: 'Score Update'),
      _createConnection(1, 3, label: 'Game Events'),
      _createConnection(2, 5, label: 'Rank'),
      _createConnection(3, 4, label: 'Process'),
      _createConnection(4, 6, label: 'Metrics'),
      _createConnection(4, 7, label: 'Analyze'),
      _createConnection(7, 8, label: 'Store'),
      _createConnection(8, 9, label: 'Analytics Service'),
      _createConnection(6, 9, label: 'Visualize'),
    ],
  };

  // DESIGN 9: Serverless Leaderboard
  static Map<String, dynamic> get serverlessArchitecture => {
    'name': 'Serverless Leaderboard',
    'description': 'Cloud-native serverless leaderboard with auto-scaling',
    'explanation': '''
## Serverless Leaderboard Architecture

### What This System Does
This leaderboard runs entirely on cloud services with no servers to manage. You pay only for what you use - perfect for games with unpredictable traffic or indie developers.

### How It Works Step-by-Step

**Step 1: Request Hits Managed API Gateway**
AWS API Gateway, Google Cloud Endpoints, or similar. These are fully managed - you just define endpoints, no server configuration needed.

**Step 2: Cloud Function Invoked**
Instead of a running server, your code exists as "functions" that are invoked on-demand:
- Submit Score Function: Triggered by POST /scores
- Get Leaderboard Function: Triggered by GET /leaderboard

These functions start in ~100ms (cold start) or ~10ms (warm).

**Step 3: Functions Access Managed Redis**
Cloud providers offer managed Redis like AWS ElastiCache or Google Memorystore. Same Redis commands, but someone else handles the infrastructure.

**Step 4: Event Stream for Async Processing**
For heavy operations like analytics or notifications, functions publish events to streams like AWS EventBridge or Google Pub/Sub. Other functions subscribe and process asynchronously.

**Step 5: Auto-Scaling Happens Automatically**
No traffic at 3 AM? Zero instances running, zero cost. Tournament with 100K players? Automatically scales to handle load.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| API Gateway (Managed) | HTTP endpoint handling | No server management |
| Submit Function | Processes score submissions | Serverless compute |
| Query Function | Returns leaderboard data | Serverless compute |
| Event Stream | Async event handling | Decoupled processing |
| Process Function | Background tasks | Async operations |
| Managed Redis | Score storage | Serverless database |
| Cloud Database | Persistent storage | Serverless database |
| Auto-scaling | Automatic capacity | No capacity planning |

### When to Use Serverless
**Good for:**
- Indie games with unpredictable traffic
- New games testing the market
- Games with extreme traffic spikes (tournaments)
- Teams without DevOps expertise

**Not ideal for:**
- Consistent high traffic (servers cheaper at scale)
- Ultra-low latency requirements (cold starts)
- Complex stateful operations

### Icons Explained

**Desktop Client** - Player's game client sending requests to the serverless backend.

**API Gateway** - Managed API Gateway (AWS/GCP) that handles HTTP routing with no servers.

**Cloud Service (Submit Func)** - Serverless function triggered on score submissions.

**Cloud Service (Query Func)** - Serverless function triggered when viewing leaderboards.

**Event Stream** - Managed event streaming for async processing between functions.

**Cloud Service (Process Func)** - Background function for analytics and notifications.

**Redis Cache** - Managed Redis service (ElastiCache/Memorystore) for score storage.

**Cloud Database** - Managed NoSQL database for persistent storage.

**Auto-scaling Group** - Automatic scaling that adds capacity during tournaments, scales to zero at night.

### How They Work Together

1. Request hits managed API Gateway → invokes right Cloud Function
2. Submit Func handles score submissions → publishes to Event Stream
3. Query Func handles read requests → queries Redis Cache directly
4. Event Stream triggers Process Func for async work (analytics)
5. Process Func updates Redis Cache and Cloud Database
6. Auto-scaling automatically adjusts capacity based on load
7. Zero traffic at 3 AM = zero running instances = zero cost
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon(
        'Cloud Service',
        'Cloud,Infrastructure',
        400,
        250,
        id: 'Submit Func',
      ),
      _createIcon(
        'Cloud Service',
        'Cloud,Infrastructure',
        400,
        450,
        id: 'Query Func',
      ),
      _createIcon('Event Stream', 'Message Systems', 600, 350),
      _createIcon(
        'Cloud Service',
        'Cloud,Infrastructure',
        600,
        500,
        id: 'Process Func',
      ),
      _createIcon('Redis Cache', 'Caching,Performance', 800, 300),
      _createIcon('Cloud Database', 'Cloud,Infrastructure', 800, 450),
      _createIcon('Auto-scaling Group', 'System Utilities', 400, 600),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Request'),
      _createConnection(1, 2, label: 'Submit'),
      _createConnection(1, 3, label: 'Query'),
      _createConnection(2, 4, label: 'Publish'),
      _createConnection(4, 5, label: 'Trigger'),
      _createConnection(5, 6, label: 'Update'),
      _createConnection(3, 6, label: 'Read'),
      _createConnection(5, 7, label: 'Persist'),
      _createConnection(8, 2, label: 'Scale'),
      _createConnection(8, 3, label: 'Scale'),
    ],
  };

  // DESIGN 10: Complete Leaderboard System
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete Leaderboard System',
    'description': 'Enterprise gaming leaderboard with all features',
    'explanation': '''
## Complete Leaderboard System Architecture

### What This System Does
This is the ultimate enterprise leaderboard combining everything: real-time updates, multiple segments, social features, anti-cheat, analytics, and global scale. Used by major game studios.

### How It Works Step-by-Step

**Step 1: Player Action Enters the System**
Whether submitting a score or viewing rankings, requests enter through the CDN for static content or Load Balancer for dynamic content.

**Step 2: Security Layer**
Before processing:
- Rate Limiter blocks abuse (max 100 requests/minute)
- Authentication verifies player identity
- Anti-cheat flags suspicious requests

**Step 3: API Gateway Routes to Services**
Based on the request type:
- Score submission → Leaderboard Service
- Friends ranking → Social Service
- View rankings → Leaderboard Service (read path)

**Step 4: Real-Time Path (WebSocket)**
Players watching leaderboards connect via WebSocket Gateway. They receive instant updates through the Pub/Sub system.

**Step 5: Leaderboard Service Processes Scores**
The core service validates the score, updates Redis Sorted Set, publishes change event, and persists to database.

**Step 6: Social Service Enriches Data**
For social views: gets friend list from graph database, filters leaderboard to friends only, adds social context.

**Step 7: Analytics Pipeline**
All events flow to Stream Processor (real-time metrics), Analytics Engine (batch analysis), and Dashboard (visualizations).

### Full Component List

| Component | Purpose |
|-----------|---------|
| CDN | Cache static content globally |
| Load Balancer | Distribute traffic across servers |
| Rate Limiter | Prevent abuse and DDoS |
| API Gateway | Route and validate requests |
| WebSocket Gateway | Real-time connections |
| Leaderboard Service | Core ranking logic |
| Social Service | Friends and guild features |
| Anti-Cheat Service | Fraud detection |
| Redis Cluster | Fast score storage |
| Pub/Sub System | Real-time notifications |
| NoSQL Database | Persistent data store |
| Stream Processor | Real-time analytics |
| Analytics Engine | Business intelligence |
| Admin Dashboard | Operations and insights |

### System Guarantees
- **Latency**: <10ms for reads, <50ms for writes
- **Throughput**: 100,000+ updates per second
- **Scale**: 100+ million players
- **Availability**: 99.99% uptime
- **Consistency**: Eventual consistency (scores update within seconds)

### Icons Explained

**Desktop Client** - PC/console game clients for score submissions and viewing.

**Mobile Client** - Phone/tablet game clients with full leaderboard access.

**WebSocket Server** - Real-time gateway for live leaderboard updates.

**CDN** - Edge caching for static assets and frequently accessed data.

**Global Load Balancer** - Distributes traffic across regions for reliability.

**Rate Limiter** - Prevents abuse with per-user request limits.

**API Gateway** - Central routing and validation for all requests.

**Ranking Engine** - Core Leaderboard Service processing scores and queries.

**Social Graph Service** - Friends and guild features for social leaderboards.

**Anti-cheat System** - Fraud detection and match validation.

**Redis Cache** - Ultra-fast score storage using Sorted Sets.

**Message Queue** - Pub/Sub for real-time notifications and decoupling.

**NoSQL Database** - Permanent storage for all data.

**Stream Processor** - Real-time analytics and metrics processing.

**Analytics Engine** - Deep analysis for business intelligence.

**Admin User** - Operations dashboard for monitoring and insights.

### How They Work Together

1. Requests enter via CDN/Load Balancer → Rate Limiter checks abuse
2. API Gateway routes: scores → Ranking Engine, social → Social Graph
3. Anti-cheat validates before Ranking Engine processes
4. Redis Cache stores scores, publishes changes via Message Queue
5. WebSocket Server pushes live updates to watching clients
6. NoSQL Database persists everything permanently
7. Stream/Analytics Engines process data for Admin User dashboards
8. Result: Complete enterprise leaderboard at massive scale
''',
    'icons': [
      _createIcon('Desktop Client', 'Client & Interface', 50, 200),
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      _createIcon('WebSocket Server', 'Networking', 50, 500),
      _createIcon('CDN', 'Networking', 200, 275),
      _createIcon('Global Load Balancer', 'Networking', 350, 275),
      _createIcon('Rate Limiter', 'Networking', 350, 425),
      _createIcon('API Gateway', 'Networking', 500, 350),
      _createIcon('Ranking Engine', 'Application Services', 700, 250),
      _createIcon('Social Graph Service', 'Application Services', 700, 400),
      _createIcon('Anti-cheat System', 'Security,Monitoring', 700, 550),
      _createIcon('Redis Cache', 'Caching,Performance', 900, 200),
      _createIcon('Message Queue', 'Message Systems', 900, 350),
      _createIcon('NoSQL Database', 'Database & Storage', 900, 500),
      _createIcon('Stream Processor', 'Data Processing', 1100, 350),
      _createIcon('Analytics Engine', 'Data Processing', 1100, 500),
      _createIcon('Admin User', 'Client & Interface', 1300, 425),
    ],
    'connections': [
      _createConnection(0, 3, label: 'Score'),
      _createConnection(1, 3, label: 'Score'),
      _createConnection(3, 4, label: 'Route'),
      _createConnection(4, 5, label: 'Rate Check'),
      _createConnection(4, 6, label: 'Forward'),
      _createConnection(6, 7, label: 'Update'),
      _createConnection(6, 8, label: 'Social'),
      _createConnection(7, 9, label: 'Validate'),
      _createConnection(7, 10, label: 'ZADD'),
      _createConnection(10, 11, label: 'Publish'),
      _createConnection(11, 2, label: 'Push'),
      _createConnection(7, 12, label: 'Persist'),
      _createConnection(12, 13, label: 'Process'),
      _createConnection(13, 14, label: 'Analyze'),
      _createConnection(14, 15, label: 'Analytics Service'),
    ],
  };

  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      scalableArchitecture,
      realtimeArchitecture,
      segmentedArchitecture,
      competitiveArchitecture,
      socialArchitecture,
      multiGameArchitecture,
      analyticsArchitecture,
      serverlessArchitecture,
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
          'color': conn['color'] ?? 0xFF00BCD4,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
        });
      }
    }
    return lines;
  }
}
