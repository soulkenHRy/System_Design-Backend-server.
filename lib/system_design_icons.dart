import 'package:flutter/material.dart';

class SystemDesignIcons {
  // Client & User Interface Components
  static const Map<String, IconData> clientInterface = {
    'Mobile Client': Icons.phone_android,
    'Desktop Client': Icons.computer,
    'Tablet Client': Icons.tablet,
    'Web Browser': Icons.web,
    'User': Icons.person,
    'Admin User': Icons.admin_panel_settings,
    'Group Users': Icons.group,
  };

  // Network & Communication Components
  static const Map<String, IconData> networkCommunication = {
    'Load Balancer': Icons.share,
    'Router': Icons.router,
    'Network Hub': Icons.device_hub,
    'Internet Connection': Icons.wifi,
    'Global Network': Icons.language,
    'DNS Server': Icons.language,
    'Proxy Server': Icons.vpn_key,
    'API Gateway': Icons.api,
    'CDN': Icons.public,
    'WebSocket Server': Icons.electrical_services,
    'Rate Limiter': Icons.speed_outlined,
    'Global Load Balancer': Icons.alt_route,
  };

  // Servers & Computing Components
  static const Map<String, IconData> serversComputing = {
    'Web Server': Icons.developer_board,
    'Application Server': Icons.apps,
    'API Server': Icons.api,
    'Single Server': Icons.computer_sharp,
    'Server Cluster': Icons.view_module,
    'Microservice': Icons.widgets,
    'Container': Icons.inbox,
    'Virtual Machine': Icons.desktop_windows,
  };

  // Database & Storage Components
  static const Map<String, IconData> databaseStorage = {
    'SQL Database': Icons.storage,
    'NoSQL Database': Icons.table_chart,
    'Graph Database': Icons.account_tree,
    'Time Series Database': Icons.timeline,
    'Key-Value Store': Icons.key,
    'Blob Storage': Icons.folder,
    'Data Warehouse': Icons.archive,
    'File System': Icons.folder_open,
    'Object Storage': Icons.cloud_queue,
  };

  // Caching & Performance Components
  static const Map<String, IconData> cachingPerformance = {
    'Cache': Icons.cached,
    'Redis Cache': Icons.flash_on,
    'In-Memory Cache': Icons.memory,
    'CDN Cache': Icons.speed,
    'Browser Cache': Icons.web_asset,
    'Application Cache': Icons.layers,
  };

  // Message Systems & Queues
  static const Map<String, IconData> messageSystems = {
    'Message Queue': Icons.queue,
    'Event Stream': Icons.stream,
    'Publisher': Icons.send,
    'Subscriber': Icons.inbox,
    'Notification Service': Icons.notifications,
    'Email Service': Icons.email,
    'SMS Service': Icons.sms,
    'Push Notification': Icons.push_pin,
    'Crawl Queue': Icons.format_list_numbered,
  };

  // Security & Monitoring Components
  static const Map<String, IconData> securityMonitoring = {
    'Security Gateway': Icons.security,
    'Authentication': Icons.lock,
    'Authorization': Icons.verified_user,
    'Firewall': Icons.shield,
    'Monitoring System': Icons.monitor,
    'Analytics Service': Icons.analytics,
    'Logging Service': Icons.description,
    'Metrics Collector': Icons.assessment,
    'Alert System': Icons.warning,
    'Content Moderation': Icons.gavel,
    'DRM System': Icons.copyright,
    'Anti-cheat System': Icons.verified,
    'Fraud Detection': Icons.privacy_tip,
    'Security Scanner': Icons.scanner,
  };

  // Cloud & Infrastructure Components
  static const Map<String, IconData> cloudInfrastructure = {
    'Cloud Service': Icons.cloud,
    'Cloud Storage': Icons.cloud_upload,
    'Cloud Database': Icons.cloud_queue,
    'Backup Service': Icons.backup,
    'Sync Service': Icons.sync,
    'Geographic Region': Icons.place,
    'Data Center': Icons.business,
    'Edge Server': Icons.near_me,
  };

  // System Utilities & Tools
  static const Map<String, IconData> systemUtilities = {
    'Configuration Service': Icons.tune,
    'Scheduler': Icons.schedule,
    'Auto-scaling Group': Icons.autorenew,
    'Circuit Breaker': Icons.power_settings_new,
    'Service Mesh': Icons.grid_view,
    'API Manager': Icons.manage_accounts,
    'Version Control': Icons.source,
    'Build System': Icons.build,
    'Deployment Pipeline': Icons.double_arrow,
  };

