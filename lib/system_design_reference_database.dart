// Comprehensive System Design Reference Database
// Built from quiz app's knowledge bank and system design icons
// Organized by categories for easy mapping and evaluation

class SystemDesignReferenceDatabase {
  // =================================================================
  // TIER 1: FOUNDATIONAL SYSTEMS (Learning Core Concepts)
  // =================================================================

  static const String urlShortenerNotes = '''
URL Shortener System Design (e.g., TinyURL, bit.ly)

SYSTEM OVERVIEW:
A URL shortener service converts long URLs into short, memorable links with extremely high read traffic for redirects and moderate write traffic for URL creation. The system prioritizes low latency redirects and global availability.

END-TO-END USER FLOW:
Create flow: User pastes a long URL into the web/app interface → Request hits the Load Balancer → API Gateway validates and rate-limits the request → Application Server calls the URL Shortening Service → a unique short code is generated (Base62) and the mapping is written to the Key-Value Store (Redis/DB) → the server responds with the complete shortened URL (e.g., https://tinyurl.com/abc123) which is returned directly to the user to copy and share.
Redirect flow: User (or someone they shared the link with) clicks the short URL → DNS resolves to the CDN or Load Balancer → CDN checks its cache first; on a cache hit the redirect is served instantly without touching origin servers → on a cache miss the request reaches the Application Server → URL Redirect Service looks up the short code in Redis → finds the original long URL → returns an HTTP 301/302 redirect response → the user's browser automatically follows the redirect and lands on the original destination.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Web Browser: Primary interface for users to submit and manage URLs
- Mobile Client: Native apps for quick link sharing and management  
- Desktop Client: Browser extensions and desktop applications
- API Clients: Third-party integrations and developer access

Network & Communication Layer:
- Load Balancer: Distributes incoming requests across multiple servers
- API Gateway: Single entry point for rate limiting, authentication, and API versioning
- CDN: Caches popular shortened URLs globally for ultra-fast redirects
- DNS Server: Routes traffic to geographically closest servers

Application Layer:
- Web Server: Handles HTTP requests and 301/302 redirect responses
- Application Server: Core business logic for URL encoding, decoding, and validation
- URL Shortening Service: Generates short codes and stores mappings
- URL Redirect Service: Handles high-volume redirect requests
- Analytics Service: Tracks click patterns and user behavior

Storage & Database Layer:
- Key-Value Store: Primary storage for URL mappings (Redis/DynamoDB)
- SQL Database: User accounts, analytics, and metadata storage
- Time Series Database: Click analytics and performance metrics
- Object Storage: Backup and archival of URL mappings

CACHING STRATEGY:
- In-Memory Cache: Most frequently accessed URLs in application memory
- Redis Cache: Distributed caching layer for URL mappings
- CDN Cache: Geographic caching of popular redirects
- Browser Cache: Client-side caching for recently accessed URLs

ARCHITECTURAL PATTERNS:
- REST API: Stateless request-response model for URL creation and retrieval
- Caching: Multi-level caching strategy for high performance redirects
- Sharding: Database sharding based on URL hash for horizontal scaling
- Replication: Master-slave replication for read scalability

SECURITY & MONITORING:
- Rate Limiter: Prevents abuse and spam URL creation
- Security Scanner: Malicious URL detection and blocking
- Monitoring System: Track redirect performance and system health
- Analytics Engine: User behavior analysis, click tracking, and redirect analytics
- Alert System: Notifications for system issues and security threats

REAL-WORLD NUMBERS & SCALE:
- ~890 redirects/sec average (about 77 million redirects per day)
- 100:1 read-write ratio (for every URL created, it gets clicked ~100 times)
- 500 bytes/record (each URL mapping is tiny — just the short code + destination URL + metadata)
- 1B URLs = 500GB total storage (one billion links fits on a single large hard drive)
- Base62 7-char codes = 3.5T unique URLs (3.5 trillion possible combinations — enough for decades)
- Redis handles 100K ops/sec (one server can serve 100,000 cache lookups per second)
- PostgreSQL caps at ~500 connections (each connection uses 5-10MB RAM — about 2.5-5GB total for max connections)
- CDN serves 80% of redirects (most popular links never even hit the origin servers)

TRADE-OFFS & ENGINEERING DECISIONS:
- 301 (permanent) vs 302 (temporary) redirects: 301 is faster for users but loses analytics tracking since browsers cache it
- Sequential vs random short codes: sequential is simpler but leaks creation rate; random is harder to guess but risks collisions
- Redis vs database for lookups: Redis is 100x faster but costs more RAM; database is cheaper but adds ~5ms latency per redirect
- Single global database vs sharded: simpler to manage one database but it becomes the bottleneck past ~50K writes/sec
- Custom aliases vs auto-generated: users love custom URLs but they create hotspots in the database and cache

FAILURE MODES & WHAT BREAKS:
- Redis cache goes down: all redirects hit the database directly, latency spikes from <1ms to ~5-10ms, database may get overwhelmed
- Hash collision: two different long URLs generate the same short code — need collision detection and retry logic
- Database write bottleneck: at high creation rates, the single-master database becomes the chokepoint
- CDN cache stampede: when a viral link's CDN cache expires, thousands of requests simultaneously hit origin servers
- DNS propagation delays: changing DNS routing during failover can leave users unable to reach the service for minutes

KEY CHARACTERISTICS:
- High read traffic (90%+ redirects vs URL creation)
- Low latency requirements for global redirects with automatic expiration
- Horizontal scaling for massive request volumes
- URL encoding algorithms (Base62, custom schemes)
- Click tracking and analytics capabilities
- Global availability and geographic distribution
''';

