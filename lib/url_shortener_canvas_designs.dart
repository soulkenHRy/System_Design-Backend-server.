// URL Shortener System - Canvas Design Data
// Contains predefined system designs using available canvas icons
// These designs can be loaded into the SystemDesignCanvasScreen
// Connections track which icons are connected (from -> to)

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined URL Shortener system designs for the canvas
class URLShortenerCanvasDesigns {
  // ==========================================
  // Helper Methods
  // ==========================================

  /// Creates an icon data map for canvas
  static Map<String, dynamic> _createIcon(
    String name,
    String category,
    double x,
    double y, {
    String? id, // Optional unique ID for referencing in connections
  }) {
    final iconData = SystemDesignIcons.getIcon(name);

    return {
      'id': id ?? name, // Use name as default ID
      'name': name,
      'iconCodePoint': iconData?.codePoint ?? Icons.help.codePoint,
      'iconFontFamily': iconData?.fontFamily ?? 'MaterialIcons',
      'category': category,
      'positionX': x,
      'positionY': y,
    };
  }

  /// Creates a connection between two icons
  /// [fromIconIndex] - Index of the source icon in the icons list
  /// [toIconIndex] - Index of the destination icon in the icons list
  /// [label] - Optional label describing the connection
  static Map<String, dynamic> _createConnection(
    int fromIconIndex,
    int toIconIndex, {
    String? label,
    int color = 0xFF2196F3, // Blue
    double strokeWidth = 2.0,
  }) {
    return {
      'fromIconIndex': fromIconIndex,
      'toIconIndex': toIconIndex,
      'label': label,
      'color': color,
      'strokeWidth': strokeWidth,
    };
  }