  // Data Processing Components
  static const Map<String, IconData> dataProcessing = {
    'Stream Processor': Icons.water,
    'Batch Processor': Icons.inventory,
    'ETL Pipeline': Icons.transform,
    'Data Pipeline': Icons.linear_scale,
    'Search Engine': Icons.search,
    'Recommendation Engine': Icons.recommend,
    'ML Model': Icons.psychology,
    'Analytics Engine': Icons.insights,
    'Video Transcoding': Icons.video_settings,
    'Video Processing': Icons.movie_creation,
    'Image Processing': Icons.photo_filter,
    'Thumbnail Generator': Icons.photo_library,
  };

  // External Services & Integrations
  static const Map<String, IconData> externalServices = {
    'Third Party API': Icons.extension,
    'Payment Gateway': Icons.payment,
    'Social Media API': Icons.share,
    'Map Service': Icons.map,
    'Weather Service': Icons.wb_sunny,
    'File Upload Service': Icons.cloud_upload,
    'Video Streaming': Icons.play_circle,
  };

  // Application Services (NEW - Specialized business logic services)
  static const Map<String, IconData> applicationServices = {
    'Feed Generation': Icons.dynamic_feed,
    'Social Graph Service': Icons.hub,
    'Content Publishing': Icons.publish,
    'User Presence': Icons.personal_video,
    'Comment System': Icons.comment,
    'Chat Service': Icons.chat,
    'URL Shortening Service': Icons.link,
    'URL Redirect Service': Icons.shortcut,
    'Content Storage': Icons.save,
    'Content Retrieval': Icons.get_app,
    'Expiration Service': Icons.timer_off,
    'Crawl Coordinator': Icons.explore,
    'URL Discovery': Icons.travel_explore,
    'Content Extractor': Icons.content_cut,
    'Duplicate Detection': Icons.filter_alt,
    'Matching Engine': Icons.compare_arrows,
    'Routing Service': Icons.directions,
    'Pricing Engine': Icons.attach_money,
    'Trip Management': Icons.trip_origin,
    'Ranking Engine': Icons.leaderboard,
    'Score Processing': Icons.scoreboard,
    'Tournament Manager': Icons.emoji_events,
    'Achievement System': Icons.military_tech,
    'Document Service': Icons.article,
    'Collaboration Engine': Icons.workspaces,
    'Stream Management': Icons.live_tv,
    'Video Upload': Icons.video_call,
    'Video Ingest': Icons.videocam,
  };

  // Geospatial & Location Services (NEW)
  static const Map<String, IconData> geospatialServices = {
    'Location Service': Icons.my_location,
    'Geospatial Database': Icons.location_on,
    'Geohashing': Icons.grid_on,
    'Quadtree': Icons.account_tree_outlined,
    'GPS Tracking': Icons.gps_fixed,
    'Map Routing': Icons.directions_car,
  };

  // Get all icons in a flat map for easy access
  static Map<String, IconData> getAllIcons() {
    final Map<String, IconData> allIcons = {};

    allIcons.addAll(clientInterface);
    allIcons.addAll(networkCommunication);
    allIcons.addAll(serversComputing);
    allIcons.addAll(databaseStorage);
    allIcons.addAll(cachingPerformance);
    allIcons.addAll(messageSystems);
    allIcons.addAll(securityMonitoring);
    allIcons.addAll(cloudInfrastructure);
    allIcons.addAll(systemUtilities);
    allIcons.addAll(dataProcessing);
    allIcons.addAll(externalServices);
    allIcons.addAll(applicationServices);
    allIcons.addAll(geospatialServices);

    return allIcons;
  }

  // Get icons by category
  static Map<String, Map<String, IconData>> getIconsByCategory() {
    return {
      'Client & Interface': clientInterface,
      'Networking': networkCommunication,
      'Servers & Computing': serversComputing,
      'Database & Storage': databaseStorage,
      'Caching,Performance': cachingPerformance,
      'Message Systems': messageSystems,
      'Security,Monitoring': securityMonitoring,
      'Cloud,Infrastructure': cloudInfrastructure,
      'System Utilities': systemUtilities,
      'Data Processing': dataProcessing,
      'External Services': externalServices,
      'Application Services': applicationServices,
      'Geospatial & Location': geospatialServices,
    };
  }