  static const String pastebinServiceNotes = '''
Pastebin Service System Design (e.g., Pastebin.com, GitHub Gist)

SYSTEM OVERVIEW:
A Pastebin service is a write-heavy system that allows users to store and share text content (code snippets, logs, notes) with automatic expiration and high write throughput. The system focuses on temporary storage, content lifecycle management, and fast content retrieval via custom URLs.

END-TO-END USER FLOW:
Create flow: User types or pastes content into the editor, selects expiry time and visibility (public/private), then clicks "Submit" → Request reaches the Load Balancer → Application Server validates content size and calls the Content Storage Service → a unique paste ID/URL slug is generated and the content is written to the NoSQL DB (and optionally backed to Object Storage) → the server returns the shareable paste URL (e.g., https://pastebin.com/xK9mP2) directly to the user, which they can copy and share.
Retrieve flow: User (or recipient) visits the paste URL → Web Server looks up the paste ID in Redis cache first; on a hit the content is returned immediately → on a cache miss the Content Retrieval Service fetches from the DB, applies syntax highlighting if needed, then serves the content to the user's browser → if the paste has expired, the server returns a 404 and the Expiration Service may clean up the record.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Web Browser: Primary interface for users to paste and view content
- Mobile Client: Apps for quick content sharing on mobile devices
- Desktop Client: Integrated tools for developers and system administrators
- API Clients: Programmatic access for automation and third-party integrations

Network & Communication Layer:
- Load Balancer: Distributes high write traffic across multiple application servers
- API Gateway: Handles rate limiting, authentication, and API versioning for paste operations
- CDN: Caches popular public pastes globally for faster content delivery
- DNS Server: Routes requests to appropriate geographic regions

Application Layer:
- Web Server: Handles HTTP requests for paste creation and retrieval
- Application Server: Core business logic for content processing and validation
- Content Storage Service: Handles paste creation and validation
- Content Retrieval Service: Serves paste content with security checks
- Expiration Service: Manages automatic content deletion
- User Management Service: Handles accounts and paste ownership

Storage & Database Layer:
- SQL Database: Stores paste metadata, user accounts, and expiration schedules
- NoSQL Database: High-performance storage for paste content (MongoDB/Cassandra)
- Key-Value Store: Redis for fast paste lookups and session storage
- Object Storage: Amazon S3 for backup and archival of expired content
- File System: Local storage for temporary paste processing

CACHING STRATEGY:
- In-Memory Cache: Frequently accessed pastes stored in application memory
- Redis Cache: Distributed caching layer for paste content and metadata
- CDN Cache: Geographic caching for public pastes with long expiration
- Browser Cache: Client-side caching for recently viewed content

ARCHITECTURAL PATTERNS:
- REST API: Request-response model for paste creation and retrieval
- Caching: Multi-layer caching for frequently accessed paste content
- Sharding: Database sharding by paste ID for horizontal scaling
- Replication: Master-slave replication for high availability

DATA PROCESSING & ANALYTICS:
- Stream Processor: Real-time analytics on paste creation patterns and usage
- Analytics Engine: Generate insights on popular content types and user behavior
- ETL Pipeline: Process paste data for reporting and content moderation
- Batch Processor: Handle bulk operations like expired content cleanup

SECURITY & MONITORING:
- Authentication: User login and API key management for private pastes
- Authorization: Role-based access control for paste visibility and editing
- Security Gateway: Content scanning for malicious code and spam detection
- Firewall: Protection against DDoS attacks and malicious requests
- Monitoring System: Track system health, write throughput, and storage utilization
- Logging Service: Centralized logging for security audits and debugging
- Alert System: Notifications for system issues and security threats

MESSAGE SYSTEMS & BACKGROUND PROCESSING:
- Message Queue: Handle asynchronous tasks like content expiration and cleanup
- Event Stream: Track paste lifecycle events for analytics and auditing
- Notification Service: Email alerts for paste expiration warnings
- Scheduler: Automated cleanup of expired content and maintenance tasks

CONTENT MANAGEMENT FEATURES:
- Custom URL Generation: Create human-readable or random paste URLs
- Automatic Content Expiration: Time-based deletion (1 hour, 1 day, 1 week, never)
- Syntax Highlighting: Code formatting and language detection
- Content Versioning: Track paste edits and revision history
- Privacy Controls: Public, unlisted, and private paste visibility options

REAL-WORLD NUMBERS & SCALE:
- ~1,200 writes/sec at peak (about 100 million new pastes per day during busy hours)
- 10KB average paste size (roughly a 300-line code snippet or a page of text)
- 512KB max paste size (enough for a very large log file or code dump)
- 10M pastes = 100GB storage (ten million pastes fill up about one small hard drive)
- 60% of pastes expire within their set time (most content is temporary — burn-after-reading or 24hr links)
- Expired content cleanup saves ~3GB/day (automatic deletion keeps storage costs manageable)
- Redis handles 100K ops/sec for lookups (fast cache for recently created or popular pastes)
- Syntax highlighting adds ~50ms processing time (parsing and colorizing code takes extra compute per view)
- S3 archive storage costs \$0.023/GB/month (about \$2.30/month per 100GB of archived pastes)

TRADE-OFFS & ENGINEERING DECISIONS:
- Store content in database vs object storage: database is simpler but expensive for large pastes; S3 is cheaper but adds retrieval latency
- Eager vs lazy expiration: running cleanup continuously uses CPU but frees storage faster; lazy deletion saves CPU but wastes storage
- Server-side vs client-side syntax highlighting: server is consistent across browsers but adds 50ms; client-side saves server CPU but varies by browser
- Random vs sequential paste IDs: random is harder to guess (better privacy) but harder to shard; sequential leaks creation rate
- Compression before storage: saves 60-80% space for text but adds CPU overhead on every read and write

FAILURE MODES & WHAT BREAKS:
- Expiration service falls behind: storage fills up as expired pastes aren't cleaned, costs spike unexpectedly
- Hot paste goes viral: a single popular paste overwhelms the cache and database — need rate limiting per paste
- Storage quota exceeded: if monitoring misses growth trends, the system runs out of disk and starts rejecting writes
- Syntax highlighting timeout: very large pastes with complex syntax cause the highlighter to hang, blocking the response
- CDN serves stale content: expired or deleted pastes keep appearing because CDN cache hasn't been invalidated

KEY CHARACTERISTICS:
- Write-heavy system with high throughput paste creation
- Temporary storage with automatic expiration policies
- Content lifecycle management and auto cleanup
- Custom URL generation for easy sharing
- High write throughput and content storage optimization
- Metadata tracking and content organization
''';

  static const String webCrawlerNotes = '''
Web Crawler System Design (e.g., Googlebot, Web Scraping)

SYSTEM OVERVIEW:
A web crawler is a distributed system that systematically browses and indexes web content. It discovers URLs, extracts content, respects robots.txt policies, and builds comprehensive link graphs while handling massive scale distributed crawling operations.

END-TO-END USER FLOW:
Crawl flow: The Scheduler seeds the Crawl Queue with starting URLs → Crawler Agents dequeue a URL, check the Bloom filter (already visited?) and robots.txt (allowed?) → agent fetches the raw HTML page via HTTP → Content Extractor parses the page, strips boilerplate, and extracts clean text → URL Discovery Service finds all outbound links and adds unseen ones back to the Crawl Queue → extracted content is stored in the NoSQL/Object Storage and handed to the Indexing Service → Indexing Service tokenizes, ranks, and writes to the Search Engine index (e.g., Elasticsearch) → when a real user searches for something, the Search Engine queries the index and returns ranked results, giving the user the relevant pages the crawler discovered.
Recrawl flow: Scheduler periodically re-enqueues known URLs based on change frequency → fresh content replaces stale index entries so users always get up-to-date search results.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Crawler Agents: Distributed crawling bots that fetch web pages
- Admin Dashboard: Monitor crawling progress and manage crawl policies
- API Interface: External access for crawl data and status
- Configuration Portal: Set crawling rules and scheduling parameters

Network & Communication Layer:
- Load Balancer: Distributes crawling requests across multiple crawler nodes
- Proxy Servers: Rotate IP addresses to avoid rate limiting and blocking
- DNS Resolver: Efficient domain name resolution for discovered URLs
- Content Delivery: Transfer crawled content to processing systems

Application Layer:
- Crawl Coordinator: Manages distributed crawling tasks and scheduling
- URL Discovery Service: Finds new URLs from crawled pages and sitemaps
- Content Extractor: Parses HTML, extracts text, and identifies links
- Duplicate Detection: Identifies and eliminates duplicate content and URLs
- Robots.txt Parser: Respects website crawling policies and restrictions
- Content Processor: Analyzes and categorizes extracted content

Storage & Database Layer:
- NoSQL Database: Stores crawled content and extracted data (MongoDB/Cassandra)
- Graph Database: Maintains link graph and website relationships (Neo4j)
- Object Storage: Raw page content and binary file storage
- Time Series Database: Crawl metrics, performance data, and analytics

QUEUE & PROCESSING SYSTEMS:
- Message Queue: Manages crawl tasks and coordinates distributed workers
- Crawl Queue: Prioritized queue of URLs to be crawled (Redis/RabbitMQ)
- Stream Processor: Real-time processing of crawled content
- ETL Pipeline: Extract, transform, and load crawled data for analysis

SEARCH & INDEXING:
- Search Engine: Full-text search capabilities for crawled content (Elasticsearch)
- Indexing Service: Creates searchable indexes from extracted content
- Content Classification: Categorizes and tags crawled content
- Link Analysis: Analyzes link structure and page authority

SCHEDULING & COORDINATION:
- Scheduler: Manages crawl frequency and timing based on website policies
- Rate Limiter: Respects website rate limits and crawl delays
- Priority Manager: Prioritizes important pages and fresh content
- Crawl Politeness: Implements delays and respectful crawling practices

ARCHITECTURAL PATTERNS:
- Event-Driven: Queue-based distributed crawling with asynchronous processing
- Pub/Sub: Message queuing for coordinating crawler nodes
- Caching: URL deduplication and content caching for efficiency
- Sharding: Distributed crawling across sharded URL spaces

SECURITY & MONITORING:
- Security Gateway: Protects against malicious websites and content
- Monitoring System: Tracks crawl health, success rates, and performance
- Analytics Engine: Provides insights on crawl patterns and website changes
- Alert System: Notifications for crawl failures and system issues

REAL-WORLD NUMBERS & SCALE:
- Google crawls 20B pages/day = 230K pages/sec (that's like reading every book in every library, every single day)
- 50KB average HTML per page = 11.5GB/sec raw data ingested (a firehose of text pouring in continuously)
- robots.txt cached for 24hrs (re-fetching a site's rules once a day to be polite without overwhelming them)
- 1-10sec politeness delay between requests to same host (waiting between knocks so you don't crash someone's server)
- Bloom filter for 10B URLs needs only 1.2GB RAM (a space-efficient way to check "have I seen this URL before?" with ~1% false positive rate)
- 100 links per page = 23M new URLs/sec discovered (every page you crawl gives you 100 more pages to visit — exponential growth)
- 5-10% crawl failure rate (network timeouts, server errors, and blocked requests are normal at scale)

TRADE-OFFS & ENGINEERING DECISIONS:
- Breadth-first vs depth-first crawling: BFS discovers more sites quickly but uses more memory for the queue; DFS maps individual sites deeply but can get stuck
- Bloom filter vs hash set for deduplication: Bloom filter uses 10x less memory but has false positives (skip pages that haven't been crawled); hash set is exact but requires ~10x more RAM
- Politeness delay vs crawl speed: longer delays mean happier website owners but slower crawling; shorter delays risk getting IP-banned
- Recrawl frequency: crawling pages too often wastes bandwidth; too rarely means stale data — need priority-based scheduling
- Store raw HTML vs extracted text: raw HTML preserves everything but costs 5-10x more storage; extracted text is smaller but loses page structure

FAILURE MODES & WHAT BREAKS:
- Spider trap: dynamically generated pages create infinite URL loops (e.g., calendar pages that go on forever) — need URL depth limits
- DNS resolution bottleneck: at 230K pages/sec, DNS lookups can become the bottleneck — need aggressive DNS caching
- Bloom filter false positives: important pages get skipped because the filter incorrectly says "already crawled"
- Crawler gets IP-banned: too-aggressive crawling causes websites to block your IP ranges — need proxy rotation
- Data pipeline backup: if processing can't keep up with crawl rate, queues grow unbounded and the system runs out of memory

KEY CHARACTERISTICS:
- Distributed crawling across multiple nodes and geographic regions
- Respects robots.txt policies and website crawling guidelines with politeness delays
- URL discovery from multiple sources (links, sitemaps, feeds) and indexing
- Content extraction and text processing capabilities
- Duplicate detection and deduplication algorithms
- Link graph construction and website relationship mapping
- Scalable queue management for millions of URLs
- Crawl politeness and rate limiting compliance
''';