  // ==========================================
  // DESIGN 1: Basic URL Shortener Architecture
  // ==========================================
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic URL Shortener',
    'description': 'Simple URL shortening service with basic components',
    'explanation': '''
## Basic URL Shortener Architecture

### Overview
This is the simplest form of a URL shortener, suitable for small-scale applications or learning purposes.

### Components

**1. Clients (Web Browser & Mobile Client)**
- Users access the service through web browsers or mobile apps
- They can create short URLs or be redirected to original URLs

**2. API Gateway**
- Single entry point for all client requests
- Routes requests to the appropriate backend service
- Handles basic request validation

**3. Application Server**
- Core business logic processing
- Decides whether to create a new short URL or redirect an existing one

**4. URL Shortening Service**
- Generates unique short codes (e.g., using Base62 encoding)
- Stores the mapping between short code and original URL

**5. URL Redirect Service**
- Looks up short codes and returns the original URL
- Performs HTTP 301/302 redirects

**6. SQL Database**
- Stores URL mappings permanently
- Schema: short_code (PK), original_url, created_at, expires_at

**7. Cache**
- Stores frequently accessed URL mappings
- Reduces database load for popular links

### Data Flow
1. User submits long URL → API Gateway → App Server → URL Shortening Service → Database
2. User clicks short URL → API Gateway → App Server → URL Redirect Service → Cache/Database → Redirect

### Icons Explained
**Web Browser** - Users access the URL shortener through their web browser to create or use short links.

**Mobile Client** - Mobile app users who create or click on short URLs from their phones.

**API Gateway** - The single entry point that receives all requests and routes them to the right service.

**Application Server** - The main server running the core business logic for URL operations.

**URL Shortening Service** - Creates unique short codes and saves the mapping to the original long URL.

**URL Redirect Service** - Looks up short codes and sends users to the original URL.

**SQL Database** - Permanently stores all URL mappings with creation dates and expiry info.

**Cache** - Keeps popular URL mappings in memory for faster lookups.

### How They Work Together
1. User opens **Web Browser** or **Mobile Client** and enters a long URL
2. Request goes to **API Gateway** which validates and forwards it
3. **Application Server** receives the request and decides what to do
4. For new URLs: **URL Shortening Service** generates a short code and stores it in **SQL Database**
5. For redirects: **URL Redirect Service** checks **Cache** first, then **SQL Database**
6. User gets the short URL back or gets redirected to the original
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 100, 300),
      // Index 1: Mobile Client
      _createIcon('Mobile Client', 'Client & Interface', 100, 450),
      // Index 2: API Gateway
      _createIcon('API Gateway', 'Networking', 300, 375),
      // Index 3: Application Server
      _createIcon('Application Server', 'Servers & Computing', 500, 375),
      // Index 4: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 700, 300),
      // Index 5: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 700, 450),
      // Index 6: SQL Database
      _createIcon('SQL Database', 'Database & Storage', 950, 375),
      // Index 7: Cache
      _createIcon('Cache', 'Caching,Performance', 700, 600),
    ],
    'connections': [
      // Client Layer -> API Gateway
      _createConnection(0, 2, label: 'HTTP Request'),
      _createConnection(1, 2, label: 'HTTP Request'),
      // API Gateway -> Application Server
      _createConnection(2, 3, label: 'Route Request'),
      // Application Server -> Services
      _createConnection(3, 4, label: 'Create Short URL'),
      _createConnection(3, 5, label: 'Redirect Request'),
      // Services -> Database
      _createConnection(4, 6, label: 'Store URL Mapping'),
      _createConnection(5, 6, label: 'Lookup URL'),
      // Cache connections
      _createConnection(5, 7, label: 'Check Cache'),
      _createConnection(7, 6, label: 'Cache Miss -> DB'),
    ],
  };

  // ==========================================
  // DESIGN 2: Scalable URL Shortener with Load Balancing
  // ==========================================
  static Map<String, dynamic> get scalableArchitecture => {
    'name': 'Scalable URL Shortener',
    'description': 'Horizontally scalable URL shortener with load balancing',
    'explanation': '''
## Scalable URL Shortener Architecture

### Overview
A horizontally scalable URL shortener designed to handle millions of requests by distributing load across multiple server clusters.

### Components

**1. Multi-Client Support (Web, Mobile, Desktop)**
- Supports diverse client types
- All clients connect through a unified entry point

**2. CDN (Content Delivery Network)**
- Caches static content at edge locations
- Reduces latency for users worldwide
- Can cache redirect responses for popular URLs

**3. Global Load Balancer**
- Distributes traffic across data centers
- Provides geographic routing for lowest latency
- Health checks and automatic failover

**4. Rate Limiter**
- Prevents abuse and DDoS attacks
- Token bucket or sliding window algorithm
- Per-user and global rate limits

**5. Multiple Server Clusters**
- Horizontal scaling with 3+ clusters
- Each cluster handles a portion of traffic
- Stateless design for easy scaling

**6. Redis Cache**
- Distributed caching layer
- Sub-millisecond lookups
- Stores hot URL mappings

**7. NoSQL & SQL Databases**
- NoSQL for fast reads (URL lookups)
- SQL for transactional writes (URL creation)
- Database sharding for horizontal scaling

**8. Analytics Service**
- Tracks all click events asynchronously
- Generates real-time metrics

### Scaling Strategy
- Add more server clusters as traffic grows
- Use consistent hashing for cache distribution
- Database sharding by short code prefix

### Icons Explained
**Web Browser** - Desktop users accessing the URL shortener service.

**Mobile Client** - Mobile app users creating or clicking short links.

**Desktop Client** - Native desktop application users.

**CDN** - Content Delivery Network that caches responses at edge locations worldwide for faster access.

**Global Load Balancer** - Distributes traffic across data centers and provides geographic routing.

**Rate Limiter** - Prevents abuse by limiting how many requests each user can make.

**API Gateway** - Routes requests to the appropriate backend services.

**Server Cluster** (3 instances) - Groups of servers that handle portions of traffic for horizontal scaling.

**URL Shortening Service** - Generates unique short codes for new URLs.

**URL Redirect Service** - Handles URL lookups and redirects users.

**Redis Cache** - Distributed cache for sub-millisecond lookups of popular URLs.

**NoSQL Database** - Fast reads for URL lookups.

**SQL Database** - Transactional writes for URL creation.

**Analytics Service** - Tracks all click events asynchronously.

### How They Work Together
1. Users from **Web Browser**, **Mobile Client**, or **Desktop Client** make requests
2. **CDN** caches responses at edge for faster delivery
3. **Global Load Balancer** routes to the nearest data center
4. **Rate Limiter** checks if user is within allowed limits
5. **API Gateway** forwards valid requests to **Server Clusters**
6. Clusters call **URL Shortening Service** or **URL Redirect Service**
7. Services use **Redis Cache** for fast lookups, then **NoSQL Database** or **SQL Database**
8. **Analytics Service** logs all clicks for reporting
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 50, 200),
      // Index 1: Mobile Client
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      // Index 2: Desktop Client
      _createIcon('Desktop Client', 'Client & Interface', 50, 500),
      // Index 3: CDN
      _createIcon('CDN', 'Networking', 200, 350),
      // Index 4: Global Load Balancer
      _createIcon('Global Load Balancer', 'Networking', 350, 350),
      // Index 5: Rate Limiter
      _createIcon('Rate Limiter', 'Networking', 500, 250),
      // Index 6: API Gateway
      _createIcon('API Gateway', 'Networking', 500, 450),
      // Index 7: Server Cluster 1
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        700,
        200,
        id: 'Server Cluster 1',
      ),
      // Index 8: Server Cluster 2
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        700,
        350,
        id: 'Server Cluster 2',
      ),
      // Index 9: Server Cluster 3
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        700,
        500,
        id: 'Server Cluster 3',
      ),
      // Index 10: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 900, 275),
      // Index 11: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 900, 425),
      // Index 12: Redis Cache
      _createIcon('Redis Cache', 'Caching,Performance', 1100, 200),
      // Index 13: NoSQL Database
      _createIcon('NoSQL Database', 'Database & Storage', 1100, 350),
      // Index 14: SQL Database
      _createIcon('SQL Database', 'Database & Storage', 1100, 500),
      // Index 15: Analytics Service
      _createIcon('Analytics Service', 'Security,Monitoring', 900, 600),
    ],
    'connections': [
      // Clients -> CDN
      _createConnection(0, 3, label: 'Request'),
      _createConnection(1, 3, label: 'Request'),
      _createConnection(2, 3, label: 'Request'),
      // CDN -> Load Balancer
      _createConnection(3, 4, label: 'Forward'),
      // Load Balancer -> Rate Limiter & API Gateway
      _createConnection(4, 5, label: 'Check Rate'),
      _createConnection(4, 6, label: 'Route'),
      // Rate Limiter -> Server Clusters
      _createConnection(5, 7, label: 'Allowed'),
      _createConnection(5, 8, label: 'Allowed'),
      // API Gateway -> Server Clusters
      _createConnection(6, 8, label: 'Route'),
      _createConnection(6, 9, label: 'Route'),
      // Server Clusters -> Services
      _createConnection(7, 10, label: 'Create URL'),
      _createConnection(8, 10, label: 'Create URL'),
      _createConnection(8, 11, label: 'Redirect'),
      _createConnection(9, 11, label: 'Redirect'),
      // Services -> Cache/DB
      _createConnection(10, 12, label: 'Cache URL'),
      _createConnection(10, 13, label: 'Store'),
      _createConnection(11, 12, label: 'Lookup Cache'),
      _createConnection(11, 14, label: 'Lookup DB'),
      // Analytics
      _createConnection(11, 15, label: 'Log Click'),
    ],
  };

  // ==========================================
  // DESIGN 3: URL Shortener with Caching Strategy
  // ==========================================
  static Map<String, dynamic> get cachingOptimizedArchitecture => {
    'name': 'Cache-Optimized URL Shortener',
    'description':
        'Multi-layer caching strategy for high-performance redirects',
    'explanation': '''
## Cache-Optimized URL Shortener Architecture

### Overview
Optimized for maximum redirect performance through a multi-tier caching strategy, achieving sub-10ms response times for popular URLs.

### Components

**1. Browser Cache**
- First layer of caching
- HTTP cache headers (Cache-Control, ETag)
- Instant redirects for recently visited URLs

**2. CDN Cache (Edge Cache)**
- Caches responses at edge locations globally
- 80% of redirects served from edge
- TTL-based invalidation

**3. Redis Cache (Distributed)**
- Centralized distributed cache
- Handles CDN cache misses
- Cluster mode for high availability

**4. In-Memory Cache (Local)**
- Application-level caching
- LRU eviction policy
- Fastest lookup after browser cache

**5. Key-Value Store**
- Primary storage for URL mappings
- Optimized for point lookups
- Eventual consistency acceptable

**6. Sync Service**
- Keeps all cache layers consistent
- Pub/sub for cache invalidation
- Handles new URL propagation

### Cache Hierarchy
```
1. Browser Cache (0ms) → Hit? Return
2. CDN Cache (5ms) → Hit? Return
3. Redis Cache (2ms) → Hit? Return  
4. In-Memory Cache (0.1ms) → Hit? Return
5. Database (10ms) → Store in all caches
```

### Cache Strategy
- Write-through for new URLs
- Read-through with TTL for lookups
- Popular URLs never expire from cache

### Icons Explained
**Web Browser** - Users accessing the service through their browser.

**Mobile Client** - Mobile app users.

**CDN** - Content Delivery Network serving cached responses from edge locations.

**CDN Cache** - Edge cache layer at CDN locations, handles 80% of redirects.

**Load Balancer** - Distributes traffic across backend servers.

**Redis Cache** - Distributed cache layer for centralized caching with sub-millisecond lookups.

**In-Memory Cache** - Local application-level cache with LRU eviction, fastest lookup.

**Application Server** - Handles business logic for shortening and redirecting.

**URL Shortening Service** - Creates short URLs and manages the caching strategy.

**URL Redirect Service** - Looks up URLs through the cache hierarchy.

**Browser Cache** - Local browser cache using HTTP headers, instant redirects.

**Key-Value Store** - Primary storage optimized for point lookups.

**SQL Database** - Persistent storage for URL mappings.

**Sync Service** - Keeps all cache layers consistent through pub/sub.

### How They Work Together
1. User in **Web Browser** or **Mobile Client** requests a URL
2. **Browser Cache** checked first (0ms) - instant if cached
3. **CDN** receives request, checks **CDN Cache** (5ms)
4. On miss, **Load Balancer** forwards to backend
5. **Redis Cache** (2ms) and **In-Memory Cache** (0.1ms) checked
6. On miss, **Application Server** calls services
7. **URL Redirect Service** queries **Key-Value Store** or **SQL Database** (10ms)
8. **Sync Service** propagates new URLs to all cache layers
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 50, 300),
      // Index 1: Mobile Client
      _createIcon('Mobile Client', 'Client & Interface', 50, 450),
      // Index 2: CDN
      _createIcon('CDN', 'Networking', 200, 375),
      // Index 3: CDN Cache
      _createIcon('CDN Cache', 'Caching,Performance', 200, 525),
      // Index 4: Load Balancer
      _createIcon('Load Balancer', 'Networking', 350, 375),
      // Index 5: Redis Cache
      _createIcon('Redis Cache', 'Caching,Performance', 500, 250),
      // Index 6: In-Memory Cache
      _createIcon('In-Memory Cache', 'Caching,Performance', 500, 500),
      // Index 7: Application Server
      _createIcon('Application Server', 'Servers & Computing', 650, 375),
      // Index 8: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 850, 300),
      // Index 9: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 850, 450),
      // Index 10: Browser Cache
      _createIcon('Browser Cache', 'Caching,Performance', 50, 600),
      // Index 11: Key-Value Store
      _createIcon('Key-Value Store', 'Database & Storage', 1050, 300),
      // Index 12: SQL Database
      _createIcon('SQL Database', 'Database & Storage', 1050, 450),
      // Index 13: Sync Service
      _createIcon('Sync Service', 'Cloud,Infrastructure', 700, 150),
    ],
    'connections': [
      // Clients -> CDN
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      // Browser has local cache
      _createConnection(0, 10, label: 'Local Cache'),
      // CDN checks CDN Cache
      _createConnection(2, 3, label: 'Check Edge Cache'),
      // CDN -> Load Balancer (cache miss)
      _createConnection(2, 4, label: 'Cache Miss'),
      // Load Balancer -> Caches
      _createConnection(4, 5, label: 'Check Redis'),
      _createConnection(4, 6, label: 'Check Memory'),
      // Caches -> App Server (miss)
      _createConnection(5, 7, label: 'Cache Miss'),
      _createConnection(6, 7, label: 'Cache Miss'),
      // App Server -> Services
      _createConnection(7, 8, label: 'Shorten'),
      _createConnection(7, 9, label: 'Redirect'),
      // Services -> Storage
      _createConnection(8, 11, label: 'Store Mapping'),
      _createConnection(9, 12, label: 'Lookup'),
      // Sync Service keeps caches updated
      _createConnection(13, 5, label: 'Sync'),
      _createConnection(8, 13, label: 'Notify Change'),
    ],
  };

  // ==========================================
  // DESIGN 4: URL Shortener with Analytics
  // ==========================================
  static Map<String, dynamic> get analyticsArchitecture => {
    'name': 'Analytics URL Shortener',
    'description':
        'URL shortener with comprehensive click tracking and analytics',
    'explanation': '''
## Analytics URL Shortener Architecture

### Overview
A URL shortener focused on comprehensive click tracking, providing detailed analytics including geographic data, device info, referrer tracking, and conversion metrics.

### Components

**1. Message Queue**
- Decouples click logging from redirect response
- Ensures no analytics data loss
- Handles traffic spikes gracefully

**2. Stream Processor**
- Real-time event processing
- Enriches click data (geo-IP, device detection)
- Aggregates metrics per time window

**3. Analytics Engine**
- Complex event processing
- Calculates click-through rates
- Identifies traffic patterns and anomalies

**4. Time Series Database**
- Stores time-stamped metrics
- Efficient for range queries
- Used for real-time dashboards

**5. Data Warehouse**
- Long-term analytics storage
- Powers historical reports
- Supports complex SQL queries

**6. Monitoring System**
- Tracks system health
- Alerts on anomalies
- Performance metrics collection

**7. Admin Dashboard**
- View real-time analytics
- Generate custom reports
- Monitor system performance

### Analytics Data Collected
- Click timestamp
- Geographic location (country, city)
- Device type and browser
- Referrer URL
- Unique vs returning visitors
- Click velocity (clicks per minute)

### Data Flow
```
Click Event → Message Queue → Stream Processor
                              ↓
              [Enrich + Aggregate]
                              ↓
         Time Series DB ← → Analytics Engine → Data Warehouse
```

### Icons Explained
**Web Browser** - Users clicking on short URLs from their browser.

**Mobile Client** - Mobile users accessing short links.

**API Gateway** - Entry point that routes all requests.

**Application Server** - Processes requests and coordinates services.

**URL Shortening Service** - Creates new short URLs.

**URL Redirect Service** - Handles redirects and logs click events.

**Message Queue** - Decouples click logging from redirect response to ensure no data loss.

**Stream Processor** - Real-time processing that enriches click data with geo-IP and device info.

**Analytics Engine** - Complex event processing for click-through rates and pattern detection.

**Cache** - Stores frequently accessed URL mappings.

**SQL Database** - Persistent storage for URL data.

**Time Series Database** - Stores time-stamped metrics for real-time dashboards.

**Data Warehouse** - Long-term analytics storage for historical reports.

**Monitoring System** - Tracks system health and performance.

**Metrics Collector** - Gathers metrics from all components.

**Admin User** - Views analytics dashboards and generates reports.

### How They Work Together
1. Users from **Web Browser** or **Mobile Client** click short links
2. **API Gateway** routes to **Application Server**
3. **URL Redirect Service** redirects user and sends click event to **Message Queue**
4. **Stream Processor** enriches event data (location, device, time)
5. Data flows to **Time Series Database** for real-time metrics
6. **Analytics Engine** calculates aggregations and patterns
7. **Data Warehouse** stores processed reports
8. **Admin User** views dashboards via **Metrics Collector**
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 50, 250),
      // Index 1: Mobile Client
      _createIcon('Mobile Client', 'Client & Interface', 50, 400),
      // Index 2: API Gateway
      _createIcon('API Gateway', 'Networking', 200, 325),
      // Index 3: Application Server
      _createIcon('Application Server', 'Servers & Computing', 400, 325),
      // Index 4: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 600, 200),
      // Index 5: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 600, 350),
      // Index 6: Message Queue
      _createIcon('Message Queue', 'Message Systems', 600, 500),
      // Index 7: Stream Processor
      _createIcon('Stream Processor', 'Data Processing', 800, 500),
      // Index 8: Analytics Engine
      _createIcon('Analytics Engine', 'Data Processing', 1000, 500),
      // Index 9: Cache
      _createIcon('Cache', 'Caching,Performance', 800, 200),
      // Index 10: SQL Database
      _createIcon('SQL Database', 'Database & Storage', 800, 350),
      // Index 11: Time Series Database
      _createIcon('Time Series Database', 'Database & Storage', 1000, 350),
      // Index 12: Data Warehouse
      _createIcon('Data Warehouse', 'Database & Storage', 1200, 425),
      // Index 13: Monitoring System
      _createIcon('Monitoring System', 'Security,Monitoring', 1000, 200),
      // Index 14: Metrics Collector
      _createIcon('Metrics Collector', 'Security,Monitoring', 1200, 275),
      // Index 15: Admin User
      _createIcon('Admin User', 'Client & Interface', 1400, 350),
    ],
    'connections': [
      // Clients -> Gateway
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      // Gateway -> App Server
      _createConnection(2, 3, label: 'Route'),
      // App Server -> Services
      _createConnection(3, 4, label: 'Create URL'),
      _createConnection(3, 5, label: 'Redirect'),
      // Services -> Storage
      _createConnection(4, 9, label: 'Cache'),
      _createConnection(4, 10, label: 'Store'),
      _createConnection(5, 9, label: 'Lookup'),
      _createConnection(5, 10, label: 'Lookup'),
      // Click tracking: Redirect -> Message Queue
      _createConnection(5, 6, label: 'Log Click Event'),
      // Message Queue -> Stream Processor
      _createConnection(6, 7, label: 'Process Events'),
      // Stream Processor -> Analytics Engine
      _createConnection(7, 8, label: 'Aggregate'),
      // Stream Processor -> Time Series DB
      _createConnection(7, 11, label: 'Store Metrics'),
      // Analytics Engine -> Data Warehouse
      _createConnection(8, 12, label: 'Store Reports'),
      _createConnection(11, 12, label: 'Archive'),
      // Monitoring flow
      _createConnection(10, 13, label: 'Health Metrics'),
      _createConnection(13, 14, label: 'Collect'),
      // Admin Dashboard
      _createConnection(12, 15, label: 'View Reports'),
    ],
  };

  // ==========================================
  // DESIGN 5: Microservices URL Shortener
  // ==========================================
  static Map<String, dynamic> get microservicesArchitecture => {
    'name': 'Microservices URL Shortener',
    'description': 'Modern microservices architecture with service mesh',
    'explanation': '''
## Microservices URL Shortener Architecture

### Overview
A modern cloud-native architecture decomposing the URL shortener into independent, deployable microservices with a service mesh for communication.

### Components

**1. Service Mesh**
- Handles service-to-service communication
- Provides load balancing, retries, timeouts
- mTLS encryption between services
- Examples: Istio, Linkerd

**2. URL Generator Microservice**
- Dedicated service for creating short URLs
- Owns the URL generation algorithm
- Scales independently based on creation load

**3. URL Resolver Microservice**
- Handles redirect lookups only
- Optimized for read-heavy workloads
- Caches aggressively

**4. Analytics Microservice**
- Processes click events asynchronously
- Owns analytics data storage
- Independent scaling and deployment

**5. Configuration Service**
- Centralized configuration management
- Dynamic config updates without restart
- Feature flags and A/B testing

**6. Individual Databases**
- Each microservice owns its data
- Database-per-service pattern
- No shared database access

**7. Message Queue**
- Async communication between services
- Event-driven architecture
- Enables loose coupling

### Benefits
- Independent deployment and scaling
- Technology diversity (use best tool for each service)
- Fault isolation
- Team autonomy

### Microservice Boundaries
```
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  URL Generator  │ │  URL Resolver   │ │   Analytics     │
│   + KV Store    │ │  + NoSQL DB     │ │ + Time Series   │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         ↓                   ↓                   ↓
               ← Message Queue →
```

### Icons Explained
**Web Browser** - Users accessing the URL shortener through a browser.

**Mobile Client** - Mobile app users.

**CDN** - Caches responses at edge locations.

**API Gateway** - Routes requests to the service mesh.

**Service Mesh** - Handles service-to-service communication with load balancing, retries, and mTLS.

**Microservice** (URL Generator) - Dedicated service for creating short URLs.

**Microservice** (URL Resolver) - Handles redirect lookups only, optimized for reads.

**Microservice** (Analytics) - Processes click events asynchronously.

**URL Shortening Service** - The logic layer within the generator microservice.

**URL Redirect Service** - The logic layer within the resolver microservice.

**Analytics Service** - The logic layer within the analytics microservice.

**Key-Value Store** - Database owned by the URL Generator microservice.

**NoSQL Database** - Database owned by the URL Resolver microservice.

**Time Series Database** - Database owned by the Analytics microservice.

**Message Queue** - Enables async communication between microservices.

**Configuration Service** - Centralized config management with feature flags.

**Monitoring System** - Observes all microservices for health and metrics.

### How They Work Together
1. Users from **Web Browser** or **Mobile Client** send requests
2. **CDN** caches responses, forwards to **API Gateway**
3. **API Gateway** sends to **Service Mesh** for routing
4. **Service Mesh** routes to appropriate **Microservice**
5. Each microservice uses its own database (**Key-Value Store**, **NoSQL Database**, **Time Series Database**)
6. **Message Queue** enables async events between services
7. **Configuration Service** provides settings to all microservices
8. **Monitoring System** collects metrics from all services
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 50, 300),
      // Index 1: Mobile Client
      _createIcon('Mobile Client', 'Client & Interface', 50, 450),
      // Index 2: CDN
      _createIcon('CDN', 'Networking', 200, 375),
      // Index 3: API Gateway
      _createIcon('API Gateway', 'Networking', 350, 375),
      // Index 4: Service Mesh
      _createIcon('Service Mesh', 'System Utilities', 500, 375),
      // Index 5: URL Generator Microservice
      _createIcon(
        'Microservice',
        'Servers & Computing',
        650,
        200,
        id: 'URL Generator',
      ),
      // Index 6: URL Resolver Microservice
      _createIcon(
        'Microservice',
        'Servers & Computing',
        650,
        375,
        id: 'URL Resolver',
      ),
      // Index 7: Analytics Microservice
      _createIcon(
        'Microservice',
        'Servers & Computing',
        650,
        550,
        id: 'Analytics MS',
      ),
      // Index 8: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 850, 200),
      // Index 9: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 850, 375),
      // Index 10: Analytics Service
      _createIcon('Analytics Service', 'Security,Monitoring', 850, 550),
      // Index 11: Key-Value Store (for Generator)
      _createIcon('Key-Value Store', 'Database & Storage', 1050, 200),
      // Index 12: NoSQL Database (for Resolver)
      _createIcon('NoSQL Database', 'Database & Storage', 1050, 375),
      // Index 13: Time Series Database (for Analytics)
      _createIcon('Time Series Database', 'Database & Storage', 1050, 550),
      // Index 14: Message Queue
      _createIcon('Message Queue', 'Message Systems', 750, 700),
      // Index 15: Configuration Service
      _createIcon('Configuration Service', 'System Utilities', 500, 150),
      // Index 16: Monitoring System
      _createIcon('Monitoring System', 'Security,Monitoring', 500, 600),
    ],
    'connections': [
      // Clients -> CDN
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      // CDN -> API Gateway
      _createConnection(2, 3, label: 'Forward'),
      // API Gateway -> Service Mesh
      _createConnection(3, 4, label: 'Route'),
      // Service Mesh -> Microservices
      _createConnection(4, 5, label: 'Create URL'),
      _createConnection(4, 6, label: 'Resolve URL'),
      _createConnection(4, 7, label: 'Track'),
      // Microservices -> Service Logic
      _createConnection(5, 8, label: 'Generate'),
      _createConnection(6, 9, label: 'Redirect'),
      _createConnection(7, 10, label: 'Analyze'),
      // Services -> Individual Databases
      _createConnection(8, 11, label: 'Store Mapping'),
      _createConnection(9, 12, label: 'Lookup'),
      _createConnection(10, 13, label: 'Store Metrics'),
      // Async communication via Message Queue
      _createConnection(6, 14, label: 'Publish Click'),
      _createConnection(14, 7, label: 'Consume Event'),
      // Config Service feeds all microservices
      _createConnection(15, 5, label: 'Config'),
      _createConnection(15, 6, label: 'Config'),
      _createConnection(15, 7, label: 'Config'),
      // Monitoring observes all
      _createConnection(5, 16, label: 'Metrics'),
      _createConnection(6, 16, label: 'Metrics'),
      _createConnection(7, 16, label: 'Metrics'),
    ],
  };

  // ==========================================
  // DESIGN 6: High Availability URL Shortener
  // ==========================================
  static Map<String, dynamic> get highAvailabilityArchitecture => {
    'name': 'High Availability URL Shortener',
    'description': 'Multi-region deployment with failover and replication',
    'explanation': '''
## High Availability URL Shortener Architecture

### Overview
A fault-tolerant, multi-region deployment designed for 99.99% uptime with automatic failover and data replication across geographic regions.

### Components

**1. DNS Server (GeoDNS)**
- Routes users to nearest region
- Health-aware DNS resolution
- Automatic failover at DNS level

**2. Global Load Balancer**
- Active-active or active-passive setup
- Cross-region health monitoring
- Intelligent traffic routing

**3. Multi-Region Setup (Region 1 & 2)**
- Each region is self-sufficient
- Complete stack in each region
- Can handle full traffic if other fails

**4. Regional Server Clusters**
- Multiple clusters per region
- N+1 redundancy within region
- No single point of failure

**5. Sync Service**
- Cross-region data replication
- Conflict resolution for writes
- Sub-second replication lag

**6. Backup Service**
- Regular snapshots to cold storage
- Point-in-time recovery capability
- Geo-redundant backup storage

**7. Monitoring & Alert System**
- 24/7 health monitoring
- Automated incident response
- Pager alerts for critical issues

### Availability Calculation
```
Single Server: 99.9% (8.76 hours downtime/year)
With Failover: 99.99% (52.56 minutes/year)
Multi-Region: 99.999% (5.26 minutes/year)
```

### Failover Scenarios
1. **Server Failure** → Load balancer routes away
2. **Region Failure** → DNS failover to other region
3. **Database Failure** → Automatic replica promotion
4. **Network Partition** → Each region operates independently

### Icons Explained
**User** - End users accessing the URL shortener service.

**DNS Server** - GeoDNS that routes users to the nearest region with health-aware resolution.

**Global Load Balancer** - Distributes traffic across regions with health monitoring.

**Geographic Region** (Region 1 & 2) - Self-sufficient regions with complete stacks.

**Load Balancer** (LB 1 & 2) - Regional load balancers distributing traffic within each region.

**Server Cluster** (4 instances) - Multiple clusters per region for N+1 redundancy.

**Redis Cache** (2 instances) - Regional caches for fast lookups.

**SQL Database** (DB 1 & 2) - Regional databases with replication.

**Sync Service** - Cross-region data replication with conflict resolution.

**Backup Service** - Regular snapshots to geo-redundant cold storage.

**Monitoring System** - 24/7 health monitoring across all regions.

**Alert System** - Pager alerts for critical issues and failover triggers.

### How They Work Together
1. **User** makes DNS request to **DNS Server**
2. **DNS Server** resolves to **Global Load Balancer**
3. **Global Load Balancer** routes to nearest **Geographic Region**
4. Regional **Load Balancer** distributes across **Server Clusters**
5. Clusters use **Redis Cache** for fast lookups, **SQL Database** for persistence
6. **Sync Service** replicates data between Region 1 and Region 2
7. **Backup Service** creates periodic snapshots
8. **Monitoring System** watches health, **Alert System** triggers failover if needed
''',
    'icons': [
      // Index 0: User
      _createIcon('User', 'Client & Interface', 50, 400),
      // Index 1: DNS Server
      _createIcon('DNS Server', 'Networking', 200, 400),
      // Index 2: Global Load Balancer
      _createIcon('Global Load Balancer', 'Networking', 350, 400),
      // Index 3: Region 1
      _createIcon(
        'Geographic Region',
        'Cloud,Infrastructure',
        550,
        200,
        id: 'Region 1',
      ),
      // Index 4: Region 1 Load Balancer
      _createIcon('Load Balancer', 'Networking', 550, 300, id: 'LB 1'),
      // Index 5: Region 1 Server Cluster 1
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        700,
        250,
        id: 'Cluster 1A',
      ),
      // Index 6: Region 1 Server Cluster 2
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        700,
        350,
        id: 'Cluster 1B',
      ),
      // Index 7: Region 1 Redis Cache
      _createIcon(
        'Redis Cache',
        'Caching,Performance',
        850,
        250,
        id: 'Cache 1',
      ),
      // Index 8: Region 1 SQL Database
      _createIcon('SQL Database', 'Database & Storage', 850, 350, id: 'DB 1'),
      // Index 9: Region 2
      _createIcon(
        'Geographic Region',
        'Cloud,Infrastructure',
        550,
        500,
        id: 'Region 2',
      ),
      // Index 10: Region 2 Load Balancer
      _createIcon('Load Balancer', 'Networking', 550, 600, id: 'LB 2'),
      // Index 11: Region 2 Server Cluster 1
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        700,
        550,
        id: 'Cluster 2A',
      ),
      // Index 12: Region 2 Server Cluster 2
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        700,
        650,
        id: 'Cluster 2B',
      ),
      // Index 13: Region 2 Redis Cache
      _createIcon(
        'Redis Cache',
        'Caching,Performance',
        850,
        550,
        id: 'Cache 2',
      ),
      // Index 14: Region 2 SQL Database
      _createIcon('SQL Database', 'Database & Storage', 850, 650, id: 'DB 2'),
      // Index 15: Sync Service (Cross-region replication)
      _createIcon('Sync Service', 'Cloud,Infrastructure', 1050, 400),
      // Index 16: Backup Service
      _createIcon('Backup Service', 'Cloud,Infrastructure', 1200, 400),
      // Index 17: Monitoring System
      _createIcon('Monitoring System', 'Security,Monitoring', 350, 600),
      // Index 18: Alert System
      _createIcon('Alert System', 'Security,Monitoring', 350, 200),
    ],
    'connections': [
      // User -> DNS
      _createConnection(0, 1, label: 'DNS Lookup'),
      // DNS -> Global Load Balancer
      _createConnection(1, 2, label: 'Resolve'),
      // Global LB -> Regional LBs
      _createConnection(2, 4, label: 'Route to Region 1'),
      _createConnection(2, 10, label: 'Route to Region 2'),
      // Region 1 internal
      _createConnection(4, 5, label: 'Balance'),
      _createConnection(4, 6, label: 'Balance'),
      _createConnection(5, 7, label: 'Cache Lookup'),
      _createConnection(5, 8, label: 'DB Query'),
      _createConnection(6, 7, label: 'Cache Lookup'),
      _createConnection(6, 8, label: 'DB Query'),
      // Region 2 internal
      _createConnection(10, 11, label: 'Balance'),
      _createConnection(10, 12, label: 'Balance'),
      _createConnection(11, 13, label: 'Cache Lookup'),
      _createConnection(11, 14, label: 'DB Query'),
      _createConnection(12, 13, label: 'Cache Lookup'),
      _createConnection(12, 14, label: 'DB Query'),
      // Cross-region replication
      _createConnection(8, 15, label: 'Replicate'),
      _createConnection(14, 15, label: 'Replicate'),
      _createConnection(7, 15, label: 'Sync Cache'),
      _createConnection(13, 15, label: 'Sync Cache'),
      // Backup
      _createConnection(15, 16, label: 'Backup'),
      // Monitoring
      _createConnection(4, 17, label: 'Health'),
      _createConnection(10, 17, label: 'Health'),
      _createConnection(18, 4, label: 'Failover Alert'),
      _createConnection(18, 10, label: 'Failover Alert'),
    ],
  };

  // ==========================================
  // DESIGN 7: Secure URL Shortener
  // ==========================================
  static Map<String, dynamic> get secureArchitecture => {
    'name': 'Secure URL Shortener',
    'description':
        'Enterprise-grade security with authentication and fraud detection',
    'explanation': '''
## Secure URL Shortener Architecture

### Overview
An enterprise-grade security-focused architecture with multiple layers of protection against malicious URLs, abuse, and unauthorized access.

### Components

**1. Firewall (WAF)**
- Filters malicious traffic
- Blocks known attack patterns
- IP reputation checking
- DDoS mitigation

**2. Security Gateway**
- SSL/TLS termination
- Request inspection
- Blocks suspicious payloads

**3. Rate Limiter**
- Prevents brute force attacks
- Per-IP and per-user limits
- Adaptive rate limiting

**4. Authentication Service**
- JWT/OAuth token validation
- API key management
- Session management

**5. Authorization Service**
- Role-based access control (RBAC)
- Permission checking
- Admin vs regular user separation

**6. Fraud Detection**
- ML-based abuse detection
- Identifies spam campaigns
- Blocks phishing URL creation

**7. Security Scanner**
- Scans destination URLs for malware
- Google Safe Browsing API integration
- Phishing detection

**8. Logging Service**
- Comprehensive audit trail
- Security event logging
- Forensic investigation support

### Security Layers
```
[User] → [Firewall] → [Security Gateway] → [Rate Limiter]
                                              ↓
         [Authentication] → [Authorization] → [API Gateway]
                                              ↓
[Fraud Detection] ← [App Server] → [Security Scanner]
                         ↓
              [Logging Service]
```

### Security Features
- All traffic encrypted (TLS 1.3)
- No URL enumeration (random codes)
- Malicious URL blocking
- Abuse rate limiting
- Complete audit logging

### Icons Explained
**User** - Regular users creating or clicking short URLs.

**Admin User** - Administrators with elevated access to manage the system.

**Firewall** - Web Application Firewall that filters malicious traffic and blocks attacks.

**Security Gateway** - SSL/TLS termination and request inspection layer.

**Rate Limiter** - Prevents brute force attacks with per-IP and per-user limits.

**Authentication** - Validates JWT/OAuth tokens and manages API keys.

**Authorization** - Role-based access control checking permissions.

**API Gateway** - Routes authenticated requests to backend services.

**Application Server** - Core business logic processing.

**Fraud Detection** - ML-based detection of spam campaigns and abuse.

**Security Scanner** - Scans destination URLs for malware and phishing.

**URL Shortening Service** - Creates short URLs after security validation.

**SQL Database** - Stores URL mappings and security logs.

**Logging Service** - Comprehensive audit trail for forensic investigation.

**Monitoring System** - Tracks system health and security events.

**Alert System** - Triggers alerts on security anomalies.

### How They Work Together
1. **User** or **Admin User** sends request through **Firewall**
2. **Firewall** filters malicious traffic, **Rate Limiter** checks limits
3. **Security Gateway** inspects request, **Authentication** validates identity
4. **Authorization** checks permissions, **API Gateway** routes request
5. **Application Server** coordinates with **Fraud Detection** and **Security Scanner**
6. Only clean, safe URLs go to **URL Shortening Service**
7. **Logging Service** records all actions for audit
8. **Monitoring System** watches for anomalies, **Alert System** notifies on issues
''',
    'icons': [
      // Index 0: User
      _createIcon('User', 'Client & Interface', 50, 350),
      // Index 1: Admin User
      _createIcon('Admin User', 'Client & Interface', 50, 500),
      // Index 2: Firewall
      _createIcon('Firewall', 'Security,Monitoring', 200, 425),
      // Index 3: Security Gateway
      _createIcon('Security Gateway', 'Security,Monitoring', 350, 350),
      // Index 4: Rate Limiter
      _createIcon('Rate Limiter', 'Networking', 350, 500),
      // Index 5: Authentication
      _createIcon('Authentication', 'Security,Monitoring', 500, 300),
      // Index 6: Authorization
      _createIcon('Authorization', 'Security,Monitoring', 500, 450),
      // Index 7: API Gateway
      _createIcon('API Gateway', 'Networking', 650, 375),
      // Index 8: Application Server
      _createIcon('Application Server', 'Servers & Computing', 800, 375),
      // Index 9: Fraud Detection
      _createIcon('Fraud Detection', 'Security,Monitoring', 950, 250),
      // Index 10: Security Scanner
      _createIcon('Security Scanner', 'Security,Monitoring', 950, 500),
      // Index 11: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 950, 375),
      // Index 12: SQL Database
      _createIcon('SQL Database', 'Database & Storage', 1150, 375),
      // Index 13: Logging Service
      _createIcon('Logging Service', 'Security,Monitoring', 1150, 250),
      // Index 14: Monitoring System
      _createIcon('Monitoring System', 'Security,Monitoring', 650, 550),
      // Index 15: Alert System
      _createIcon('Alert System', 'Security,Monitoring', 800, 550),
    ],
    'connections': [
      // Users -> Firewall
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Admin Request'),
      // Firewall -> Security Layer
      _createConnection(2, 3, label: 'Filter'),
      _createConnection(2, 4, label: 'Rate Check'),
      // Security Gateway -> Auth
      _createConnection(3, 5, label: 'Authenticate'),
      _createConnection(4, 6, label: 'Authorize'),
      // Auth -> API Gateway
      _createConnection(5, 7, label: 'Token Valid'),
      _createConnection(6, 7, label: 'Authorized'),
      // API Gateway -> App Server
      _createConnection(7, 8, label: 'Forward'),
      // App Server -> Security Services
      _createConnection(8, 9, label: 'Check Fraud'),
      _createConnection(8, 10, label: 'Scan URL'),
      _createConnection(8, 11, label: 'Process'),
      // Fraud Detection result
      _createConnection(9, 11, label: 'Safe'),
      // Security Scanner result
      _createConnection(10, 11, label: 'Clean'),
      // Service -> Storage
      _createConnection(11, 12, label: 'Store'),
      // Logging
      _createConnection(9, 13, label: 'Log Fraud Attempt'),
      _createConnection(10, 13, label: 'Log Scan Result'),
      _createConnection(11, 13, label: 'Audit Log'),
      // Monitoring
      _createConnection(7, 14, label: 'Metrics'),
      _createConnection(14, 15, label: 'Trigger Alert'),
    ],
  };

  // ==========================================
  // DESIGN 8: Serverless URL Shortener
  // ==========================================
  static Map<String, dynamic> get serverlessArchitecture => {
    'name': 'Serverless URL Shortener',
    'description': 'Cloud-native serverless URL shortener with auto-scaling',
    'explanation': '''
## Serverless URL Shortener Architecture

### Overview
A cloud-native, pay-per-use architecture using serverless functions (Lambda, Cloud Functions) with automatic scaling from zero to millions of requests.

### Components

**1. Cloud Functions**
- **Create Function**: Generates short URLs
- **Redirect Function**: Handles URL lookups
- **Analytics Function**: Processes click events
- Auto-scales from 0 to 1000s of instances

**2. API Gateway (Managed)**
- Fully managed by cloud provider
- Routes requests to appropriate functions
- Built-in rate limiting and caching

**3. Cloud Database**
- Serverless database (DynamoDB, Firestore)
- Pay-per-request pricing
- Automatic scaling and replication

**4. Cloud Storage**
- Object storage for static assets
- Can store analytics data as files
- Extremely low cost

**5. Event Stream**
- Kinesis, Pub/Sub, or EventBridge
- Triggers analytics processing
- Decouples redirect from analytics

**6. Auto-scaling Group**
- Managed by cloud provider
- Scales to zero when idle
- Handles traffic spikes instantly

### Cost Model
```
Traditional: ~500/month (24/7 servers)
Serverless:  ~5/month (pay-per-use)
           + Per request: ~0.0000002
           + Per GB data: ~0.09
```

### Benefits
- Zero infrastructure management
- Pay only for actual usage
- Infinite scalability
- Built-in high availability
- Fast deployment (seconds)

### Limitations
- Cold start latency (100-500ms first request)
- Execution time limits (15 min max)
- Vendor lock-in considerations

### Icons Explained
**Web Browser** - Users accessing the service through their browser.

**Mobile Client** - Mobile app users.

**CDN** - Caches responses at edge locations globally.

**API Gateway** - Managed API gateway that routes to serverless functions.

**Cloud Service** (Create Function) - Serverless function for generating short URLs.

**Cloud Service** (Redirect Function) - Serverless function for handling redirects.

**Cloud Service** (Analytics Function) - Serverless function for processing clicks.

**URL Shortening Service** - The logic layer within the create function.

**URL Redirect Service** - The logic layer within the redirect function.

**Analytics Service** - The logic layer within the analytics function.

**Cloud Database** - Serverless database (like DynamoDB) with pay-per-request pricing.

**Cloud Storage** - Object storage for static assets and data files.

**Event Stream** - Managed event streaming (Kinesis/Pub-Sub) triggering analytics.

**Stream Processor** - Processes click events from the event stream.

**Auto-scaling Group** - Cloud-managed scaling that scales functions from 0 to 1000s.

**Monitoring System** - Tracks function invocations, latency, and errors.

### How They Work Together
1. Users from **Web Browser** or **Mobile Client** send requests
2. **CDN** caches responses, forwards to **API Gateway**
3. **API Gateway** invokes appropriate **Cloud Service** (function)
4. Functions execute **URL Shortening Service**, **URL Redirect Service**, or **Analytics Service**
5. Services use **Cloud Database** and **Cloud Storage** for data
6. **Event Stream** receives click events, triggers **Stream Processor**
7. **Auto-scaling Group** manages function scaling automatically
8. **Monitoring System** tracks all function metrics
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      // Index 1: Mobile Client
      _createIcon('Mobile Client', 'Client & Interface', 50, 500),
      // Index 2: CDN
      _createIcon('CDN', 'Networking', 200, 425),
      // Index 3: API Gateway (managed)
      _createIcon('API Gateway', 'Networking', 350, 425),
      // Index 4: Cloud Service (URL Creator Function)
      _createIcon(
        'Cloud Service',
        'Cloud,Infrastructure',
        500,
        300,
        id: 'Create Function',
      ),
      // Index 5: Cloud Service (Redirect Function)
      _createIcon(
        'Cloud Service',
        'Cloud,Infrastructure',
        500,
        425,
        id: 'Redirect Function',
      ),
      // Index 6: Cloud Service (Analytics Function)
      _createIcon(
        'Cloud Service',
        'Cloud,Infrastructure',
        500,
        550,
        id: 'Analytics Function',
      ),
      // Index 7: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 700, 300),
      // Index 8: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 700, 425),
      // Index 9: Analytics Service
      _createIcon('Analytics Service', 'Security,Monitoring', 700, 550),
      // Index 10: Cloud Database
      _createIcon('Cloud Database', 'Cloud,Infrastructure', 900, 300),
      // Index 11: Cloud Storage
      _createIcon('Cloud Storage', 'Cloud,Infrastructure', 900, 425),
      // Index 12: Event Stream
      _createIcon('Event Stream', 'Message Systems', 700, 700),
      // Index 13: Stream Processor
      _createIcon('Stream Processor', 'Data Processing', 900, 700),
      // Index 14: Auto-scaling Group
      _createIcon('Auto-scaling Group', 'System Utilities', 550, 150),
      // Index 15: Monitoring System
      _createIcon('Monitoring System', 'Security,Monitoring', 1100, 425),
    ],
    'connections': [
      // Clients -> CDN
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      // CDN -> API Gateway
      _createConnection(2, 3, label: 'Forward'),
      // API Gateway -> Cloud Functions
      _createConnection(3, 4, label: 'Invoke Create'),
      _createConnection(3, 5, label: 'Invoke Redirect'),
      _createConnection(3, 6, label: 'Invoke Analytics'),
      // Cloud Functions -> Services
      _createConnection(4, 7, label: 'Generate URL'),
      _createConnection(5, 8, label: 'Resolve URL'),
      _createConnection(6, 9, label: 'Process'),
      // Services -> Cloud Storage
      _createConnection(7, 10, label: 'Store'),
      _createConnection(8, 11, label: 'Lookup'),
      _createConnection(8, 10, label: 'Read'),
      // Event Stream for analytics
      _createConnection(8, 12, label: 'Publish Click'),
      _createConnection(12, 13, label: 'Process Stream'),
      _createConnection(13, 9, label: 'Send to Analytics'),
      // Auto-scaling manages functions
      _createConnection(14, 4, label: 'Scale'),
      _createConnection(14, 5, label: 'Scale'),
      _createConnection(14, 6, label: 'Scale'),
      // Monitoring
      _createConnection(10, 15, label: 'Metrics'),
      _createConnection(11, 15, label: 'Metrics'),
    ],
  };

  // ==========================================
  // DESIGN 9: URL Shortener with Expiration
  // ==========================================
  static Map<String, dynamic> get expirationArchitecture => {
    'name': 'Expiring URL Shortener',
    'description': 'URL shortener with time-to-live and automatic expiration',
    'explanation': '''
## Expiring URL Shortener Architecture

### Overview
A URL shortener with built-in expiration support, allowing users to create time-limited URLs with automatic cleanup and optional expiry notifications.

### Components

**1. Expiration Service**
- Checks if URLs have expired
- Returns 410 Gone for expired URLs
- Manages TTL (Time-To-Live) values

**2. Scheduler**
- Cron-based job scheduler
- Triggers cleanup at regular intervals
- Processes expiring URL notifications

**3. Redis Cache (with TTL)**
- Native TTL support in Redis
- Auto-evicts expired entries
- SETEX command for atomic set with expiry

**4. Message Queue**
- Queues cleanup jobs
- Handles bulk deletion tasks
- Ensures reliable processing

**5. Batch Processor**
- Processes expired URLs in batches
- Efficient bulk database operations
- Runs during off-peak hours

**6. Notification Service**
- Sends expiry warnings
- Reminds users before URL expires
- Offers renewal options

**7. Email Service**
- Delivers expiry notifications
- Sends renewal confirmations
- Links to extend URL lifetime

### Expiration Flow
```
1. URL Created with TTL (e.g., 7 days)
2. Stored in Redis (TTL) + Database (expires_at)
3. Day 6: Notification sent to owner
4. Day 7: Scheduler marks as expired
5. Day 8: Batch processor deletes from DB
6. Click on expired: 410 Gone response
```

### TTL Options
- 1 hour (temporary sharing)
- 24 hours (daily links)
- 7 days (weekly campaigns)
- 30 days (monthly)
- Custom (premium feature)
- Never (default, costs more)

### Icons Explained
**Web Browser** - Users creating or clicking short URLs with expiration.

**API Gateway** - Entry point for all requests.

**Application Server** - Processes requests and coordinates services.

**URL Shortening Service** - Creates short URLs with specified TTL values.

**URL Redirect Service** - Handles redirects and checks expiration status.

**Expiration Service** - Checks if URLs have expired, returns 410 Gone for expired ones.

**Scheduler** - Cron-based job scheduler that triggers cleanup at regular intervals.

**Redis Cache** - Cache with native TTL support that auto-evicts expired entries.

**SQL Database** - Stores URL mappings with expires_at timestamp.

**Message Queue** - Queues cleanup jobs for reliable batch processing.

**Batch Processor** - Processes expired URLs in batches during off-peak hours.

**Notification Service** - Sends expiry warnings before URLs expire.

**Email Service** - Delivers expiry notifications and renewal options to users.

### How They Work Together
1. **Web Browser** user creates URL with TTL (e.g., 7 days)
2. **API Gateway** routes to **Application Server**
3. **URL Shortening Service** stores in **Redis Cache** (with TTL) and **SQL Database** (with expires_at)
4. **Scheduler** periodically triggers **Expiration Service**
5. **Expiration Service** finds expiring URLs, sends to **Notification Service**
6. **Notification Service** uses **Email Service** to warn owners
7. Expired URLs queued in **Message Queue** for **Batch Processor**
8. **Batch Processor** deletes expired entries from **SQL Database**
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      // Index 1: API Gateway
      _createIcon('API Gateway', 'Networking', 200, 350),
      // Index 2: Application Server
      _createIcon('Application Server', 'Servers & Computing', 400, 350),
      // Index 3: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 600, 250),
      // Index 4: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 600, 350),
      // Index 5: Expiration Service
      _createIcon('Expiration Service', 'Application Services', 600, 450),
      // Index 6: Scheduler
      _createIcon('Scheduler', 'System Utilities', 600, 600),
      // Index 7: Redis Cache (with TTL)
      _createIcon('Redis Cache', 'Caching,Performance', 800, 250),
      // Index 8: SQL Database
      _createIcon('SQL Database', 'Database & Storage', 800, 350),
      // Index 9: Message Queue (cleanup jobs)
      _createIcon('Message Queue', 'Message Systems', 800, 500),
      // Index 10: Batch Processor
      _createIcon('Batch Processor', 'Data Processing', 1000, 500),
      // Index 11: Notification Service
      _createIcon('Notification Service', 'Message Systems', 1000, 350),
      // Index 12: Email Service
      _createIcon('Email Service', 'Message Systems', 1150, 350),
    ],
    'connections': [
      // Client -> Gateway
      _createConnection(0, 1, label: 'Request'),
      // Gateway -> App Server
      _createConnection(1, 2, label: 'Route'),
      // App Server -> Services
      _createConnection(2, 3, label: 'Create URL'),
      _createConnection(2, 4, label: 'Redirect'),
      _createConnection(2, 5, label: 'Check Expiry'),
      // Services -> Cache/DB
      _createConnection(3, 7, label: 'Cache with TTL'),
      _createConnection(3, 8, label: 'Store with Expiry'),
      _createConnection(4, 7, label: 'Lookup Cache'),
      _createConnection(4, 8, label: 'Lookup DB'),
      // Scheduler triggers Expiration Service
      _createConnection(6, 5, label: 'Trigger Cleanup'),
      // Expiration Service -> Message Queue
      _createConnection(5, 9, label: 'Queue Expired URLs'),
      // Message Queue -> Batch Processor
      _createConnection(9, 10, label: 'Process Batch'),
      // Batch Processor cleans up DB
      _createConnection(10, 8, label: 'Delete Expired'),
      // Notification flow for expiring URLs
      _createConnection(5, 11, label: 'Expiry Warning'),
      _createConnection(11, 12, label: 'Send Email'),
    ],
  };

  // ==========================================
  // DESIGN 10: Complete URL Shortener System
  // ==========================================
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete URL Shortener System',
    'description': 'Enterprise-grade URL shortener with all major components',
    'explanation': '''
## Complete URL Shortener System Architecture

### Overview
An enterprise-grade, production-ready URL shortener combining all best practices: scalability, security, caching, analytics, and high availability.

### Components

**1. Client Layer**
- Web Browser, Mobile App, Third-party API
- Multiple access patterns supported
- SDK libraries for easy integration

**2. Edge Layer**
- DNS for discovery
- CDN for caching and edge delivery
- Global presence

**3. Security Layer**
- Firewall (WAF) for attack prevention
- Rate Limiter for abuse protection
- Authentication for user identity

**4. Routing Layer**
- API Gateway for request routing
- Load Balancer for traffic distribution
- Health checks and failover

**5. Compute Layer**
- Multiple Server Clusters (redundancy)
- Stateless application servers
- Auto-scaling groups

**6. Service Layer**
- URL Shortening Service (create)
- URL Redirect Service (resolve)
- Expiration Service (cleanup)

**7. Caching Layer**
- Redis Cache (distributed)
- In-Memory Cache (local)
- Multi-tier cache strategy

**8. Storage Layer**
- SQL Database (transactions)
- NoSQL Database (fast reads)
- Write to SQL, read from NoSQL

**9. Analytics Pipeline**
- Message Queue → Stream Processor
- Analytics Engine → Data Warehouse
- Real-time and batch processing

**10. Operations Layer**
- Monitoring System
- Logging Service
- Alert System
- Admin Dashboard

### Architecture Diagram Summary
```
[Clients] → [CDN/DNS] → [Security] → [API GW] → [Load Balancer]
                                                       ↓
                                              [Server Clusters]
                                                       ↓
                                              [Services Layer]
                                                       ↓
                              [Cache Layer] ←→ [Database Layer]
                                                       ↓
                                            [Analytics Pipeline]
                                                       ↓
                                              [Admin Dashboard]
```

### Key Metrics Target
- Latency: <50ms p99 for redirects
- Availability: 99.99% uptime
- Throughput: 100K+ requests/second
- Storage: Billions of URL mappings

### Icons Explained
**Web Browser** - Desktop users accessing the URL shortener.

**Mobile Client** - Mobile app users.

**Third Party API** - External applications integrating via API.

**CDN** - Content Delivery Network for edge caching.

**DNS Server** - Resolves domain names to IP addresses.

**Firewall** - Web Application Firewall for attack prevention.

**Rate Limiter** - Abuse protection limiting request frequency.

**API Gateway** - Central request routing.

**Authentication** - Validates user identity and tokens.

**Load Balancer** - Distributes traffic across server clusters.

**Server Cluster** (2 instances) - Application servers for redundancy.

**URL Shortening Service** - Creates new short URLs.

**URL Redirect Service** - Handles URL lookups and redirects.

**Expiration Service** - Manages URL lifecycle and cleanup.

**Redis Cache** - Distributed cache layer.

**In-Memory Cache** - Local hot cache for fastest lookups.

**SQL Database** - Transactional storage for writes.

**NoSQL Database** - Fast reads for URL lookups.

**Message Queue** - Queues click events for analytics.

**Stream Processor** - Real-time event processing.

**Analytics Engine** - Aggregates metrics and patterns.

**Data Warehouse** - Long-term analytics storage.

**Monitoring System** - Tracks system health.

**Logging Service** - Records all system events.

**Alert System** - Notifies on issues.

**Admin User** - Views dashboards and manages the system.

### How They Work Together
1. Users from **Web Browser**, **Mobile Client**, or **Third Party API** request
2. **DNS Server** resolves, **CDN** caches at edge
3. **Firewall** filters attacks, **Rate Limiter** checks limits
4. **Authentication** validates, **API Gateway** routes to **Load Balancer**
5. **Load Balancer** distributes to **Server Clusters**
6. Services (**URL Shortening Service**, **URL Redirect Service**, **Expiration Service**) process
7. **Redis Cache** and **In-Memory Cache** provide fast lookups
8. **SQL Database** handles writes, **NoSQL Database** handles reads
9. **Message Queue** → **Stream Processor** → **Analytics Engine** → **Data Warehouse**
10. **Monitoring System** and **Logging Service** track everything
11. **Admin User** views reports via **Data Warehouse**
''',
    'icons': [
      // Index 0: Web Browser
      _createIcon('Web Browser', 'Client & Interface', 50, 200),
      // Index 1: Mobile Client
      _createIcon('Mobile Client', 'Client & Interface', 50, 350),
      // Index 2: Third Party API
      _createIcon('Third Party API', 'External Services', 50, 500),
      // Index 3: CDN
      _createIcon('CDN', 'Networking', 200, 350),
      // Index 4: DNS Server
      _createIcon('DNS Server', 'Networking', 200, 200),
      // Index 5: Firewall
      _createIcon('Firewall', 'Security,Monitoring', 350, 275),
      // Index 6: Rate Limiter
      _createIcon('Rate Limiter', 'Networking', 350, 425),
      // Index 7: API Gateway
      _createIcon('API Gateway', 'Networking', 500, 350),
      // Index 8: Authentication
      _createIcon('Authentication', 'Security,Monitoring', 500, 200),
      // Index 9: Load Balancer
      _createIcon('Load Balancer', 'Networking', 650, 350),
      // Index 10: Server Cluster 1
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        800,
        250,
        id: 'App Server 1',
      ),
      // Index 11: Server Cluster 2
      _createIcon(
        'Server Cluster',
        'Servers & Computing',
        800,
        450,
        id: 'App Server 2',
      ),
      // Index 12: URL Shortening Service
      _createIcon('URL Shortening Service', 'Application Services', 1000, 200),
      // Index 13: URL Redirect Service
      _createIcon('URL Redirect Service', 'Application Services', 1000, 350),
      // Index 14: Expiration Service
      _createIcon('Expiration Service', 'Application Services', 1000, 500),
      // Index 15: Redis Cache
      _createIcon('Redis Cache', 'Caching,Performance', 1150, 250),
      // Index 16: In-Memory Cache
      _createIcon('In-Memory Cache', 'Caching,Performance', 1150, 400),
      // Index 17: SQL Database
      _createIcon('SQL Database', 'Database & Storage', 1350, 300),
      // Index 18: NoSQL Database
      _createIcon('NoSQL Database', 'Database & Storage', 1350, 450),
      // Index 19: Message Queue
      _createIcon('Message Queue', 'Message Systems', 1000, 650),
      // Index 20: Stream Processor
      _createIcon('Stream Processor', 'Data Processing', 1150, 650),
      // Index 21: Analytics Engine
      _createIcon('Analytics Engine', 'Data Processing', 1300, 650),
      // Index 22: Data Warehouse
      _createIcon('Data Warehouse', 'Database & Storage', 1450, 650),
      // Index 23: Monitoring System
      _createIcon('Monitoring System', 'Security,Monitoring', 650, 550),
      // Index 24: Logging Service
      _createIcon('Logging Service', 'Security,Monitoring', 650, 700),
      // Index 25: Alert System
      _createIcon('Alert System', 'Security,Monitoring', 800, 650),
      // Index 26: Admin User
      _createIcon('Admin User', 'Client & Interface', 1550, 350),
    ],
    'connections': [
      // Clients -> DNS -> CDN
      _createConnection(0, 4, label: 'DNS Lookup'),
      _createConnection(4, 3, label: 'Resolve'),
      _createConnection(1, 3, label: 'Request'),
      _createConnection(2, 3, label: 'API Call'),
      // CDN -> Security Layer
      _createConnection(3, 5, label: 'Forward'),
      _createConnection(3, 6, label: 'Check Rate'),
      // Security -> API Gateway
      _createConnection(5, 7, label: 'Allowed'),
      _createConnection(6, 7, label: 'Not Limited'),
      // Authentication -> API Gateway
      _createConnection(8, 7, label: 'Token Valid'),
      // API Gateway -> Load Balancer
      _createConnection(7, 9, label: 'Route'),
      // Load Balancer -> Server Clusters
      _createConnection(9, 10, label: 'Balance'),
      _createConnection(9, 11, label: 'Balance'),
      // Server Clusters -> Services
      _createConnection(10, 12, label: 'Create URL'),
      _createConnection(10, 13, label: 'Redirect'),
      _createConnection(11, 13, label: 'Redirect'),
      _createConnection(11, 14, label: 'Check Expiry'),
      // Services -> Cache Layer
      _createConnection(12, 15, label: 'Cache'),
      _createConnection(13, 15, label: 'Lookup'),
      _createConnection(13, 16, label: 'Hot Cache'),
      // Cache -> Database
      _createConnection(15, 17, label: 'Miss -> DB'),
      _createConnection(16, 18, label: 'Miss -> DB'),
      // Services -> Database directly
      _createConnection(12, 17, label: 'Persist'),
      _createConnection(14, 17, label: 'Delete Expired'),
      // Analytics Pipeline
      _createConnection(13, 19, label: 'Log Click'),
      _createConnection(19, 20, label: 'Process'),
      _createConnection(20, 21, label: 'Aggregate'),
      _createConnection(21, 22, label: 'Store Report'),
      // Monitoring
      _createConnection(10, 23, label: 'Metrics'),
      _createConnection(11, 23, label: 'Metrics'),
      _createConnection(23, 24, label: 'Log'),
      _createConnection(23, 25, label: 'Alert'),
      // Admin Dashboard
      _createConnection(22, 26, label: 'View Dashboard'),
    ],
  };

  // ==========================================
  // Public API Methods
  // ==========================================

  /// Get all available designs
  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      scalableArchitecture,
      cachingOptimizedArchitecture,
      analyticsArchitecture,
      microservicesArchitecture,
      highAvailabilityArchitecture,
      secureArchitecture,
      serverlessArchitecture,
      expirationArchitecture,
      completeArchitecture,
    ];
  }

  /// Get design by name
  static Map<String, dynamic>? getDesignByName(String name) {
    final designs = getAllDesigns();
    for (final design in designs) {
      if (design['name'] == name) {
        return design;
      }
    }
    return null;
  }

  /// Get list of design names
  static List<String> getDesignNames() {
    return getAllDesigns().map((d) => d['name'] as String).toList();
  }

  /// Get design descriptions
  static Map<String, String> getDesignDescriptions() {
    final designs = getAllDesigns();
    return {
      for (final d in designs) d['name'] as String: d['description'] as String,
    };
  }

  /// Convert connections to drawable lines (for rendering on canvas)
  /// This calculates line coordinates based on icon positions
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

        // Calculate center points (assuming icon size of ~70px)
        const iconSize = 70.0;
        final startX = (fromIcon['positionX'] as num).toDouble() + iconSize / 2;
        final startY = (fromIcon['positionY'] as num).toDouble() + iconSize / 2;
        final endX = (toIcon['positionX'] as num).toDouble() + iconSize / 2;
        final endY = (toIcon['positionY'] as num).toDouble() + iconSize / 2;

        lines.add({
          'startX': startX,
          'startY': startY,
          'endX': endX,
          'endY': endY,
          'color': conn['color'] ?? 0xFF2196F3,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
          'fromIconIndex': fromIndex,
          'toIconIndex': toIndex,
        });
      }
    }

    return lines;
  }

  /// Get the connection graph as an adjacency list
  /// Returns a map where key is icon index and value is list of connected icon indices
  static Map<int, List<int>> getConnectionGraph(Map<String, dynamic> design) {
    final connections = design['connections'] as List<dynamic>;
    final graph = <int, List<int>>{};

    for (final conn in connections) {
      final from = conn['fromIconIndex'] as int;
      final to = conn['toIconIndex'] as int;

      graph.putIfAbsent(from, () => []);
      graph[from]!.add(to);
    }

    return graph;
  }

  /// Get all icons that come after a specific icon
  static List<int> getNextIcons(Map<String, dynamic> design, int iconIndex) {
    final graph = getConnectionGraph(design);
    return graph[iconIndex] ?? [];
  }

  /// Get all icons that come before a specific icon
  static List<int> getPreviousIcons(
    Map<String, dynamic> design,
    int iconIndex,
  ) {
    final connections = design['connections'] as List<dynamic>;
    final previous = <int>[];

    for (final conn in connections) {
      if (conn['toIconIndex'] == iconIndex) {
        previous.add(conn['fromIconIndex'] as int);
      }
    }

    return previous;
  }

  /// Get the data flow path from a source icon to all reachable icons
  static List<List<int>> getDataFlowPaths(
    Map<String, dynamic> design,
    int sourceIndex,
  ) {
    final graph = getConnectionGraph(design);
    final paths = <List<int>>[];
    final visited = <int>{};

    void dfs(int current, List<int> currentPath) {
      if (visited.contains(current)) return;
      visited.add(current);
      currentPath.add(current);

      final next = graph[current] ?? [];
      if (next.isEmpty) {
        paths.add(List.from(currentPath));
      } else {
        for (final nextIcon in next) {
          dfs(nextIcon, List.from(currentPath));
        }
      }
    }

    dfs(sourceIndex, []);
    return paths;
  }

  /// List of all available icons used in these designs
  static List<String> get usedIconNames => [
    // Client & Interface
    'Web Browser',
    'Mobile Client',
    'Desktop Client',
    'User',
    'Admin User',

    // Networking
    'CDN',
    'API Gateway',
    'Load Balancer',
    'Global Load Balancer',
    'Rate Limiter',
    'DNS Server',

    // Servers & Computing
    'Application Server',
    'Server Cluster',
    'Microservice',

    // Database & Storage
    'SQL Database',
    'NoSQL Database',
    'Key-Value Store',
    'Time Series Database',
    'Data Warehouse',

    // Caching
    'Cache',
    'Redis Cache',
    'In-Memory Cache',
    'CDN Cache',
    'Browser Cache',

    // Message Systems
    'Message Queue',
    'Event Stream',
    'Notification Service',
    'Email Service',

    // Security & Monitoring
    'Security Gateway',
    'Authentication',
    'Authorization',
    'Firewall',
    'Monitoring System',
    'Analytics Service',
    'Logging Service',
    'Alert System',
    'Fraud Detection',
    'Security Scanner',
    'Metrics Collector',

    // Cloud & Infrastructure
    'Cloud Service',
    'Cloud Storage',
    'Cloud Database',
    'Backup Service',
    'Sync Service',
    'Geographic Region',

    // System Utilities
    'Configuration Service',
    'Scheduler',
    'Auto-scaling Group',
    'Service Mesh',

    // Data Processing
    'Stream Processor',
    'Batch Processor',
    'Analytics Engine',

    // External Services
    'Third Party API',

    // Application Services
    'URL Shortening Service',
    'URL Redirect Service',
    'Expiration Service',
  ];
}