  // Get a specific icon by name
  static IconData? getIcon(String name) {
    return getAllIcons()[name];
  }

  // Get category for a specific icon name
  static String? getCategory(String iconName) {
    final categories = getIconsByCategory();
    for (final entry in categories.entries) {
      if (entry.value.containsKey(iconName)) {
        return entry.key;
      }
    }
    return null;
  }

  // Get all icon names in a category
  static List<String> getIconNamesInCategory(String category) {
    final categories = getIconsByCategory();
    return categories[category]?.keys.toList() ?? [];
  }

  // Search icons by name (useful for filtering)
  static Map<String, IconData> searchIcons(String query) {
    final allIcons = getAllIcons();
    final filteredIcons = <String, IconData>{};

    for (final entry in allIcons.entries) {
      if (entry.key.toLowerCase().contains(query.toLowerCase())) {
        filteredIcons[entry.key] = entry.value;
      }
    }

    return filteredIcons;
  }

  // Get recommended icons for common system design patterns
  static Map<String, List<String>> getSystemPatternIcons() {
    return {
      'Microservices Architecture': [
        'API Gateway',
        'Microservice',
        'Load Balancer',
        'Message Queue',
        'Service Mesh',
      ],
      'Web Application': [
        'Web Browser',
        'Load Balancer',
        'Web Server',
        'Application Server',
        'SQL Database',
        'Cache',
      ],
      'Real-time Chat System': [
        'Mobile Client',
        'WebSocket Server',
        'Message Queue',
        'NoSQL Database',
        'Push Notification',
      ],
      'E-commerce Platform': [
        'Web Browser',
        'API Gateway',
        'User Service',
        'Product Service',
        'Payment Gateway',
        'SQL Database',
        'Cache',
      ],
      'Social Media Platform': [
        'Mobile Client',
        'CDN',
        'Load Balancer',
        'Feed Service',
        'Graph Database',
        'Message Queue',
        'Analytics Service',
      ],
    };
  }