  // =================================================================
  // TIER 2: WEB-SCALE GIANTS (Million+ Users, Complex Features)
  // =================================================================

  static const String socialMediaNewsFeedNotes = '''
Social Media News Feed System Design (e.g., Facebook, X/Twitter)

SYSTEM OVERVIEW:
A social media news feed system handles millions of users generating and consuming user-generated content in real-time. It balances personalized content delivery with massive scale through sophisticated algorithmic ranking, caching strategies, and real-time updates.

END-TO-END USER FLOW:
Post flow: User writes a post and hits "Share" → Content Publishing Service stores the post in the NoSQL DB → Fan-out Service reads the user's follower list from the Social Graph Service → for users with ≤5K followers the post is pushed (written) into each follower's pre-computed feed in Redis (fan-out-on-write) → for celebrities with millions of followers the post is only stored once and pulled at read time → followers who are online receive a real-time update via WebSocket; offline followers see it the next time they open the app.
Read (feed load) flow: User opens the app → Feed Generation Service retrieves the user's pre-computed feed from the Redis Feed Cache → ML Ranking evaluates ~500 candidate posts in ~50ms and reorders them by predicted relevance → the ranked feed (posts, images, metadata) is returned to the client → the user sees their personalized feed immediately, images loaded via CDN → as they scroll, older posts are fetched from the DB on demand.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Mobile Apps: Native iOS and Android applications for optimal performance
- Web Application: Responsive web interface for browser-based access
- Desktop Client: Native desktop applications for power users
- API Gateway: External developer access and third-party integrations

Network & Communication Layer:
- Global Load Balancer: Distributes traffic across multiple data centers
- CDN: Caches static content (images, videos) globally for fast delivery
- API Gateway: Rate limiting, authentication, and API versioning
- WebSocket Servers: Real-time notifications and live updates

Application Layer:
- Feed Generation Service: Creates personalized feeds using algorithmic ranking
- Content Publishing Service: Handles post creation, editing, and publishing
- Social Graph Service: Manages user relationships and connections
- Recommendation Engine: Suggests content, people, and trending topics
- Content Moderation Service: Automated and manual content review
- Notification Service: Real-time alerts and push notifications

Storage & Database Layer:
- Graph Database: Social connections and relationship mapping (Neo4j)
- NoSQL Database: User posts, comments, and activity data (Cassandra)
- Object Storage: Media files (images, videos) with CDN integration
- SQL Database: User profiles, authentication, and structured data
- Time Series Database: Analytics, metrics, and user behavior tracking

CACHING & PERFORMANCE:
- Redis Cache: Hot data like trending posts and active user sessions
- In-Memory Cache: Frequently accessed user feeds and social graphs
- CDN Cache: Media content cached globally for fast delivery
- Feed Cache: Pre-computed feeds for active users

REAL-TIME PROCESSING:
- Stream Processor: Real-time engagement tracking and trend detection
- Event Stream: User activity events for analytics and recommendations
- Live Updates: WebSocket connections for instant feed updates
- Push Notifications: Real-time alerts for interactions and messages

CONTENT & RECOMMENDATIONS:
- ML Model: Machine learning for personalized content ranking
- Analytics Engine: User engagement analysis and content performance
- Search Engine: Full-text search for posts, users, and hashtags
- Trending Algorithm: Identifies viral content and emerging topics

ARCHITECTURAL PATTERNS:
- Microservices: Distributed services for feed, posts, recommendations, and notifications
- Event-Driven: Real-time event processing for timeline updates and notifications
- Pub/Sub: Message queue for distributing posts to followers' feeds
- Caching: Multi-layer caching for personalized feeds and hot content
- Sharding: Database sharding by user ID for horizontal scaling
- Replication: Database replication for read-heavy workloads

SECURITY & MODERATION:
- Content Moderation: AI-powered detection of inappropriate content
- Security Gateway: Protection against spam, bots, and malicious content
- Privacy Controls: User privacy settings and content visibility management
- Monitoring System: System health, performance metrics, and abuse detection

REAL-WORLD NUMBERS & SCALE:
- 2B DAU (two billion people opening the app daily — roughly 1 in 4 humans on Earth)
- 115K posts/sec (every second, 115,000 new posts, photos, and videos are created worldwide)
- Fan-out-on-write math: 1 post × 1,000 followers = 1,000 feed writes (every post triggers writes to all followers' feeds)
- Hybrid approach: push for users with ≤5K followers / pull for celebrities (a celebrity with 50M followers can't trigger 50M writes per post)
- ML ranking evaluates 500 candidates in 50ms (the algorithm scores 500 potential posts and picks the best ones in the blink of an eye)
- 200TB pre-computed feeds cost ~\$2M/month in RAM (storing everyone's personalized feed in memory isn't cheap)
- Memcached handles 5B requests/sec across the fleet (five billion cache lookups per second across all servers combined)
- 400B social graph edges (400 billion friend/follow connections — the world's largest relationship map)

TRADE-OFFS & ENGINEERING DECISIONS:
- Fan-out-on-write vs fan-out-on-read: write-time fan-out is fast for readers but expensive for popular users; read-time fan-out saves writes but makes feed loading slower
- Chronological vs algorithmic feed: chronological is fair and simple but users miss important posts; algorithmic boosts engagement but creates filter bubbles
- Pre-compute all feeds vs compute on demand: pre-computing uses massive RAM but gives instant loads; on-demand saves memory but adds 100-200ms latency
- Push vs pull for celebrities: pushing to 50M followers per post is wasteful; pulling at read time saves writes but adds latency for followers of celebrities
- Strong vs eventual consistency: users expect to see their own posts instantly but can tolerate 1-2sec delay seeing others' posts

FAILURE MODES & WHAT BREAKS:
- Celebrity post storm: a celebrity posts during a major event, triggering fan-out to millions of followers simultaneously — can spike write load 1000x
- Cache stampede: when Memcached restarts, billions of requests hit the database at once — need cache warming strategies
- Social graph hotspot: users with 50M+ followers create hot partitions in the graph database
- ML ranking service timeout: if the ranking model takes >50ms, the feed falls back to chronological — users notice lower quality content
- Feed inconsistency: during network partitions between data centers, users in different regions see different versions of the feed

KEY CHARACTERISTICS:
- Social graph management with complex relationship mapping
- News feed generation with timeline and algorithmic ranking and personalization
- User-generated content at massive scale with real-time delivery and posts
- Recommendation systems for content discovery, engagement, and likes tracking
- Fan-out strategies (push vs pull) for content distribution
- Real-time updates and notifications for user interactions
- Content moderation and spam detection capabilities
- Massive scale with millions of concurrent users
''';

