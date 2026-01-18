// Web Crawler System - Canvas Design Data
// Contains predefined system designs using available canvas icons

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined Web Crawler system designs for the canvas
class WebCrawlerCanvasDesigns {
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
    int color = 0xFF607D8B,
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

  // DESIGN 1: Basic Web Crawler
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic Web Crawler',
    'description': 'Simple single-threaded URL fetching',
    'explanation': '''
## Basic Web Crawler Architecture

### What This System Does
A web crawler visits websites, downloads their content, and follows links to discover new pages. Think of it as a robot that systematically reads the entire internet.

### How It Works Step-by-Step

**Step 1: Start with Seed URLs**
Crawler begins with a list of starting URLs:
```
https://example.com
https://wikipedia.org
https://news.ycombinator.com
```

**Step 2: Add to URL Frontier**
URLs added to a queue (frontier) to be crawled:
- Priority queue based on importance
- FIFO for same priority
- Deduplication to avoid repeats

**Step 3: Fetch Page**
HTTP Fetcher downloads the page:
```
GET https://example.com HTTP/1.1
Host: example.com
User-Agent: MyCrawler/1.0
```

**Step 4: Parse HTML**
Parser extracts useful data:
- Page title, content, metadata
- All links (<a href="...">)
- Images, scripts, stylesheets

**Step 5: Extract Links**
Links are extracted and normalized:
- "/about" → "https://example.com/about"
- Remove duplicates
- Filter by domain (if needed)

**Step 6: Store Content**
Page content stored in database:
```json
{
  "url": "https://example.com",
  "content": "Welcome to Example...",
  "title": "Example Domain",
  "fetched_at": 1642000000
}
```

**Step 7: Add New URLs to Frontier**
New URLs added to queue, repeat process.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Seed URLs | Starting points | Bootstrap crawler |
| URL Frontier | Queue of URLs to crawl | Work management |
| HTTP Fetcher | Downloads pages | Core fetching |
| HTML Parser | Extracts content/links | Data extraction |
| URL Extractor | Finds and normalizes links | Discovery |
| Storage | Saves page content | Persistence |

### Crawl Loop
```
while frontier.not_empty():
    url = frontier.pop()
    page = fetcher.download(url)
    content = parser.parse(page)
    store(url, content)
    links = extract_links(page)
    frontier.add(links)
```

### Icons Explained
**URL Discovery** - The starting list of URLs that bootstrap the crawler.

**Crawl Queue** - A queue holding all URLs waiting to be crawled, prioritized by importance.

**Web Server** - Downloads web pages by making HTTP GET requests to servers.

**Content Extractor** - Parses raw HTML into a structured DOM tree for data extraction.

**URL Discovery** - Finds all links in a page and normalizes them to absolute URLs.

**Blob Storage** - Database storing crawled page content, metadata, and timestamps.

### How They Work Together
1. **URL Discovery** provide initial URLs to start crawling
2. URLs added to **Crawl Queue** queue for processing
3. **Web Server** downloads the next URL from frontier
4. **Content Extractor** extracts content and structure from raw HTML
5. **URL Discovery** finds all links for discovery
6. Clean content saved to **Blob Storage**
7. New URLs added back to **Crawl Queue**, loop repeats
''',
    'icons': [
      _createIcon('URL Discovery', 'Data Processing', 50, 350),
      _createIcon('Crawl Queue', 'Message Systems', 200, 350),
      _createIcon('Web Server', 'Networking', 350, 350),
      _createIcon('Content Extractor', 'Data Processing', 500, 350),
      _createIcon('URL Discovery', 'Data Processing', 650, 250),
      _createIcon('Blob Storage', 'Database & Storage', 650, 450),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Seed'),
      _createConnection(1, 2, label: 'Next URL'),
      _createConnection(2, 3, label: 'HTML'),
      _createConnection(3, 4, label: 'Extract'),
      _createConnection(3, 5, label: 'Store'),
      _createConnection(4, 1, label: 'Add URLs'),
    ],
  };

  // DESIGN 2: Distributed Crawler
  static Map<String, dynamic> get distributedArchitecture => {
    'name': 'Distributed Crawler',
    'description': 'Multiple crawlers working in parallel',
    'explanation': '''
## Distributed Crawler Architecture

### What This System Does
The web has billions of pages. A single crawler takes years. This system uses hundreds of crawlers working in parallel, coordinated to avoid duplicates.

### How It Works Step-by-Step

**Step 1: URLs Partitioned**
URLs distributed across crawlers by hash:
```
hash("example.com") % 100 = 47 → Crawler 47
hash("wikipedia.org") % 100 = 12 → Crawler 12
```

**Step 2: Coordinator Assigns Work**
Master coordinator:
- Tracks which URLs assigned to which crawler
- Reassigns work if crawler fails
- Balances load across crawlers

**Step 3: Crawlers Work in Parallel**
Each crawler independently:
- Fetches from its assigned URLs
- Parses and extracts links
- Sends new URLs back to coordinator

**Step 4: Deduplication at Scale**
Bloom filter for fast duplicate checking:
- Probabilistic data structure
- Billions of URLs in memory
- May have false positives (re-crawl some)
- Never false negatives (never miss)

**Step 5: Results Merged**
All crawlers write to shared storage:
- Distributed database (Cassandra/HBase)
- Partitioned by URL hash
- Eventually consistent

**Step 6: Fault Tolerance**
If a crawler fails:
- Heartbeat timeout detected
- Work reassigned to healthy crawlers
- Progress checkpointed regularly

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Coordinator | Distributes work | Orchestration |
| Crawler Workers | Parallel fetching | Scale |
| Bloom Filter | Fast dedup check | Memory efficiency |
| URL Partitioner | Assigns URLs to crawlers | Load balance |
| Distributed DB | Stores all content | Scale storage |
| Health Monitor | Detects failures | Reliability |

### Scaling Numbers
```
Single crawler: ~100 pages/second
100 crawlers: ~10,000 pages/second
1000 crawlers: ~100,000 pages/second

Google crawls ~billions of pages daily!
```

### Partitioning Strategy
```
URL → hash(domain) → crawler_id

Benefits:
- Same domain always same crawler (politeness)
- Even distribution
- Easy to scale up/down
```

### Icons Explained
**Crawl Coordinator** - Master node that distributes work and tracks progress across all crawlers.

**ETL Pipeline** - Assigns URLs to specific crawlers using hash-based partitioning.

**Crawl Coordinator** (3 instances) - Independent crawlers working in parallel on assigned URLs.

**Cache** - Memory-efficient data structure for fast duplicate URL checking.

**NoSQL Database** - Scalable storage (like Cassandra) for all crawled content.

### How They Work Together
1. **Crawl Coordinator** manages overall crawl progress and health
2. **ETL Pipeline** assigns URLs to **Crawler Workers** by hash
3. Each **Crawl Coordinator** independently fetches and parses assigned URLs
4. Workers check **Cache** before crawling to skip seen URLs
5. Crawled content stored in **NoSQL Database**
6. If a worker fails, **Crawl Coordinator** reassigns its work
''',
    'icons': [
      _createIcon('Crawl Coordinator', 'Application Services', 400, 150),
      _createIcon('ETL Pipeline', 'Data Processing', 400, 300),
      _createIcon(
        'Crawl Coordinator',
        'Application Services',
        150,
        450,
        id: 'crawler1',
      ),
      _createIcon(
        'Crawl Coordinator',
        'Application Services',
        400,
        450,
        id: 'crawler2',
      ),
      _createIcon(
        'Crawl Coordinator',
        'Application Services',
        650,
        450,
        id: 'crawler3',
      ),
      _createIcon('Cache', 'Caching,Performance', 400, 600),
      _createIcon('NoSQL Database', 'Database & Storage', 650, 600),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Assign'),
      _createConnection(1, 2, label: 'URLs'),
      _createConnection(1, 3, label: 'URLs'),
      _createConnection(1, 4, label: 'URLs'),
      _createConnection(2, 5, label: 'Check'),
      _createConnection(3, 5, label: 'Check'),
      _createConnection(4, 5, label: 'Check'),
      _createConnection(2, 6, label: 'Store'),
      _createConnection(3, 6, label: 'Store'),
      _createConnection(4, 6, label: 'Store'),
    ],
  };

  // DESIGN 3: Politeness and Rate Limiting
  static Map<String, dynamic> get politenessArchitecture => {
    'name': 'Politeness and Rate Limiting',
    'description': 'Respecting robots.txt and crawl delays',
    'explanation': '''
## Politeness and Rate Limiting Architecture

### What This System Does
Aggressive crawling can overload websites. Polite crawlers respect robots.txt rules, maintain crawl delays, and limit concurrent requests per domain.

### How It Works Step-by-Step

**Step 1: Fetch robots.txt First**
Before crawling any site:
```
GET https://example.com/robots.txt

User-agent: *
Disallow: /private/
Disallow: /admin/
Crawl-delay: 5
```

**Step 2: Parse Rules**
Robots.txt Cache stores parsed rules:
- Allowed/disallowed paths
- Crawl delay (seconds between requests)
- Sitemap locations

**Step 3: Check Before Crawl**
For each URL:
- Is this path allowed? (Check against Disallow)
- When did we last crawl this domain?
- Is crawl delay satisfied?

**Step 4: Rate Limiter Enforces Delays**
Per-domain rate limiting:
```
Domain: example.com
Last crawl: 1642000000 (5 seconds ago)
Crawl delay: 10 seconds
Status: WAIT 5 more seconds
```

**Step 5: Concurrent Request Limits**
Don't overwhelm servers:
- Max 1-2 concurrent requests per domain
- Even if we have 100 URLs from same site
- Queue excess requests

**Step 6: Backoff on Errors**
If server returns errors:
- 429 Too Many Requests → Back off exponentially
- 503 Server Unavailable → Wait and retry
- Respect Retry-After header

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Robots Parser | Interprets robots.txt | Rule extraction |
| Robots Cache | Stores parsed rules | Efficiency |
| Rate Limiter | Enforces crawl delays | Politeness |
| Request Throttler | Limits concurrency | Server health |
| Backoff Handler | Handles errors | Resilience |

### Politeness Rules
```
Rule                           Default
─────────────────────────────────────────
Crawl delay                    1 second
Max concurrent per domain      2 requests
Robots.txt cache TTL           24 hours
Error backoff                  Exponential
```

### Common robots.txt Patterns
```
# Allow everything
User-agent: *
Allow: /

# Block all crawlers
User-agent: *
Disallow: /

# Block specific crawler
User-agent: BadBot
Disallow: /

# Allow only main pages
User-agent: *
Allow: /\$
Disallow: /
```

### Icons Explained
**Crawl Queue** - Queue of URLs to crawl, checks politeness before processing.

**Web Server** - Downloads robots.txt from each domain before crawling.

**Cache** - Stores parsed robots.txt rules to avoid repeated fetches.

**Content Extractor** - Interprets robots.txt rules (allowed paths, crawl delays).

**Rate Limiter** - Enforces delays between requests to the same domain.

**Rate Limiter** - Limits concurrent connections to each server.

**Web Server** - Makes the actual HTTP request after all politeness checks pass.

### How They Work Together
1. URL pops from **Crawl Queue** for processing
2. **Web Server** downloads robots.txt if not cached
3. Rules stored in **Cache** for reuse
4. **Content Extractor** checks if URL is allowed
5. **Rate Limiter** ensures crawl delay is respected
6. **Rate Limiter** limits concurrent requests per domain
7. Only then does **Web Server** download the page
''',
    'icons': [
      _createIcon('Crawl Queue', 'Message Systems', 50, 350),
      _createIcon('Web Server', 'Networking', 200, 250),
      _createIcon('Cache', 'Caching,Performance', 350, 250),
      _createIcon('Content Extractor', 'Data Processing', 500, 250),
      _createIcon('Rate Limiter', 'Networking', 350, 450),
      _createIcon('Rate Limiter', 'Networking', 500, 450),
      _createIcon('Web Server', 'Networking', 650, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Check robots'),
      _createConnection(1, 2, label: 'Cache'),
      _createConnection(2, 3, label: 'Parse'),
      _createConnection(0, 4, label: 'Rate check'),
      _createConnection(4, 5, label: 'Throttle'),
      _createConnection(5, 6, label: 'Fetch'),
      _createConnection(3, 4, label: 'Rules'),
    ],
  };

  // DESIGN 4: URL Frontier Management
  static Map<String, dynamic> get frontierArchitecture => {
    'name': 'URL Frontier Management',
    'description': 'Prioritizing and scheduling URLs to crawl',
    'explanation': '''
## URL Frontier Management Architecture

### What This System Does
The frontier is the queue of URLs to crawl. Smart frontier management prioritizes important pages, balances domains, and ensures freshness.

### How It Works Step-by-Step

**Step 1: URL Discovered**
New URL found on a page:
```
https://news.site/breaking-story
```

**Step 2: Priority Assigned**
Prioritizer calculates importance:
- PageRank of linking page
- Domain authority
- Content freshness signals
- Update frequency history

**Step 3: Added to Front Queues**
URLs organized by priority:
```
Priority 1 (High): Major news sites
Priority 2 (Medium): Popular blogs
Priority 3 (Low): Personal pages
Priority 4 (Archive): Old content
```

**Step 4: Back Queue Selection**
Selector picks which queue to process:
- Weighted random selection
- Higher priority = more frequent
- But all queues get some attention

**Step 5: Per-Host Queues**
Within each priority, separate by host:
- example.com queue
- wikipedia.org queue
- Ensures politeness (1 request at a time per host)

**Step 6: URL Popped for Crawling**
When ready to crawl:
- Pick priority queue (weighted)
- Pick host queue (round-robin)
- Pop URL, send to fetcher

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| URL Receiver | Accepts new URLs | Entry point |
| Prioritizer | Assigns importance | Smart crawling |
| Front Queues | Priority-based queues | Importance |
| Back Queues | Per-host queues | Politeness |
| Selector | Picks next URL | Balance |
| Deduplicator | Removes seen URLs | Efficiency |

### Priority Calculation
```python
def calculate_priority(url, referring_page):
    score = 0
    score += referring_page.pagerank * 10
    score += domain_authority(url.domain) * 5
    score += freshness_bonus(url)  # News sites get boost
    score -= depth(url) * 2  # Deeper pages less priority
    return score
```

### Queue Structure
```
Front Queues (by priority):
[P1] → [P2] → [P3] → [P4]

Back Queues (by host):
P1: [google.com] [amazon.com] [bbc.com]
P2: [medium.com] [dev.to] [reddit.com]
P3: [blog1.com] [blog2.com] [blog3.com]
```

### Icons Explained
**API Gateway** - Entry point that accepts newly discovered URLs.

**Duplicate Detection** - Filters out URLs that have already been crawled or queued.

**Ranking Engine** - Assigns importance scores based on PageRank, domain authority, and freshness.

**Message Queue** (front queues) - High-priority URLs organized by importance.

**Message Queue** (back queues) - Per-domain queues ensuring politeness (one at a time per host).

**Routing Service** - Picks the next URL to crawl using weighted selection across queues.

**Web Server** - Downloads the selected URL from the web.

### How They Work Together
1. New URLs enter through **API Gateway**
2. **Duplicate Detection** filters out seen URLs
3. **Ranking Engine** calculates importance score
4. High-priority URLs go to **Message Queue**, others to **Host Queues**
5. **Routing Service** picks next URL (weighted by priority)
6. Selected URL sent to **Web Server** for downloading
7. Round-robin within host queues ensures politeness
''',
    'icons': [
      _createIcon('API Gateway', 'Networking', 50, 350),
      _createIcon('Duplicate Detection', 'Data Processing', 200, 350),
      _createIcon('Ranking Engine', 'Data Processing', 350, 350),
      _createIcon('Message Queue', 'Message Systems', 550, 200, id: 'front'),
      _createIcon('Message Queue', 'Message Systems', 550, 350, id: 'back1'),
      _createIcon('Message Queue', 'Message Systems', 550, 500, id: 'back2'),
      _createIcon('Routing Service', 'Application Services', 750, 350),
      _createIcon('Web Server', 'Networking', 900, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'New URL'),
      _createConnection(1, 2, label: 'Unique'),
      _createConnection(2, 3, label: 'High'),
      _createConnection(2, 4, label: 'Medium'),
      _createConnection(2, 5, label: 'Low'),
      _createConnection(3, 6, label: 'Select'),
      _createConnection(4, 6, label: 'Select'),
      _createConnection(5, 6, label: 'Select'),
      _createConnection(6, 7, label: 'Crawl'),
    ],
  };

  // DESIGN 5: Content Parsing and Extraction
  static Map<String, dynamic> get parsingArchitecture => {
    'name': 'Content Parsing and Extraction',
    'description': 'Extracting structured data from HTML',
    'explanation': '''
## Content Parsing and Extraction Architecture

### What This System Does
Raw HTML is messy. This system extracts clean, structured data: main content, title, author, publish date, links, and removes boilerplate.

### How It Works Step-by-Step

**Step 1: HTML Received**
Fetcher provides raw HTML:
```html
<!DOCTYPE html>
<html>
<head><title>Article Title</title></head>
<body>
  <nav>Navigation...</nav>
  <article>
    <h1>Headline</h1>
    <p>Article content...</p>
  </article>
  <footer>Footer...</footer>
</body>
</html>
```

**Step 2: DOM Parsed**
HTML Parser creates DOM tree:
- Handles malformed HTML gracefully
- Fixes unclosed tags
- Normalizes encoding

**Step 3: Boilerplate Removed**
Content Extractor identifies main content:
- Remove nav, header, footer, ads
- Use text-to-tag ratio
- Machine learning classifiers

**Step 4: Metadata Extracted**
Parse structured data:
```json
{
  "title": "Article Title",
  "author": "John Doe",
  "published": "2024-01-15",
  "description": "Meta description",
  "canonical_url": "https://..."
}
```

**Step 5: Links Extracted**
All links found and normalized:
- Resolve relative URLs
- Remove fragments (#section)
- Detect external vs internal

**Step 6: Content Indexed**
Clean content ready for search:
- Title, headings, body text
- Keywords, entities
- Sentiment (optional)

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| HTML Parser | Creates DOM tree | Structure |
| Boilerplate Remover | Removes navigation/ads | Clean content |
| Metadata Extractor | Parses structured data | Rich info |
| Link Extractor | Finds all URLs | Discovery |
| Text Normalizer | Cleans text | Search prep |
| Language Detector | Identifies language | Localization |

### Boilerplate Detection
```
Content area has:
- High text-to-HTML ratio
- Continuous text blocks
- Semantic tags (<article>, <main>)

Boilerplate has:
- Low text-to-HTML ratio
- Lists of links
- Repeated across pages
```

### Extracted Data Structure
```json
{
  "url": "https://news.site/article",
  "title": "Breaking News Story",
  "content": "Clean article text...",
  "publish_date": "2024-01-15T10:30:00Z",
  "author": "Jane Reporter",
  "links": ["https://...", "https://..."],
  "images": ["https://...", "https://..."],
  "language": "en"
}
```

### Icons Explained
**Web Server** - Downloads raw HTML from web servers.

**Content Extractor** - Converts raw HTML into a structured DOM tree.

**Content Extractor** - Strips navigation, headers, footers, and ads to get main content.

**Content Extractor** - Pulls structured data like title, author, publish date.

**URL Discovery** - Finds and normalizes all URLs for further crawling.

**ETL Pipeline** - Cleans text for indexing (encoding, whitespace, etc.).

**Blob Storage** - Database storing extracted and processed page data.

### How They Work Together
1. **Web Server** downloads raw HTML page
2. **Content Extractor** creates DOM tree from HTML
3. **Content Extractor** strips navigation and ads
4. **Content Extractor** pulls title, author, dates
5. **URL Discovery** finds URLs for discovery (sent back to frontier)
6. **ETL Pipeline** cleans the main content
7. Final structured data saved to **Blob Storage**
''',
    'icons': [
      _createIcon('Web Server', 'Networking', 50, 350),
      _createIcon('Content Extractor', 'Data Processing', 200, 350),
      _createIcon('Content Extractor', 'Data Processing', 400, 200),
      _createIcon('Content Extractor', 'Data Processing', 400, 350),
      _createIcon('URL Discovery', 'Data Processing', 400, 500),
      _createIcon('ETL Pipeline', 'Data Processing', 600, 350),
      _createIcon('Blob Storage', 'Database & Storage', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Raw HTML'),
      _createConnection(1, 2, label: 'DOM'),
      _createConnection(1, 3, label: 'Meta'),
      _createConnection(1, 4, label: 'Links'),
      _createConnection(2, 5, label: 'Clean'),
      _createConnection(3, 5, label: 'Merge'),
      _createConnection(5, 6, label: 'Store'),
      _createConnection(4, 0, label: 'New URLs'),
    ],
  };

  // DESIGN 6: Deduplication System
  static Map<String, dynamic> get deduplicationArchitecture => {
    'name': 'Deduplication System',
    'description': 'Detecting duplicate and near-duplicate content',
    'explanation': '''
## Deduplication System Architecture

### What This System Does
Many pages have same content (mirrors, syndication, reposts). This system detects both exact duplicates and near-duplicates to avoid storing redundant data.

### How It Works Step-by-Step

**Step 1: URL Deduplication**
Before fetching, check if URL seen:
- Normalize URL (remove trailing slash, sort params)
- Check Bloom filter
- If seen, skip

**Step 2: Content Hash**
After fetching, hash the content:
```
MD5("Hello World article content...")
= "d41d8cd98f00b204e9800998ecf8427e"
```

**Step 3: Exact Duplicate Check**
Look up hash in database:
- If exists → exact duplicate found
- Link to original, don't store again

**Step 4: Near-Duplicate Detection**
For similar but not identical content:
- SimHash: Creates fingerprint
- MinHash: Jaccard similarity approximation
- Locality Sensitive Hashing (LSH)

**Step 5: SimHash Comparison**
SimHash generates 64-bit fingerprint:
```
Doc A: 1010110100110101...
Doc B: 1010110100110100...
Hamming distance: 1 bit (very similar!)
```

**Step 6: Cluster Similar Documents**
Group near-duplicates:
- Choose canonical version
- Store only canonical
- Reference from duplicates

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| URL Normalizer | Standardizes URLs | Avoid variants |
| Bloom Filter | Fast URL check | Memory efficient |
| Content Hasher | MD5/SHA hash | Exact dedup |
| SimHash | Fingerprint for similarity | Near-dedup |
| LSH Index | Fast similarity search | Scale |
| Cluster Manager | Groups duplicates | Organization |

### SimHash Algorithm
```
1. Tokenize document into words
2. Hash each word to 64-bit value
3. For each bit position:
   - Sum +1 if bit is 1
   - Sum -1 if bit is 0
4. Final bit is 1 if sum > 0, else 0

Result: 64-bit fingerprint
Similar docs → similar fingerprints
```

### Duplicate Statistics
```
Crawl of 1 billion pages:
- Exact duplicates: ~25%
- Near-duplicates: ~15%
- Unique content: ~60%

Dedup saves 40% storage!
```

### Icons Explained
**API Gateway** - Incoming URLs and content to check for duplicates.

**ETL Pipeline** - Standardizes URLs (removes trailing slashes, sorts params).

**Cache** - Fast probabilistic check if URL was seen before.

**Security Gateway** - Creates MD5/SHA hash of content for exact duplicate detection.

**Duplicate Detection** - Creates 64-bit fingerprint for near-duplicate detection.

**Search Engine** - Locality Sensitive Hashing index for fast similarity search.

**Server Cluster** - Groups duplicate/similar content, picks canonical version.

### How They Work Together
1. URL comes in through **API Gateway**
2. **ETL Pipeline** standardizes the URL format
3. **Cache** quickly checks if URL seen before
4. **Security Gateway** creates hash for exact duplicate check
5. **Duplicate Detection** creates fingerprint for similarity
6. **Search Engine** finds near-duplicate candidates efficiently
7. **Server Cluster** groups duplicates and selects canonical version
''',
    'icons': [
      _createIcon('API Gateway', 'Networking', 50, 350),
      _createIcon('ETL Pipeline', 'Data Processing', 200, 250),
      _createIcon('Cache', 'Caching,Performance', 200, 450),
      _createIcon('Security Gateway', 'Security,Monitoring', 400, 350),
      _createIcon('Duplicate Detection', 'Data Processing', 600, 250),
      _createIcon('Search Engine', 'Database & Storage', 600, 450),
      _createIcon('Server Cluster', 'Data Processing', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'URL'),
      _createConnection(1, 2, label: 'Check'),
      _createConnection(0, 3, label: 'Content'),
      _createConnection(3, 4, label: 'Hash'),
      _createConnection(4, 5, label: 'Index'),
      _createConnection(5, 6, label: 'Cluster'),
    ],
  };

  // DESIGN 7: Search Index Building
  static Map<String, dynamic> get indexingArchitecture => {
    'name': 'Search Index Building',
    'description': 'Creating inverted index for fast search',
    'explanation': '''
## Search Index Building Architecture

### What This System Does
After crawling, we need to make content searchable. This system builds an inverted index: given a word, find all documents containing it.

### How It Works Step-by-Step

**Step 1: Document Tokenized**
Split document into terms:
```
"The quick brown fox" →
["the", "quick", "brown", "fox"]
```

**Step 2: Terms Normalized**
Apply text processing:
- Lowercase: "The" → "the"
- Stemming: "running" → "run"
- Remove stop words: "the", "a", "is"

**Step 3: Inverted Index Built**
Map terms to documents:
```
"quick" → [doc1, doc47, doc892]
"brown" → [doc1, doc23]
"fox"   → [doc1, doc47]
```

**Step 4: Position Index Added**
Store where in document:
```
"quick" → [
  doc1: [positions: 2, 45, 67],
  doc47: [positions: 12]
]
```

**Step 5: TF-IDF Calculated**
Score term importance:
- TF: How often in this doc
- IDF: How rare across all docs
- TF-IDF = TF × IDF

**Step 6: Index Sharded**
Split index for scale:
- By term hash (a-m, n-z)
- By document ID ranges
- Replicated for reliability

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Tokenizer | Splits into words | Basic parsing |
| Normalizer | Stems, lowercases | Consistency |
| Index Builder | Creates inverted index | Core indexing |
| TF-IDF Calculator | Scores relevance | Ranking |
| Shard Manager | Distributes index | Scale |
| Index Merger | Combines partial indexes | Efficiency |

### Inverted Index Structure
```
Term → PostingList
PostingList = [(DocID, [Positions], TF-IDF), ...]

Example:
"algorithm" → [
  (doc42, [15, 89, 234], 0.87),
  (doc103, [3], 0.45),
  (doc891, [67, 68], 0.92)
]
```

### Search Query Execution
```
Query: "quick brown fox"

1. Look up "quick" → [doc1, doc47, doc892]
2. Look up "brown" → [doc1, doc23]
3. Look up "fox" → [doc1, doc47]
4. Intersect: [doc1] contains all terms
5. Rank by TF-IDF scores
6. Return doc1 first
```

### Icons Explained
**Blob Storage** - Database containing all crawled page content.

**ETL Pipeline** - Splits document text into individual words/tokens.

**ETL Pipeline** - Lowercases, stems words, removes stop words for consistency.

**Search Engine** - Creates the inverted index mapping terms to documents.

**Analytics Engine** - Computes term importance scores for ranking.

**Data Pipeline** - Distributes index across multiple machines for scale.

**Search Engine** - The final inverted index used for fast search queries.

### How They Work Together
1. **Blob Storage** provides crawled content
2. **ETL Pipeline** splits text into words
3. **ETL Pipeline** standardizes tokens (lowercase, stemming)
4. **Search Engine** creates inverted index (term → documents)
5. **Analytics Engine** computes relevance scores
6. **Data Pipeline** distributes index for scale
7. Final **Search Engine** ready for fast queries
''',
    'icons': [
      _createIcon('Blob Storage', 'Database & Storage', 50, 350),
      _createIcon('ETL Pipeline', 'Data Processing', 200, 350),
      _createIcon('ETL Pipeline', 'Data Processing', 350, 350),
      _createIcon('Search Engine', 'Data Processing', 500, 250),
      _createIcon('Analytics Engine', 'Data Processing', 500, 450),
      _createIcon('Data Pipeline', 'System Utilities', 700, 350),
      _createIcon('Search Engine', 'Database & Storage', 850, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Documents'),
      _createConnection(1, 2, label: 'Tokens'),
      _createConnection(2, 3, label: 'Terms'),
      _createConnection(2, 4, label: 'Calculate'),
      _createConnection(3, 5, label: 'Postings'),
      _createConnection(4, 5, label: 'Scores'),
      _createConnection(5, 6, label: 'Store'),
    ],
  };

  // DESIGN 8: PageRank Computation
  static Map<String, dynamic> get pagerankArchitecture => {
    'name': 'PageRank Computation',
    'description': 'Computing page importance from link graph',
    'explanation': '''
## PageRank Computation Architecture

### What This System Does
PageRank determines page importance based on incoming links. A page is important if important pages link to it. Used for ranking search results.

### How It Works Step-by-Step

**Step 1: Build Link Graph**
From crawled data, extract links:
```
Page A → [B, C]
Page B → [A, D]
Page C → [A]
Page D → [B, C]
```

**Step 2: Initialize PageRank**
All pages start with equal rank:
```
PR(A) = PR(B) = PR(C) = PR(D) = 0.25
```

**Step 3: Iterate**
Apply PageRank formula repeatedly:
```
PR(A) = (1-d)/N + d × Σ(PR(i)/outlinks(i))

Where:
- d = damping factor (usually 0.85)
- N = total pages
- i = pages linking to A
```

**Step 4: Convergence Check**
Stop when ranks stabilize:
- Calculate change from last iteration
- If change < threshold, stop
- Usually 20-50 iterations

**Step 5: Handle Dangling Pages**
Pages with no outlinks:
- Distribute their rank to all pages
- Prevents rank "sinking"

**Step 6: Store Final Ranks**
Save computed PageRank:
```
A: 0.38
B: 0.12
C: 0.28
D: 0.22
```

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Link Extractor | Builds link graph | Graph structure |
| Graph Store | Stores adjacency list | Scale |
| PageRank Engine | Iterative computation | Core algorithm |
| Convergence Checker | Detects stability | Stop condition |
| Rank Store | Saves final values | Persistence |

### PageRank Example
```
Iteration 0: A=0.25, B=0.25, C=0.25, D=0.25
Iteration 1: A=0.33, B=0.18, C=0.28, D=0.21
Iteration 2: A=0.36, B=0.14, C=0.29, D=0.21
...
Final: A=0.38, B=0.12, C=0.28, D=0.22

Page A has highest rank (most incoming links)
```

### MapReduce Implementation
```
MAP: For each page P with outlinks
  Emit (P, 0)  // for structure
  For each outlink L:
    Emit (L, PR(P) / num_outlinks)

REDUCE: For each page P
  Sum all incoming rank contributions
  NewPR(P) = (1-d)/N + d × sum
```

### Icons Explained
**Blob Storage** - Contains all crawled pages with their outgoing links.

**URL Discovery** - Extracts link relationships from crawled pages.

**Graph Database** - Graph database storing page-to-page link structure.

**Ranking Engine** - Iteratively computes page importance from link graph.

**Monitoring System** - Monitors when PageRank values stabilize.

**Data Warehouse** - Database storing final computed PageRank scores.

### How They Work Together
1. **Blob Storage** provides crawled pages
2. **URL Discovery** builds link relationships
3. **Graph Database** stores the adjacency structure
4. **Ranking Engine** runs iterative computation
5. **Monitoring System** monitors for stability
6. When converged, final ranks saved to **Data Warehouse**
7. PageRank scores used for search result ranking
''',
    'icons': [
      _createIcon('Blob Storage', 'Database & Storage', 50, 350),
      _createIcon('URL Discovery', 'Data Processing', 200, 350),
      _createIcon('Graph Database', 'Database & Storage', 400, 350),
      _createIcon('Ranking Engine', 'Data Processing', 600, 250),
      _createIcon('Monitoring System', 'Data Processing', 600, 450),
      _createIcon('Data Warehouse', 'Database & Storage', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Pages'),
      _createConnection(1, 2, label: 'Links'),
      _createConnection(2, 3, label: 'Graph'),
      _createConnection(3, 4, label: 'Check'),
      _createConnection(4, 3, label: 'Iterate'),
      _createConnection(3, 5, label: 'Final'),
    ],
  };

  // DESIGN 9: Freshness and Re-crawling
  static Map<String, dynamic> get freshnessArchitecture => {
    'name': 'Freshness and Re-crawling',
    'description': 'Keeping content up-to-date with smart scheduling',
    'explanation': '''
## Freshness and Re-crawling Architecture

### What This System Does
Web content changes. News sites update hourly, personal blogs rarely. This system schedules re-crawls intelligently based on how often pages actually change.

### How It Works Step-by-Step

**Step 1: Track Change History**
For each page, record:
```
URL: news.site/front-page
Last crawl: 1642000000
Content hash: abc123
Change history: [1h, 2h, 1h, 3h, 1h]
```

**Step 2: Calculate Change Rate**
Estimate change probability:
- Average time between changes
- Variance (consistent or sporadic?)
- Time since last change

**Step 3: Priority Score**
Score = importance × freshness_need:
- High PageRank + changes often = HIGH priority
- Low PageRank + rarely changes = LOW priority

**Step 4: Schedule Re-crawl**
Add to frontier with timestamp:
```
news.site/front-page: crawl at 1642003600 (1hr from now)
blog.site/old-post: crawl at 1642604800 (1 week from now)
```

**Step 5: Compare on Crawl**
When re-crawled:
- Hash new content
- Compare to stored hash
- If changed: update index
- Update change statistics

**Step 6: Adaptive Scheduling**
Adjust based on actual changes:
- Changed as expected → keep schedule
- Changed faster → increase frequency
- No change → decrease frequency

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Change Tracker | Records history | Learning |
| Change Predictor | Estimates next change | Scheduling |
| Priority Calculator | Ranks by importance | Resource allocation |
| Scheduler | Sets crawl times | Timing |
| Diff Detector | Compares versions | Change detection |

### Change Detection
```
Method 1: Content Hash
- Fast comparison
- Any change triggers update

Method 2: Structural Diff
- Compare DOM structure
- Ignore minor text changes

Method 3: Semantic Diff
- Compare meaning
- Ignore formatting changes
```

### Scheduling Strategies
```
Strategy              When to Use
─────────────────────────────────────────
Fixed interval        Simple, predictable
Adaptive              Learning change patterns
Age-based             Older = less frequent
Importance-based      High PageRank = more often
Combined              Best of all worlds
```

### Icons Explained
**Scheduler** - Triggers re-crawl jobs based on calculated timing.

**Analytics Service** - Records when pages changed historically.

**ML Model** - Uses history to estimate when page will change next.

**Ranking Engine** - Combines importance and freshness need into priority score.

**Crawl Queue** - Queue where scheduled URLs wait for re-crawling.

**Web Server** - Downloads the page for re-crawl.

**Duplicate Detection** - Compares new content to stored version to detect changes.

### How They Work Together
1. **Scheduler** checks which pages are due for re-crawl
2. **Analytics Service** provides historical change data
3. **ML Model** estimates next change time
4. **Ranking Engine** scores by importance × freshness need
5. Scheduled URLs added to **Crawl Queue**
6. **Web Server** re-downloads the page
7. **Duplicate Detection** compares to stored version
8. If changed, updates storage and **Analytics Service** learns new pattern
''',
    'icons': [
      _createIcon('Scheduler', 'System Utilities', 50, 350),
      _createIcon('Analytics Service', 'Data Processing', 200, 250),
      _createIcon('ML Model', 'Data Processing', 200, 450),
      _createIcon('Ranking Engine', 'Data Processing', 400, 350),
      _createIcon('Crawl Queue', 'Message Systems', 600, 350),
      _createIcon('Web Server', 'Networking', 750, 350),
      _createIcon('Duplicate Detection', 'Data Processing', 900, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'History'),
      _createConnection(1, 2, label: 'Stats'),
      _createConnection(2, 3, label: 'Predict'),
      _createConnection(3, 4, label: 'Schedule'),
      _createConnection(4, 5, label: 'Crawl'),
      _createConnection(5, 6, label: 'Compare'),
      _createConnection(6, 1, label: 'Update'),
    ],
  };

  // DESIGN 10: Complete Web Crawler System
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete Web Crawler',
    'description': 'Full-featured distributed web crawler',
    'explanation': '''
## Complete Web Crawler Architecture

### What This System Does
This is a production web crawler combining: distributed crawling, politeness, intelligent frontier, content extraction, deduplication, indexing, and ranking.

### How It Works Step-by-Step

**Step 1: Seed & Schedule**
Start with seeds, scheduler adds URLs to frontier with priorities.

**Step 2: Polite Fetching**
Check robots.txt, rate limit, fetch page politely.

**Step 3: Parse & Extract**
Extract clean content, metadata, and links.

**Step 4: Deduplicate**
Skip exact and near-duplicates.

**Step 5: Index & Rank**
Build inverted index, compute PageRank.

**Step 6: Schedule Re-crawl**
Based on change patterns, schedule next visit.

### Full Component List

| Category | Components |
|----------|------------|
| Scheduling | Frontier, Priority Queue, Scheduler |
| Fetching | DNS, Robots, Rate Limiter, HTTP |
| Parsing | HTML Parser, Extractor, Normalizer |
| Dedup | Bloom Filter, SimHash, LSH |
| Storage | Document Store, Index, Graph |
| Ranking | PageRank, TF-IDF |
| Coordination | Master, Workers, Health Monitor |

### Scale Numbers
```
Pages crawled: 10 billion
Index size: 100 TB
Crawlers: 1000
Pages/second: 100,000
Re-crawl cycle: 30 days
```

### Architecture Principles
1. **Distribute Everything**: URLs, crawlers, storage
2. **Be Polite**: Respect robots.txt, rate limits
3. **Deduplicate Early**: Save resources
4. **Prioritize Smart**: Important pages first
5. **Stay Fresh**: Adaptive re-crawling

### Icons Explained
**URL Discovery** - Initial URLs that bootstrap the crawler.

**Scheduler** - Schedules re-crawls based on change patterns.

**Crawl Queue** - Priority queue of URLs waiting to be crawled.

**Cache** - Cached robots.txt rules for each domain.

**Crawl Coordinator** - Worker that fetches pages respecting politeness.

**Content Extractor** - Extracts content and links from downloaded HTML.

**Duplicate Detection** - Detects and filters duplicate/similar content.

**Blob Storage** - Database storing all crawled page content.

**Search Engine** - Creates inverted index for search.

**Search Engine** - Final searchable index of web content.

**Ranking Engine** - Computes page importance from link structure.

### How They Work Together
1. **URL Discovery** and **Scheduler** feed URLs to **Crawl Queue**
2. **Crawl Coordinator** checks **Cache** for politeness
3. **Crawl Coordinator** downloads page, sends to **Content Extractor**
4. **Content Extractor** extracts links (back to frontier) and content
5. **Duplicate Detection** filters duplicates
6. Clean content stored in **Blob Storage**
7. **Search Engine** creates **Search Engine** from documents
8. **Ranking Engine** computes page importance for ranking
''',
    'icons': [
      _createIcon('URL Discovery', 'Data Processing', 50, 200),
      _createIcon('Scheduler', 'System Utilities', 50, 400),
      _createIcon('Crawl Queue', 'Message Systems', 200, 300),
      _createIcon('Cache', 'Caching,Performance', 350, 200),
      _createIcon('Crawl Coordinator', 'Application Services', 350, 400),
      _createIcon('Content Extractor', 'Data Processing', 500, 300),
      _createIcon('Duplicate Detection', 'Data Processing', 650, 200),
      _createIcon('Blob Storage', 'Database & Storage', 650, 400),
      _createIcon('Search Engine', 'Data Processing', 800, 300),
      _createIcon('Search Engine', 'Database & Storage', 950, 200),
      _createIcon('Ranking Engine', 'Data Processing', 950, 400),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Seed'),
      _createConnection(1, 2, label: 'Schedule'),
      _createConnection(2, 4, label: 'URLs'),
      _createConnection(3, 4, label: 'Rules'),
      _createConnection(4, 5, label: 'HTML'),
      _createConnection(5, 6, label: 'Content'),
      _createConnection(6, 7, label: 'Store'),
      _createConnection(5, 2, label: 'Links'),
      _createConnection(7, 8, label: 'Index'),
      _createConnection(8, 9, label: 'Inverted'),
      _createConnection(7, 10, label: 'Links'),
    ],
  };

  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      distributedArchitecture,
      politenessArchitecture,
      frontierArchitecture,
      parsingArchitecture,
      deduplicationArchitecture,
      indexingArchitecture,
      pagerankArchitecture,
      freshnessArchitecture,
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
          'color': conn['color'] ?? 0xFF607D8B,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
        });
      }
    }
    return lines;
  }
}