  /// Connection validation rules for system design
  /// Returns a map where each icon name maps to a set of icons it can connect TO
  static Map<String, Set<String>> getValidConnections() {
    // Define icon groups for easier rule creation
    const clients = [
      'Mobile Client',
      'Desktop Client',
      'Tablet Client',
      'Web Browser',
      'User',
      'Admin User',
      'Group Users',
    ];

    const gateways = [
      'Load Balancer',
      'API Gateway',
      'CDN',
      'Proxy Server',
      'Global Load Balancer',
      'Rate Limiter',
      'Security Gateway',
    ];

    const servers = [
      'Web Server',
      'Application Server',
      'API Server',
      'Single Server',
      'Server Cluster',
      'Microservice',
      'Container',
      'Virtual Machine',
      'WebSocket Server',
      'Edge Server',
    ];

    const databases = [
      'SQL Database',
      'NoSQL Database',
      'Graph Database',
      'Time Series Database',
      'Key-Value Store',
      'Blob Storage',
      'Data Warehouse',
      'File System',
      'Object Storage',
      'Cloud Database',
      'Geospatial Database',
    ];

    const caches = [
      'Cache',
      'Redis Cache',
      'In-Memory Cache',
      'CDN Cache',
      'Browser Cache',
      'Application Cache',
    ];

    const messageQueues = [
      'Message Queue',
      'Event Stream',
      'Publisher',
      'Subscriber',
      'Crawl Queue',
    ];

    const notificationServices = [
      'Notification Service',
      'Email Service',
      'SMS Service',
      'Push Notification',
    ];

    const securityComponents = [
      'Security Gateway',
      'Authentication',
      'Authorization',
      'Firewall',
      'Content Moderation',
      'DRM System',
      'Anti-cheat System',
      'Fraud Detection',
      'Security Scanner',
    ];

    const monitoringComponents = [
      'Monitoring System',
      'Analytics Service',
      'Logging Service',
      'Metrics Collector',
      'Alert System',
    ];

    const cloudComponents = [
      'Cloud Service',
      'Cloud Storage',
      'Cloud Database',
      'Backup Service',
      'Sync Service',
      'Geographic Region',
      'Data Center',
    ];

    const dataProcessors = [
      'Stream Processor',
      'Batch Processor',
      'ETL Pipeline',
      'Data Pipeline',
      'Search Engine',
      'Recommendation Engine',
      'ML Model',
      'Analytics Engine',
      'Video Transcoding',
      'Video Processing',
      'Image Processing',
      'Thumbnail Generator',
    ];

    const applicationServices = [
      'Feed Generation',
      'Social Graph Service',
      'Content Publishing',
      'User Presence',
      'Comment System',
      'Chat Service',
      'URL Shortening Service',
      'URL Redirect Service',
      'Content Storage',
      'Content Retrieval',
      'Expiration Service',
      'Crawl Coordinator',
      'URL Discovery',
      'Content Extractor',
      'Duplicate Detection',
      'Matching Engine',
      'Routing Service',
      'Pricing Engine',
      'Trip Management',
      'Ranking Engine',
      'Score Processing',
      'Tournament Manager',
      'Achievement System',
      'Document Service',
      'Collaboration Engine',
      'Stream Management',
      'Video Upload',
      'Video Ingest',
    ];

    const networkComponents = [
      'Router',
      'Network Hub',
      'Internet Connection',
      'Global Network',
      'DNS Server',
    ];

    const externalServices = [
      'Third Party API',
      'Payment Gateway',
      'Social Media API',
      'Map Service',
      'Weather Service',
      'File Upload Service',
      'Video Streaming',
    ];

    const geospatialComponents = [
      'Location Service',
      'Geospatial Database',
      'Geohashing',
      'Quadtree',
      'GPS Tracking',
      'Map Routing',
    ];

    final Map<String, Set<String>> validConnections = {};

    // Helper to add connections for a list of sources to a list of targets
    void addConnections(List<String> sources, List<String> targets) {
      for (final source in sources) {
        validConnections.putIfAbsent(source, () => <String>{});
        validConnections[source]!.addAll(targets);
      }
    }

    // CLIENT CONNECTIONS
    // Clients connect to: Gateways, CDN, DNS, Security, Load Balancers, WebSockets
    addConnections(clients, gateways);
    addConnections(clients, [
      'CDN',
      'DNS Server',
      'Internet Connection',
      'Global Network',
    ]);
    addConnections(clients, [
      'Browser Cache',
    ]); // Clients can have browser cache
    addConnections(clients, [
      'WebSocket Server',
    ]); // Real-time apps (chat, gaming, live updates)
    addConnections(clients, ['Edge Server']); // Edge computing patterns
    addConnections(clients, ['Firewall']); // Security at client entry point
    addConnections(
      clients,
      notificationServices,
    ); // Push notifications to clients

    // GATEWAY/LOAD BALANCER CONNECTIONS
    // Gateways connect to: Servers, Authentication, Rate Limiters, other Gateways, Queues
    addConnections(gateways, servers);
    addConnections(gateways, [
      'Authentication',
      'Authorization',
      'Rate Limiter',
    ]);
    addConnections(gateways, caches);
    addConnections(gateways, ['CDN']);
    addConnections(gateways, messageQueues); // Async API patterns
    addConnections(gateways, applicationServices); // Direct to microservices
    addConnections(gateways, ['WebSocket Server']); // WebSocket routing
    addConnections(gateways, ['Firewall']); // Security chain

    // CDN CONNECTIONS
    // CDN connects to: Origin storage, servers
    addConnections(
      ['CDN', 'CDN Cache'],
      ['Blob Storage', 'Object Storage', 'Cloud Storage', 'File System'],
    ); // CDN pulls from origin
    addConnections([
      'CDN',
      'CDN Cache',
    ], servers); // CDN can pull from origin servers
    addConnections(['CDN', 'CDN Cache'], ['Edge Server']); // Edge distribution

    // SERVER CONNECTIONS
    // Servers connect to: Databases, Caches, Message Queues, Other Servers, Data Processors
    addConnections(servers, databases);
    addConnections(servers, caches);
    addConnections(servers, messageQueues);
    addConnections(servers, servers); // Servers can connect to each other
    addConnections(servers, applicationServices);
    addConnections(servers, dataProcessors);
    addConnections(servers, externalServices);
    addConnections(servers, notificationServices);
    addConnections(servers, monitoringComponents);
    addConnections(servers, securityComponents);
    addConnections(servers, cloudComponents);
    addConnections(servers, geospatialComponents);
    addConnections(
      servers,
      gateways,
    ); // Servers can call other APIs through gateways

    // DATABASE CONNECTIONS
    // Databases connect to: Backup, Sync, Replication (other databases), Data Processors
    addConnections(databases, ['Backup Service', 'Sync Service']);
    addConnections(databases, databases); // Database replication
    addConnections(databases, dataProcessors);
    addConnections(databases, cloudComponents);
    addConnections(databases, caches); // Write-through cache patterns
    addConnections(databases, messageQueues); // Change data capture (CDC)
    addConnections(databases, ['Search Engine']); // Database to search sync

    // CACHE CONNECTIONS
    // Caches connect to: Databases (as cache-aside pattern), other caches, servers
    addConnections(caches, databases);
    addConnections(caches, caches);
    addConnections(caches, servers); // Cache can be read by servers
    addConnections(caches, messageQueues); // Cache invalidation via queues

    // MESSAGE QUEUE CONNECTIONS
    // Message queues connect to: Servers, Data Processors, Notification Services, Application Services
    addConnections(messageQueues, servers);
    addConnections(messageQueues, dataProcessors);
    addConnections(messageQueues, notificationServices);
    addConnections(messageQueues, applicationServices);
    addConnections(messageQueues, messageQueues); // Queue chaining
    addConnections(messageQueues, databases); // Queue to database persistence
    addConnections(messageQueues, caches); // Queue updating cache
    addConnections(messageQueues, cloudComponents); // Queue to cloud storage

    // NOTIFICATION SERVICE CONNECTIONS
    // Notification services connect to: External services, Clients (conceptually)
    addConnections(notificationServices, externalServices);
    addConnections(notificationServices, clients); // Push to clients
    addConnections(
      notificationServices,
      messageQueues,
    ); // Notification via queues

    // DATA PROCESSOR CONNECTIONS
    // Data processors connect to: Databases, Storage, Caches, ML Models, other processors
    addConnections(dataProcessors, databases);
    addConnections(dataProcessors, cloudComponents);
    addConnections(dataProcessors, caches);
    addConnections(dataProcessors, dataProcessors);
    addConnections(dataProcessors, messageQueues);
    addConnections(
      dataProcessors,
      notificationServices,
    ); // Processors can trigger notifications
    addConnections(
      dataProcessors,
      applicationServices,
    ); // Processors can call services
    addConnections(
      dataProcessors,
      externalServices,
    ); // Processors can call external APIs

    // APPLICATION SERVICE CONNECTIONS
    // Application services connect to: Databases, Caches, Message Queues, Other Services
    addConnections(applicationServices, databases);
    addConnections(applicationServices, caches);
    addConnections(applicationServices, messageQueues);
    addConnections(applicationServices, applicationServices);
    addConnections(applicationServices, dataProcessors);
    addConnections(applicationServices, notificationServices);
    addConnections(applicationServices, externalServices);
    addConnections(applicationServices, cloudComponents);
    addConnections(applicationServices, geospatialComponents);

    // SECURITY COMPONENT CONNECTIONS
    // Security connects to: Servers, Gateways, Monitoring
    addConnections(securityComponents, servers);
    addConnections(securityComponents, gateways);
    addConnections(securityComponents, monitoringComponents);
    addConnections(securityComponents, databases);
    addConnections(
      securityComponents,
      messageQueues,
    ); // Security events to queue
    addConnections(securityComponents, applicationServices); // Auth services

    // MONITORING COMPONENT CONNECTIONS
    // Monitoring connects to: Everything (for observability)
    addConnections(monitoringComponents, servers);
    addConnections(monitoringComponents, databases);
    addConnections(monitoringComponents, messageQueues);
    addConnections(monitoringComponents, notificationServices);
    addConnections(monitoringComponents, cloudComponents);
    addConnections(monitoringComponents, applicationServices);
    addConnections(monitoringComponents, caches);
    addConnections(monitoringComponents, gateways);
    addConnections(monitoringComponents, dataProcessors);
    // Allow everything to connect TO monitoring (for sending metrics/logs)
    addConnections(servers, monitoringComponents);
    addConnections(databases, monitoringComponents);
    addConnections(applicationServices, monitoringComponents);
    addConnections(gateways, monitoringComponents);
    addConnections(caches, monitoringComponents);

    // CLOUD COMPONENT CONNECTIONS
    addConnections(cloudComponents, databases);
    addConnections(cloudComponents, servers);
    addConnections(cloudComponents, cloudComponents);
    addConnections(cloudComponents, messageQueues);
    addConnections(cloudComponents, applicationServices);
    addConnections(cloudComponents, dataProcessors);

    // NETWORK COMPONENT CONNECTIONS
    addConnections(networkComponents, gateways);
    addConnections(networkComponents, servers);
    addConnections(networkComponents, networkComponents);
    addConnections(networkComponents, securityComponents); // Firewall, etc.
    addConnections(networkComponents, clients); // Network to clients
    addConnections(clients, networkComponents); // Clients through network

    // GEOSPATIAL COMPONENT CONNECTIONS
    addConnections(geospatialComponents, databases);
    addConnections(geospatialComponents, caches);
    addConnections(geospatialComponents, applicationServices);
    addConnections(geospatialComponents, servers);
    addConnections(
      geospatialComponents,
      messageQueues,
    ); // Location updates via queue
    addConnections(geospatialComponents, externalServices); // Map services

    // EXTERNAL SERVICE CONNECTIONS
    // External services can connect back to servers/application services
    addConnections(externalServices, servers);
    addConnections(externalServices, applicationServices);
    addConnections(externalServices, notificationServices);
    addConnections(externalServices, messageQueues); // Webhooks to queues
    addConnections(externalServices, databases); // External data sync

    // UTILITY CONNECTIONS
    const utilities = [
      'Configuration Service',
      'Scheduler',
      'Auto-scaling Group',
      'Circuit Breaker',
      'Service Mesh',
      'API Manager',
      'Version Control',
      'Build System',
      'Deployment Pipeline',
    ];
    addConnections(utilities, servers);
    addConnections(utilities, applicationServices);
    addConnections(utilities, cloudComponents);
    addConnections(servers, utilities);
    addConnections(utilities, databases); // Config from DB
    addConnections(utilities, messageQueues); // Scheduled jobs to queue
    addConnections(
      utilities,
      monitoringComponents,
    ); // Utilities report to monitoring
    addConnections(applicationServices, utilities); // Services use utilities

    // WEBSOCKET SPECIFIC CONNECTIONS
    addConnections(['WebSocket Server'], servers);
    addConnections(['WebSocket Server'], messageQueues); // Real-time via queues
    addConnections(['WebSocket Server'], caches); // Session/presence cache
    addConnections(['WebSocket Server'], databases);
    addConnections(['WebSocket Server'], applicationServices);
    addConnections(['WebSocket Server'], notificationServices);

    // SEARCH ENGINE CONNECTIONS
    addConnections(['Search Engine'], databases); // Search indexes from DB
    addConnections(['Search Engine'], caches); // Search result caching
    addConnections(['Search Engine'], applicationServices);
    addConnections(applicationServices, ['Search Engine']);
    addConnections(servers, ['Search Engine']);

    // STORAGE SPECIFIC CONNECTIONS
    const storageComponents = [
      'Blob Storage',
      'Object Storage',
      'Cloud Storage',
      'File System',
    ];
    addConnections(servers, storageComponents);
    addConnections(applicationServices, storageComponents);
    addConnections(dataProcessors, storageComponents);
    addConnections(storageComponents, ['CDN', 'CDN Cache']); // Storage to CDN
    addConnections(storageComponents, ['Backup Service']); // Storage backup

    return validConnections;
  }