  static const String videoStreamingServiceNotes = '''
Video Streaming Service System Design (e.g., Netflix, YouTube)

SYSTEM OVERVIEW:
A video streaming platform delivers high-quality video content to millions of users globally with adaptive bitrate streaming, massive content libraries, and personalized recommendations. The system handles video upload, transcoding, storage, and delivery through global CDN networks.

END-TO-END USER FLOW:
Upload flow (creator): Creator uploads a video file → Video Upload Service receives the large file in resumable chunks → raw file stored in Object Storage → a Transcoding job is queued → Transcoding Pipeline converts the video into ~1,200 versions (multiple resolutions 4K/1080p/720p, bitrates, codecs, and audio tracks) → thumbnails are generated → all versions pushed to CDN edge servers globally → video is marked available in the catalog DB and appears on the platform for users to discover.
Watch flow (viewer): User browses recommendations (served by the ML Recommendation Engine) → clicks a title → Video Streaming Service looks up available stream URLs → client requests the nearest CDN edge server → CDN serves the video as short HLS/DASH chunks (2-6 seconds each) → Adaptive Bitrate algorithm monitors network speed and automatically switches quality mid-stream so the video plays smoothly → the user watches uninterrupted, never seeing the full file download; they only receive the chunks they're watching right now.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Smart TV Apps: Native applications for television platforms
- Mobile Apps: iOS and Android apps with offline download capabilities
- Web Player: Browser-based video player with adaptive streaming
- Gaming Console Apps: Xbox, PlayStation, and other gaming platform apps

Network & Content Delivery:
- Global CDN: Massive content delivery network for video streaming
- Edge Servers: Geographically distributed servers for low-latency delivery
- Adaptive Bitrate: Dynamic quality adjustment based on network conditions
- Content Delivery Optimization: Intelligent routing and caching strategies

Application Layer:
- Video Streaming Service: Core streaming logic and session management
- Recommendation Engine: AI-powered content suggestions and discovery
- User Management Service: Profiles, preferences, and viewing history
- Content Management: Video catalog, metadata, and content organization
- Search Service: Advanced search with filters and content discovery
- Payment Processing: Subscription management and billing

VIDEO PROCESSING PIPELINE:
- Video Upload Service: Handles large file uploads with resumable transfers
- Video Transcoding: Converts videos to multiple formats and bitrates
- Quality Processing: Generates multiple resolution versions (4K, 1080p, 720p, 480p)
- Thumbnail Generation: Creates preview images and video thumbnails
- Content Analysis: Automated content classification and tagging

Storage & Database Layer:
- Object Storage: Massive video file storage distributed globally
- CDN Storage: Video content cached at edge locations worldwide
- NoSQL Database: User profiles, viewing history, and preferences
- SQL Database: Content metadata, billing, and business data
- Time Series Database: Streaming analytics and performance metrics

STREAMING TECHNOLOGY:
- Adaptive Bitrate Streaming: HLS, DASH protocols for quality adaptation
- Video Encoding: H.264, H.265 compression for optimal file sizes
- Stream Processing: Real-time analytics on viewing patterns
- Content Delivery: Intelligent caching and pre-positioning of popular content

ANALYTICS & RECOMMENDATIONS:
- ML Model: Machine learning for personalized content recommendations
- Analytics Engine: Detailed viewing analytics and user behavior tracking
- A/B Testing Platform: Content recommendation and interface optimization
- Business Intelligence: Content performance and revenue analytics

SECURITY & CONTENT PROTECTION:
- DRM (Digital Rights Management): Content protection and licensing
- Geo-blocking: Regional content restrictions and licensing compliance
- Authentication: Secure user login and session management
- Monitoring System: Performance monitoring and system health tracking

ARCHITECTURAL PATTERNS:
- Microservices: Distributed services for streaming, transcoding, recommendations, and user management
- REST API: Request-response for content management and user interactions
- Event-Driven: Asynchronous video processing and notification delivery
- Caching: Multi-layer caching with CDN for content delivery optimization
- Sharding: Database sharding by content ID for horizontal scaling
- Replication: Content replication across global regions for availability

SCALABILITY FEATURES:
- Auto-scaling: Dynamic resource allocation based on demand
- Global Distribution: Multi-region deployment for worldwide coverage
- Load Balancing: Intelligent traffic distribution across servers
- Caching Strategy: Multi-layer caching for popular and trending content

REAL-WORLD NUMBERS & SCALE:
- Netflix serves 100M concurrent streams at peak (one hundred million people watching at the same time)
- Consumes 15% of global downstream internet bandwidth (nearly 1 in 6 bytes flowing across the internet is Netflix)
- 1,200 versions per movie (every title encoded in different resolutions, bitrates, codecs, and audio tracks)
- 36PB total storage (36 petabytes — equivalent to about 36,000 one-terabyte hard drives)
- HLS chunks are 2-6 seconds each (video split into tiny segments so quality can adapt mid-stream)
- Transcoding 1hr video = 4-8hrs of compute time (encoding a movie takes 4-8x longer than watching it)
- 18K CDN servers serve 95% of traffic from within ISPs (Netflix boxes sit inside your internet provider's building)
- Recommendation engine generates 80% of watches (most people watch what the algorithm suggests, not what they search for)
- H.265 is 50% more efficient than H.264 (same quality video in half the file size, saving bandwidth and storage)

TRADE-OFFS & ENGINEERING DECISIONS:
- H.264 vs H.265 encoding: H.265 saves 50% bandwidth but takes 5-10x longer to encode and some older devices can't play it
- Eager vs lazy transcoding: encoding all 1,200 versions upfront costs compute but ensures instant availability; on-demand transcoding saves compute but adds startup delay for rare formats
- CDN push vs pull: pre-positioning popular content at edge is fast but wastes bandwidth for unpopular titles; pulling on first request saves bandwidth but first viewer waits longer
- Longer vs shorter HLS chunks: longer chunks (6s) are more efficient but increase startup time; shorter chunks (2s) reduce latency but increase request overhead
- Client-side vs server-side adaptive bitrate: client-side is more responsive to network changes but can cause quality oscillation; server-side is smoother but less responsive

FAILURE MODES & WHAT BREAKS:
- Transcoding pipeline backup: a surge of new uploads overwhelms encoding capacity — new content is delayed by hours or days
- CDN cache miss storm: a new viral show launches and millions of requests hit origin servers simultaneously because edge caches are cold
- Adaptive bitrate oscillation: unstable network causes rapid quality switching, making the video unwatchable despite available bandwidth
- DRM license server failure: viewers can't start new streams because content decryption keys can't be retrieved — even cached content becomes inaccessible
- Regional CDN outage: one ISP's Netflix box fails, suddenly thousands of streams need to be served from farther servers, increasing latency and costs

KEY CHARACTERISTICS:
- Video streaming with adaptive bitrate for optimal quality
- Massive content libraries with efficient storage and delivery using CDN
- Global CDN distribution for low-latency worldwide access
- Video transcoding pipeline for multiple formats and qualities
- Personalized recommendation algorithms for content discovery
- Advanced analytics for viewing patterns and content performance
- DRM and content protection for licensed material
- Scalable architecture supporting millions of concurrent streams
''';

  static const String rideSharingServiceNotes = '''
Ride-Sharing Service System Design (e.g., Uber, Lyft)

SYSTEM OVERVIEW:
A ride-sharing service connects drivers and riders in real-time through sophisticated geospatial matching, dynamic pricing, and location tracking. The system handles millions of real-time location updates, efficient driver-rider matching, and complex pricing algorithms.

END-TO-END USER FLOW:
Driver flow: Driver opens the app and goes online → Driver Mobile App begins sending GPS pings every 4 seconds → Location Service stores the position in the Key-Value Store using Geohash indexing → driver is now visible to the Matching Engine as an available supply unit.
Ride request flow: Rider opens the app, enters destination → Pricing Engine calculates estimated fare (applying surge if demand > supply) → rider confirms → Matching Engine queries the Geospatial index for nearby available drivers in the rider's geohash cell (and adjacent cells) → scores candidates by distance, rating, and direction → best driver is selected and notified via push notification in <200ms → driver accepts → both rider and driver receive each other's details (name, photo, car info, ETA) returned to their apps → driver navigates to pickup using Routing Service → during the trip both apps show live GPS tracking via WebSocket → trip ends → Pricing Engine calculates final fare → Payment Processing charges the rider in <3 seconds → driver receives payout confirmation → receipt is delivered to the rider, completing the loop.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Rider Mobile App: Location-based ride requests and trip tracking
- Driver Mobile App: Trip acceptance, navigation, and earnings tracking
- Web Dashboard: Fleet management and administrative interfaces
- Partner APIs: Integration with third-party services and businesses

Network & Communication Layer:
- Load Balancer: Distributes geospatial queries across multiple servers
- API Gateway: Rate limiting and authentication for mobile applications
- WebSocket Servers: Real-time location updates and trip status
- Message Queue: Asynchronous processing of ride requests and updates

APPLICATION LAYER:
- Location Service: Real-time GPS tracking and location updates
- Matching Engine: Driver-rider pairing based on proximity and preferences
- Routing Service: Optimal route calculation and navigation
- Pricing Engine: Dynamic pricing based on demand, distance, and time
- Trip Management: Trip lifecycle from request to completion
- Payment Processing: Fare calculation, payment, and driver payouts

GEOSPATIAL SYSTEMS:
- Geohashing: Location indexing for efficient proximity searches
- Quadtrees: Spatial data structure for fast location queries
- Geospatial Database: Specialized storage for location data and queries
- Map Services: Integration with mapping providers for routes and ETA

Storage & Database Layer:
- NoSQL Database: Trip data, user profiles, and location history
- Time Series Database: Location tracking data and trip analytics
- Graph Database: City road networks and routing information
- SQL Database: User accounts, driver information, and billing data
- Key-Value Store: Real-time session data and active trip information

REAL-TIME PROCESSING:
- Stream Processor: Real-time location updates and trip status changes
- Event Processing: Driver availability changes and demand fluctuations
- Live Tracking: Continuous GPS updates for accurate trip monitoring
- Notification Service: Real-time alerts for drivers and riders

ANALYTICS & OPTIMIZATION:
- Demand Prediction: ML models for ride demand forecasting
- Supply Management: Driver positioning and availability optimization
- Surge Pricing Algorithm: Dynamic pricing based on supply and demand
- Route Optimization: Efficient routing for drivers and carpooling

BUSINESS LOGIC:
- Driver Onboarding: Background checks, vehicle verification, and approval
- Rider Management: Account creation, payment methods, and trip history
- Surge Pricing: Dynamic fare adjustments based on demand patterns
- Incentive System: Driver bonuses and rider promotions

ARCHITECTURAL PATTERNS:
- Microservices: Distributed services for geolocation, matching, routing, and pricing
- Event-Driven: Real-time location updates and trip status changes
- Pub/Sub: Message queue for coordinating ride requests and driver availability
- Caching: Location caching for fast proximity searches
- Sharding: Geospatial sharding by geographic regions

SECURITY & MONITORING:
- Fraud Detection: Unusual trip patterns and payment fraud prevention
- Safety Features: Emergency buttons, trip sharing, and driver verification
- Monitoring System: System performance and geospatial query optimization
- Analytics Engine: Business metrics, driver efficiency, and user satisfaction

REAL-WORLD NUMBERS & SCALE:
- 28M rides/day = 324 rides/sec (every second, 324 people somewhere in the world are starting a ride)
- 250K GPS pings/sec from 1M active drivers (each driver's phone sends location updates every 4 seconds)
- Driver-rider matching completes in 200ms (from ride request to driver assignment in one-fifth of a second)
- Geohashing reduces location search space by 99.99% (instead of checking all 1M drivers, only check ~100 nearby ones)
- ETA accuracy within ±2min for 85% of trips (the app's time estimate is off by less than 2 minutes most of the time)
- \$70B/year in total bookings (seventy billion dollars flows through the platform annually)
- Payment processing completes in <3sec (the entire charge happens before you've closed the car door)
- Dispatch system requires 99.99% SLA = only 52min downtime/year (if matching goes down, no one can get a ride)

TRADE-OFFS & ENGINEERING DECISIONS:
- Geohash vs Quadtree for location indexing: geohash is simpler and integrates with databases but has edge-case issues at cell boundaries; Quadtree is more precise but harder to implement and shard
- Nearest driver vs best driver matching: nearest is fastest to compute but may send a driver going the wrong direction; scoring multiple factors takes 200ms but improves rider experience
- Push-based vs pull-based driver location: pushing every 4sec is real-time but generates 250K writes/sec; pulling on demand saves writes but adds latency to matching
- Fixed pricing vs surge pricing: fixed is predictable for riders but causes driver shortages at peak; surge balances supply and demand but angers customers
- Single vs multi-region database: single is simpler but has high latency for distant cities; multi-region adds complexity but keeps rides fast globally

FAILURE MODES & WHAT BREAKS:
- GPS drift in urban canyons: tall buildings cause GPS to be off by 50-100m, matching riders with drivers on the wrong street
- Matching service overload: during surge events (concerts, sports), ride requests spike 10-50x normal and the matching engine times out
- Payment gateway timeout: if payment processing takes >3sec, the ride completion hangs and drivers can't accept new rides
- Geohash boundary problem: a driver and rider 10m apart can be in different geohash cells, making the driver "invisible" to the matching algorithm
- Cascading surge pricing: if one area surges, drivers migrate there, causing adjacent areas to also surge — creating price instability waves

KEY CHARACTERISTICS:
- Real-time geospatial processing with geolocation and location tracking
- Efficient driver-rider matching based on proximity and preferences
- Dynamic pricing algorithms responding to supply and demand
- GPS tracking, routing, and route optimization for trip efficiency
- Massive scale with millions of location updates per second
- Complex business logic for driver management and rider experience
- Real-time notifications and trip status updates
- Advanced analytics for demand prediction and operational optimization
''';

  // =================================================================
  // TIER 3: ADVANCED & SPECIALIZED SYSTEMS (Complex Engineering)
  // =================================================================