  /// Check if a connection between two icons is valid
  /// Returns true if the connection makes sense for system design
  static bool isValidConnection(String fromIcon, String toIcon) {
    // ============================================
    // INVALID CASES - These should ALWAYS be RED
    // ============================================

    // 1. Same icon type connecting to itself - NO (redundant, doesn't make sense)
    //    Exception: Databases can replicate, Servers can cluster
    if (fromIcon == toIcon) {
      // Allow only specific cases for replication/clustering
      if (_isDatabase(fromIcon)) return true; // Database replication
      if (_isServer(fromIcon)) return true; // Server clustering
      if (_isCache(fromIcon)) return true; // Distributed cache
      if (_isMessageQueue(fromIcon)) return true; // Queue chaining
      if (_isCloudComponent(fromIcon)) return true; // Multi-region
      // All other same-type connections are invalid
      return false;
    }

    // 2. Client to Client - Users don't connect directly to each other
    if (_isClient(fromIcon) && _isClient(toIcon)) {
      return false;
    }

    // 3. Clients directly to Databases - NEVER valid
    if (_isClient(fromIcon) && _isDatabase(toIcon)) {
      return false;
    }
    if (_isDatabase(fromIcon) && _isClient(toIcon)) {
      return false;
    }

    // 4. Clients directly to Caches - NEVER valid (except Browser Cache)
    if (_isClient(fromIcon) && _isCache(toIcon) && toIcon != 'Browser Cache') {
      return false;
    }
    if (_isCache(fromIcon) &&
        _isClient(toIcon) &&
        fromIcon != 'Browser Cache') {
      return false;
    }

    // 5. Clients directly to Message Queues - NEVER valid
    if (_isClient(fromIcon) && _isMessageQueue(toIcon)) {
      return false;
    }
    if (_isMessageQueue(fromIcon) && _isClient(toIcon)) {
      return false;
    }

    // 6. Clients directly to Data Processors - NEVER valid
    if (_isClient(fromIcon) && _isDataProcessor(toIcon)) {
      return false;
    }
    if (_isDataProcessor(fromIcon) && _isClient(toIcon)) {
      return false;
    }

    // 7. Clients directly to internal Application Services (most of them)
    //    Exception: Some services can be client-facing via gateway
    if (_isClient(fromIcon) && _isInternalService(toIcon)) {
      return false;
    }

    // 8. Database to Database of different types without sync service
    //    (e.g., SQL Database directly to NoSQL Database is unusual)
    //    This is allowed in the valid connections for replication scenarios

    // 9. Cache directly to Cache of different types
    //    (e.g., Redis Cache to CDN Cache doesn't make sense)
    if (_isCache(fromIcon) && _isCache(toIcon) && fromIcon != toIcon) {
      // Only allow same-type cache connections
      return false;
    }

    // 10. Security components shouldn't connect to each other directly
    //     (e.g., Firewall to Authentication doesn't flow directly)
    if (_isSecurityComponent(fromIcon) &&
        _isSecurityComponent(toIcon) &&
        fromIcon != toIcon) {
      return false;
    }

    // 11. Monitoring components shouldn't connect to each other
    //     (They collect data, don't chain to each other)
    if (_isMonitoringComponent(fromIcon) &&
        _isMonitoringComponent(toIcon) &&
        fromIcon != toIcon) {
      return false;
    }

    // 12. External services shouldn't connect directly to databases
    if (_isExternalService(fromIcon) && _isDatabase(toIcon)) {
      return false;
    }

    // 13. External services shouldn't connect directly to caches
    if (_isExternalService(fromIcon) && _isCache(toIcon)) {
      return false;
    }

    // 14. Notification services to Databases - doesn't make sense
    if (_isNotificationService(fromIcon) && _isDatabase(toIcon)) {
      return false;
    }

    // 15. Geospatial components shouldn't connect to notification services
    if (_isGeospatialComponent(fromIcon) && _isNotificationService(toIcon)) {
      return false;
    }

    // 16. Utilities connecting to clients - doesn't make sense
    if (_isUtility(fromIcon) && _isClient(toIcon)) {
      return false;
    }
    if (_isClient(fromIcon) && _isUtility(toIcon)) {
      return false;
    }

    // ============================================
    // VALID CASES - Check against our rules
    // ============================================
    final validConnections = getValidConnections();

    // Check forward connection
    if (validConnections[fromIcon]?.contains(toIcon) == true) {
      return true;
    }

    // Check reverse connection (connections can be bidirectional)
    if (validConnections[toIcon]?.contains(fromIcon) == true) {
      return true;
    }

    return false;
  }