  static const String collaborativeEditorNotes = '''
Collaborative Editor System Design (e.g., Google Docs, Figma)

SYSTEM OVERVIEW:
A collaborative editor enables multiple users to edit documents simultaneously with real-time synchronization, conflict resolution, and operational transforms. The system handles concurrent editing, user presence, and document versioning with ultra-low latency.

END-TO-END USER FLOW:
Open flow: User opens a shared document link → Authentication check → Document Service loads the latest document snapshot from the DB → full document content is returned and rendered in the user's editor → a persistent WebSocket connection is established to the Collaborative Engine → User Presence Service broadcasts the user's cursor position to all other collaborators → the user can now see other editors' cursors highlighted in real-time.
Edit flow: User types a character → the change is captured as an Operation (insert/delete at position X) → Operation is sent over the WebSocket to the Collaborative Engine server in <100ms → the OT (Operational Transform) server orders the operation relative to any concurrent operations from other users, transforms it to resolve conflicts, and applies it to the authoritative document state → the resolved operation is broadcast to all other connected collaborators via their WebSocket connections → each collaborator's editor applies the transformed operation → all editors converge to the same document state, and every user sees the change appear within ~500ms → meanwhile Auto-save writes the new state to the DB so no work is lost.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Web Editor: Rich text editor with real-time collaboration features
- Mobile Apps: Touch-optimized editing for smartphones and tablets
- Desktop Apps: Native applications for offline editing capabilities
- Browser Extensions: Quick editing and document access tools

Network & Communication Layer:
- WebSocket Servers: Real-time bidirectional communication for live editing
- Load Balancer: Distributes WebSocket connections across multiple servers
- CDN: Caches static assets and document templates globally
- API Gateway: Authentication and rate limiting for editor operations

APPLICATION LAYER:
- Collaborative Engine: Core logic for real-time document synchronization
- Operational Transforms: Conflict resolution for concurrent edits
- Document Service: Document creation, storage, and version management
- User Presence Service: Real-time cursor positions and user awareness
- Comment System: Threaded discussions and document annotations
- Permission Management: Access control and sharing permissions

REAL-TIME SYNCHRONIZATION:
- Event Stream: Document change events and user operations
- Conflict Resolution: Operational transform algorithms for edit conflicts
- State Synchronization: Ensuring all clients have consistent document state
- Presence Broadcasting: Real-time user cursor and selection updates

Storage & Database Layer:
- NoSQL Database: Document content and version history storage
- Key-Value Store: Real-time session data and user presence information
- Object Storage: Media files, images, and document attachments
- SQL Database: User accounts, permissions, and sharing settings

DOCUMENT PROCESSING:
- Version Control: Document history and rollback capabilities
- Auto-save: Continuous saving of document changes
- Export Service: Convert documents to various formats (PDF, Word, etc.)
- Template Engine: Document templates and formatting presets

COLLABORATION FEATURES:
- Real-time Editing: Simultaneous multi-user editing with live updates
- User Presence: See other users' cursors and selections in real-time
- Comment Threading: Collaborative discussions and feedback
- Suggestion Mode: Track changes and review proposed edits
- Document Sharing: Granular permission controls for access management

SECURITY & ACCESS CONTROL:
- Authentication: Secure user login and session management
- Authorization: Document-level and feature-level permissions
- Encryption: End-to-end encryption for sensitive documents
- Audit Logging: Track all document changes and user actions

ARCHITECTURAL PATTERNS:
- Microservices: Distributed services for editing, collaboration, and document management
- Event-Driven: Real-time document updates and user action broadcasting
- Pub/Sub: Message distribution for collaborative editing events
- Caching: Document caching for fast load times
- Replication: Document replication for availability and backup

PERFORMANCE OPTIMIZATION:
- Delta Compression: Efficient transmission of document changes
- Caching Strategy: Document fragments cached for fast loading
- Lazy Loading: Load document sections on-demand
- Offline Support: Local editing with synchronization when online

REAL-WORLD NUMBERS & SCALE:
- 30M concurrent editors at peak (thirty million people typing in shared documents at the same time)
- 60M operations/sec from keystrokes (every keystroke, cursor move, and formatting change is an operation that must be synced)
- OT (Operational Transform) transform takes 0.01ms (transforming one operation against another is nearly instant — ten microseconds)
- CRDT metadata adds 2-5x overhead to text size (a 1KB document might need 2-5KB of metadata to track every character's history)
- WebSocket capacity: 50K connections/server → need 600 servers for 30M users (each server can handle 50,000 persistent connections)
- Operation batching reduces load: 60M/sec → 600K/sec (grouping keystrokes into batches gives a 100x reduction in network messages)
- Latency budget: own keystrokes appear in <100ms / others' edits appear in <500ms (your typing must feel instant; others' changes can be slightly delayed)

TRADE-OFFS & ENGINEERING DECISIONS:
- OT vs CRDT for conflict resolution: OT requires a central server but is simpler and battle-tested (Google Docs uses it); CRDT works peer-to-peer but adds 2-5x metadata overhead
- WebSocket vs HTTP polling: WebSocket gives real-time updates but requires persistent connections (50K/server limit); polling is simpler but wastes bandwidth and adds latency
- Character-level vs operation-level sync: character-level is most precise but generates 60M ops/sec; operation-level batching reduces this 100x but adds slight delay
- Full document vs delta sync: sending the full document is simple but wasteful for large docs; deltas are efficient but complex to merge correctly
- Central server vs peer-to-peer: central is easier to implement and reason about but creates a single point of failure; P2P is resilient but conflict resolution is much harder

FAILURE MODES & WHAT BREAKS:
- WebSocket server crash: 50K users simultaneously lose connection and must reconnect — thundering herd problem on the remaining servers
- OT transform divergence: if operations arrive in different order at different clients, documents can permanently diverge — need server-authoritative ordering
- CRDT tombstone bloat: deleted characters leave metadata behind, causing documents to grow without bound over time — need periodic garbage collection
- Network partition: users on different sides of a partition keep editing — when it heals, massive conflict resolution spike
- Cursor position desync: after concurrent edits, cursor positions shift and users end up typing in the wrong location

KEY CHARACTERISTICS:
- Real-time collaboration with operational transform and conflict resolution
- Conflict resolution for concurrent editing operations
- User presence awareness and live cursor tracking
- Document synchronization with ultra-low latency
- Version control and document history management
- WebSocket-based communication for instant updates
- Complex permission systems for document access control
- Offline editing capabilities with online synchronization
''';

  static const String liveStreamingPlatformNotes = '''
Live Streaming Platform System Design (e.g., Twitch, YouTube Live)

SYSTEM OVERVIEW:
A live streaming platform delivers real-time video content to millions of concurrent viewers with ultra-low latency, interactive chat, and content discovery. The system handles live video ingestion, transcoding, distribution, and real-time audience interaction.

END-TO-END USER FLOW:
Broadcast flow (streamer): Streamer starts their streaming software (e.g., OBS) → video is encoded locally and sent via RTMP to the Video Ingest server (1-5 sec camera-to-server latency) → Live Transcoding Service converts the stream into multiple quality variants (1080p, 720p, 480p, 360p) in real-time → HLS segments (2-6 seconds each) are pushed to CDN edge servers globally as they are produced → the stream is now live and discoverable.
Watch flow (viewer): Viewer opens the platform and sees the live stream in recommendations → clicks the stream → player requests the HLS playlist from the nearest CDN edge server → CDN begins delivering the latest video segments (viewer is always ~2-8 seconds behind the live moment) → Adaptive Bitrate player monitors download speed and switches quality seamlessly → viewer watches the live video in their browser or app → simultaneously, viewers send chat messages which flow through the WebSocket Chat Service, get distributed to all connected viewers, and appear in the live chat panel in real-time → the viewer sees both the live video and the live audience reacting together, completing the interactive experience.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Streaming Software: OBS, XSplit integration for content creators
- Mobile Apps: Live streaming and viewing on iOS and Android
- Web Player: Browser-based live video player with chat integration
- Smart TV Apps: Television applications for living room viewing

LIVE VIDEO PIPELINE:
- Video Ingest: RTMP/WebRTC servers for live video upload
- Live Transcoding: Real-time video processing and format conversion
- Adaptive Streaming: Multiple quality streams for different bandwidths
- Stream Distribution: Delivery to edge servers and CDN networks

Network & Delivery:
- Global CDN: Worldwide content delivery for low-latency streaming
- Edge Servers: Geographically distributed servers for regional delivery
- Load Balancer: Distributes streaming load across multiple servers
- WebRTC: Ultra-low latency streaming for interactive applications

APPLICATION LAYER:
- Stream Management: Live stream lifecycle and broadcaster tools
- Chat Service: Real-time messaging and audience interaction
- Content Discovery: Live stream recommendations and trending content
- User Management: Broadcaster profiles and viewer accounts
- Monetization: Subscriptions, donations, and advertising integration

REAL-TIME FEATURES:
- Live Chat: Real-time messaging with moderation capabilities
- Interactive Elements: Polls, donations, and viewer engagement tools
- Stream Analytics: Real-time viewership and engagement metrics
- Notification Service: Live stream alerts and follow notifications

Storage & Database Layer:
- Object Storage: Live stream recordings and video-on-demand content
- NoSQL Database: User profiles, chat history, and stream metadata
- Time Series Database: Viewership analytics and performance metrics
- CDN Storage: Cached stream segments for playback and recording

CHAT & INTERACTION:
- Message Queue: Real-time chat message distribution
- Chat Moderation: Automated and manual content filtering
- Emote System: Custom emojis and subscriber perks
- WebSocket Servers: Real-time bidirectional communication

CONTENT MANAGEMENT:
- Stream Recording: Automatic recording of live streams for VOD
- Clip Creation: User-generated highlights and shareable moments
- Content Moderation: AI-powered detection of inappropriate content
- DMCA Protection: Copyright detection and takedown procedures

MONETIZATION & BUSINESS:
- Subscription System: Paid channels and premium features
- Donation Processing: Real-time viewer contributions to streamers
- Advertising: Pre-roll, mid-roll, and banner advertisement integration
- Analytics Dashboard: Revenue tracking and audience insights

ARCHITECTURAL PATTERNS:
- Microservices: Distributed services for RTMP ingestion, transcoding, chat, and delivery
- Event-Driven: Real-time stream events and chat message processing
- Pub/Sub: Message queue for live chat distribution and notifications
- Caching: CDN caching for stream segments and content delivery
- Sharding: Geographic sharding for regional live streaming

PERFORMANCE & SCALING:
- Auto-scaling: Dynamic resource allocation for varying viewership
- Latency Optimization: Sub-second delay for interactive streaming
- Quality Adaptation: Automatic bitrate adjustment for viewer connections
- Global Distribution: Multi-region deployment for worldwide coverage

REAL-WORLD NUMBERS & SCALE:
- Twitch serves 7M concurrent viewers at peak (seven million people watching live streams at the same time)
- 100K live streams running simultaneously (one hundred thousand broadcasters going live at once)
- Transcoding load: 100K streams × 4 CPU cores each = 400K CPU cores needed (a massive compute farm just for video encoding)
- RTMP ingest latency: 1-5sec from camera to server (the delay from a streamer's webcam to the platform's servers)
- HLS delivery adds 2-6sec segment delay (video is cut into chunks, so viewers are always a few seconds behind the broadcaster)
- Chat handles 150K messages/sec at peak (during major events, chat moves impossibly fast — 150,000 messages every second)
- CDN math: 1M viewers × 5Mbps = 5Pbps if served directly (five petabits per second — impossible without edge caching distributing the load)
- 810TB of new video recorded per day (every live stream is saved, generating nearly a petabyte of new video daily)
- Ad insertion must complete in 200ms (ads are stitched into the live stream in real-time, with only 200 milliseconds to do it)

TRADE-OFFS & ENGINEERING DECISIONS:
- RTMP vs WebRTC for ingest: RTMP is widely supported and reliable with 1-5sec latency; WebRTC offers sub-second latency but is harder to scale and less stable
- Per-stream transcoding vs shared transcoding: dedicated cores per stream give consistent quality but waste resources for low-viewer streams; shared pools save money but risk quality drops under load
- HLS vs DASH for delivery: HLS has universal Apple device support; DASH is more flexible but less widely supported — most platforms use HLS
- Chat in-memory vs persistent: in-memory is fast (150K msg/sec) but loses history on restart; persistent saves everything but adds write latency
- VOD recording: record everything vs on-demand: recording all 100K streams generates 810TB/day; selective recording saves storage but some content is lost forever

FAILURE MODES & WHAT BREAKS:
- Transcoding farm overload: surge in new streams exhausts CPU capacity — new streams queue up and viewers see "processing" errors
- RTMP ingest server failure: streamer's broadcast drops mid-stream — need automatic reconnection and server failover
- Chat message flood: popular streamers' chats hit 150K msg/sec, overwhelming the WebSocket servers — need message throttling and batching
- CDN edge cache cold start: major event starts and edge caches have no content yet — first viewers experience buffering while caches warm up
- Ad insertion timeout: if the ad decision takes >200ms, the stream stutters or shows a blank frame — need fallback ad content pre-loaded at edge

KEY CHARACTERISTICS:
- Ultra-low latency streaming with RTMP for real-time interaction
- Massive concurrent viewership support (millions of viewers)
- Real-time chat and live audience engagement features with broadcasting
- Live video transcoding and adaptive bitrate streaming
- Global CDN distribution for worldwide low-latency delivery
- Interactive features like donations, polls, and viewer participation
- Content creator tools and monetization features
- Stream recording and video-on-demand conversion
''';