  /// Get a hint message for why a connection is invalid
  static String getConnectionHint(String fromIcon, String toIcon) {
    // Same icon type
    if (fromIcon == toIcon) {
      return 'Connecting $fromIcon to itself is redundant. Consider using a different component or showing replication with a database/server.';
    }

    // Client to Client
    if (_isClient(fromIcon) && _isClient(toIcon)) {
      return 'Clients don\'t connect directly to each other. They communicate through servers/services.';
    }

    // Specific hints based on common mistakes
    if (_isClient(fromIcon) && _isDatabase(toIcon)) {
      return 'Clients should connect through an API Gateway or Load Balancer, not directly to databases.';
    }
    if (_isClient(fromIcon) && _isCache(toIcon)) {
      return 'Clients should connect through an API Gateway or Load Balancer, not directly to caches.';
    }
    if (_isClient(fromIcon) && _isMessageQueue(toIcon)) {
      return 'Clients should connect through servers/services, not directly to message queues.';
    }
    if (_isClient(fromIcon) && _isDataProcessor(toIcon)) {
      return 'Clients don\'t connect directly to data processors. Use an API server as intermediary.';
    }
    if (_isDatabase(fromIcon) && _isClient(toIcon)) {
      return 'Databases don\'t connect directly to clients. Use servers as intermediaries.';
    }
    if (_isCache(fromIcon) && _isClient(toIcon)) {
      return 'Caches don\'t connect directly to clients. Use servers as intermediaries.';
    }
    if (_isCache(fromIcon) && _isCache(toIcon)) {
      return 'Different cache types don\'t connect directly. They serve different purposes in the architecture.';
    }
    if (_isSecurityComponent(fromIcon) && _isSecurityComponent(toIcon)) {
      return 'Security components don\'t chain directly. They are applied at different layers.';
    }
    if (_isMonitoringComponent(fromIcon) && _isMonitoringComponent(toIcon)) {
      return 'Monitoring components collect data independently, they don\'t chain to each other.';
    }
    if (_isExternalService(fromIcon) && _isDatabase(toIcon)) {
      return 'External services shouldn\'t access your databases directly. Route through your application layer.';
    }
    if (_isUtility(fromIcon) && _isClient(toIcon)) {
      return 'Utility services are internal infrastructure, they don\'t connect to clients.';
    }

    // Generic hint
    return '$fromIcon typically doesn\'t connect directly to $toIcon in system design. Consider adding intermediate components like API Gateway, Load Balancer, or Application Server.';
  }