  static const String globalGamingLeaderboardNotes = '''
Global Gaming Leaderboard System Design (e.g., Steam, Xbox Live)

SYSTEM OVERVIEW:
A global gaming leaderboard system handles millions of real-time score updates, player rankings, and competitive gaming data. The system provides instant rank calculations, anti-cheat measures, and high-performance sorting for massive player bases across multiple games.

END-TO-END USER FLOW:
Score submit flow: Player finishes a game session → Game Client sends the score (with a cryptographic signature to prevent tampering) to the Score Processing Service → Anti-cheat System runs statistical validation (is this score within normal human range?) → if valid, the score is written to Redis using ZADD on the game's Sorted Set, which automatically re-ranks all players in O(log n) time → the player's new rank is calculated instantly via ZRANK → the updated rank is pushed back to the player's game client via WebSocket in ~16ms total end-to-end → the player sees their new position on the leaderboard immediately after the match ends.
View leaderboard flow: Player opens the leaderboard screen → client requests the top N players → Ranking Engine runs ZRANGE on the Redis Sorted Set (0.1ms for 100M players) → player names, scores, and rank positions are fetched from the Key-Value Store → the ranked list is returned to the client and displayed → the player sees their own rank highlighted, with live updates pushed via WebSocket whenever nearby players' scores change.

CORE ARCHITECTURE COMPONENTS:
Client & Interface Layer:
- Game Clients: Integration with games for score submission and leaderboard display
- Mobile Apps: Leaderboard viewing and player statistics on mobile devices
- Web Dashboard: Comprehensive leaderboard views and player profiles
- API Gateway: Third-party integration for tournaments and esports platforms

Network & Communication Layer:
- Load Balancer: Distributes high-frequency score updates across servers
- API Gateway: Rate limiting and authentication for score submissions
- Real-time Sync: WebSocket connections for live leaderboard updates
- Regional Servers: Geographic distribution for low-latency score updates

APPLICATION LAYER:
- Score Processing Service: Validates and processes incoming game scores
- Ranking Engine: Real-time rank calculation and leaderboard generation
- Anti-cheat System: Anomaly detection and suspicious score validation
- Tournament Management: Competitive event organization and tracking
- Achievement System: Player badges, milestones, and recognition
- Statistics Engine: Player performance analytics and historical data

HIGH-PERFORMANCE STORAGE:
- Redis Sorted Sets: Primary data structure for fast ranking operations
- Key-Value Store: Player profiles and current rankings
- Time Series Database: Historical scores and performance trends
- SQL Database: Player accounts, game information, and tournament data
- In-Memory Cache: Hot leaderboard data for instant access

REAL-TIME PROCESSING:
- Stream Processor: Real-time score updates and rank recalculation
- Event Processing: Game completion events and score submissions
- Live Updates: Instant leaderboard changes pushed to connected clients
- Batch Processing: Periodic leaderboard cleanup and optimization

RANKING ALGORITHMS:
- ELO Rating System: Skill-based rating for competitive games
- Percentile Rankings: Player position relative to overall population
- Seasonal Rankings: Time-based leaderboard resets and competitions
- Multi-game Rankings: Cross-game player statistics and achievements

ANTI-CHEAT & VALIDATION:
- Score Validation: Server-side verification of submitted scores
- Anomaly Detection: Statistical analysis of unusual score patterns
- Rate Limiting: Prevents score submission abuse and gaming
- Audit Trail: Complete history of score changes and investigations

SHARDING & SCALABILITY:
- Horizontal Sharding: Distribute players across multiple database shards
- Regional Sharding: Geographic distribution for local leaderboards
- Game-specific Sharding: Separate leaderboards for different games
- Auto-scaling: Dynamic resource allocation based on player activity

ANALYTICS & INSIGHTS:
- Player Analytics: Detailed performance metrics and improvement tracking
- Game Balance: Statistical analysis for game difficulty balancing
- Competitive Intelligence: Tournament and esports data analysis
- Business Metrics: Player engagement and retention analytics

ARCHITECTURAL PATTERNS:
- Microservices: Distributed services for ranking, scores, anti-cheat, and analytics
- Event-Driven: Real-time score processing and rank updates
- Pub/Sub: Score update notifications and real-time updates broadcasting
- Caching: In-memory caching for hot leaderboard data
- Sharding: Horizontal sharding by game and region for scalability
- Replication: Score replication for high availability

SECURITY & INTEGRITY:
- Cryptographic Verification: Secure score submission with digital signatures
- Monitoring System: Real-time detection of cheating attempts and exploits
- Fair Play Enforcement: Automated penalties for cheating violations with competition integrity
- Data Integrity: Backup and recovery systems for leaderboard data

REAL-WORLD NUMBERS & SCALE:
- 80M monthly active players (eighty million people competing on leaderboards every month)
- 13.9K score updates/sec (nearly fourteen thousand new scores submitted every second across all games)
- Redis ZADD handles 100K ops/sec (a single Redis server can process 100,000 sorted set insertions per second — plenty of headroom)
- ZRANK lookup takes 0.1ms for 100M players (finding your rank among 100 million players takes just 27 comparisons — O(log n) binary search)
- 10GB RAM per leaderboard (100M players × 100 bytes each = about 10 gigabytes, fits in one server's memory)
- ELO rating calculation takes <0.01ms (rating math is simple arithmetic — nearly instant even at scale)
- Anti-cheat flags 0.3% of submissions (about 1 in 300 scores is suspicious and gets flagged for review)
- WebSocket push for live updates uses 20x less bandwidth than polling (pushing changes only when they happen vs. clients asking "anything new?" every second)
- End-to-end score pipeline: 16ms from game event to leaderboard update (score submitted → validated → stored → ranked → pushed to viewers in 16 milliseconds)

TRADE-OFFS & ENGINEERING DECISIONS:
- Redis sorted sets vs database: Redis gives 0.1ms rank lookups but all data must fit in RAM (10GB per 100M players); database handles larger datasets but rank queries take 50-100ms
- Global vs regional leaderboards: global gives one true ranking but adds latency for distant players; regional is faster but fragments the competitive experience
- Real-time vs batched rank updates: real-time gives instant feedback (16ms pipeline) but costs 13.9K writes/sec; batching every 5sec reduces writes 5000x but players see stale ranks
- ELO vs Glicko vs TrueSkill: ELO is simple and well-understood but assumes equal game lengths; Glicko adds confidence intervals; TrueSkill handles team games but is more complex
- WebSocket vs polling for live updates: WebSocket uses 20x less bandwidth but requires persistent connections; polling is simpler to implement but wastes bandwidth

FAILURE MODES & WHAT BREAKS:
- Redis memory exhaustion: if a leaderboard grows beyond available RAM, Redis starts evicting data or crashes — need monitoring and sharding before this happens
- Anti-cheat false positives: legitimate skilled players get flagged and their scores removed — need human review pipeline for edge cases
- Score submission replay attack: hackers replay valid score packets to inflate rankings — need nonce/timestamp validation
- Cross-region sync lag: players in different regions see different leaderboard positions during sync delays — causes confusion in competitive tournaments
- Hot partition: the top of the leaderboard (top 100 players) gets read 1000x more than the rest — need dedicated caching for hot ranges

KEY CHARACTERISTICS:
- Real-time ranking with millisecond-level score updates and real-time updates
- High-performance sorted sets using Redis for instant rank queries
- Massive scale supporting millions of players across multiple games
- Anti-cheat systems with statistical anomaly detection
- Horizontal sharding for global player distribution
- Complex ranking algorithms including ELO and percentile systems
- Tournament and competitive gaming support with competition features
- Historical performance tracking and analytics
''';

  // =================================================================
  // SYSTEM CATEGORIZATION AND METADATA
  // =================================================================

  static const Map<String, Map<String, dynamic>> systemCategories = {
    'Tier 1: Foundational Systems': {
      'description': 'Perfect for learning core, fundamental concepts',
      'difficulty': 'Beginner to Intermediate',
      'systems': ['URL Shortener', 'Pastebin Service', 'Web Crawler'],
      'keyLearnings': [
        'Basic system design patterns',
        'Database design (SQL vs NoSQL)',
        'Caching strategies',
        'API design',
        'Load balancing fundamentals',
      ],
    },
    'Tier 2: Web-Scale Giants': {
      'description':
          'Covers systems that serve millions of users with complex features',
      'difficulty': 'Intermediate to Advanced',
      'systems': [
        'Social Media News Feed',
        'Video Streaming Service',
        'Ride-Sharing Service',
      ],
      'keyLearnings': [
        'Massive scale architecture',
        'Real-time systems',
        'Content delivery networks',
        'Machine learning integration',
        'Global distribution',
      ],
    },
    'Tier 3: Advanced & Specialized Systems': {
      'description':
          'Dives into complex, niche problems for experienced engineers',
      'difficulty': 'Advanced to Expert',
      'systems': [
        'Collaborative Editor',
        'Live Streaming Platform',
        'Global Gaming Leaderboard',
      ],
      'keyLearnings': [
        'Real-time collaboration',
        'Ultra-low latency systems',
        'Conflict resolution algorithms',
        'High-frequency data processing',
        'Specialized data structures',
      ],
    },
  };

  // =================================================================
  // QUICK REFERENCE MAPPING
  // =================================================================

  static const Map<String, String> systemNotesMapping = {
    'URL Shortener': urlShortenerNotes,
    'URL Shortener (e.g., TinyURL)': urlShortenerNotes,
    'Pastebin Service': pastebinServiceNotes,
    'Pastebin Service (e.g., Pastebin.com)': pastebinServiceNotes,
    'Web Crawler': webCrawlerNotes,
    'Social Media News Feed': socialMediaNewsFeedNotes,
    'Social Media News Feed (e.g., Facebook, X/Twitter)':
        socialMediaNewsFeedNotes,
    'Video Streaming Service': videoStreamingServiceNotes,
    'Video Streaming Service (e.g., Netflix, YouTube)':
        videoStreamingServiceNotes,
    'Ride-Sharing Service': rideSharingServiceNotes,
    'Ride-Sharing Service (e.g., Uber, Lyft)': rideSharingServiceNotes,
    'Collaborative Editor': collaborativeEditorNotes,
    'Collaborative Editor (e.g., Google Docs, Figma)': collaborativeEditorNotes,
    'Live Streaming Platform': liveStreamingPlatformNotes,
    'Global Gaming Leaderboard': globalGamingLeaderboardNotes,
  };

  // Helper method to get system notes by name
  static String? getSystemNotes(String systemName) {
    return systemNotesMapping[systemName];
  }

  // Helper method to get all system names
  static List<String> getAllSystemNames() {
    return systemCategories.values
        .expand((category) => category['systems'] as List<String>)
        .toList();
  }

  // Helper method to get systems by tier
  static List<String> getSystemsByTier(String tier) {
    return systemCategories[tier]?['systems'] ?? [];
  }
}