  // Helper methods for category checking
  static bool _isClient(String iconName) {
    return clientInterface.containsKey(iconName);
  }

  static bool _isDatabase(String iconName) {
    return databaseStorage.containsKey(iconName);
  }

  static bool _isCache(String iconName) {
    return cachingPerformance.containsKey(iconName);
  }

  static bool _isMessageQueue(String iconName) {
    return messageSystems.containsKey(iconName);
  }

  static bool _isServer(String iconName) {
    return serversComputing.containsKey(iconName);
  }

  static bool _isDataProcessor(String iconName) {
    return dataProcessing.containsKey(iconName);
  }

  static bool _isSecurityComponent(String iconName) {
    return securityMonitoring.containsKey(iconName) &&
        !_isMonitoringComponent(iconName);
  }

  static bool _isMonitoringComponent(String iconName) {
    const monitoring = [
      'Monitoring System',
      'Analytics Service',
      'Logging Service',
      'Metrics Collector',
      'Alert System',
    ];
    return monitoring.contains(iconName);
  }

  static bool _isCloudComponent(String iconName) {
    return cloudInfrastructure.containsKey(iconName);
  }

  static bool _isExternalService(String iconName) {
    return externalServices.containsKey(iconName);
  }

  static bool _isNotificationService(String iconName) {
    const notifications = [
      'Notification Service',
      'Email Service',
      'SMS Service',
      'Push Notification',
    ];
    return notifications.contains(iconName);
  }

  static bool _isGeospatialComponent(String iconName) {
    return geospatialServices.containsKey(iconName);
  }

  static bool _isUtility(String iconName) {
    const utilities = [
      'Configuration Service',
      'Scheduler',
      'Auto-scaling Group',
      'Circuit Breaker',
      'Service Mesh',
      'API Manager',
      'Version Control',
      'Build System',
      'Deployment Pipeline',
    ];
    return utilities.contains(iconName);
  }

  static bool _isInternalService(String iconName) {
    // Services that should not be directly client-facing
    const internalOnly = [
      'Feed Generation',
      'Social Graph Service',
      'Content Extractor',
      'Duplicate Detection',
      'Score Processing',
      'Crawl Coordinator',
      'URL Discovery',
      'Expiration Service',
      'Batch Processor',
      'Stream Processor',
      'ETL Pipeline',
      'Data Pipeline',
    ];
    return internalOnly.contains(iconName);
  }
}
