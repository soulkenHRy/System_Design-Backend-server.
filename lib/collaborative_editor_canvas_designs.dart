// Collaborative Editor System - Canvas Design Data
// Contains predefined system designs using available canvas icons

import 'package:flutter/material.dart';
import 'system_design_icons.dart';

/// Provides predefined Collaborative Editor system designs for the canvas
class CollaborativeEditorCanvasDesigns {
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
    int color = 0xFF9C27B0,
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

  // DESIGN 1: Basic Collaborative Editor
  static Map<String, dynamic> get basicArchitecture => {
    'name': 'Basic Collaborative Editor',
    'description': 'Simple real-time text synchronization',
    'explanation': '''
## Basic Collaborative Editor Architecture

### What This System Does
Multiple users edit the same document simultaneously - like Google Docs. When User A types "Hello", User B sees it appear in real-time. Changes are synchronized without conflicts.

### How It Works Step-by-Step

**Step 1: User Opens Document**
User A opens a shared document. The app:
- Fetches the current document content
- Establishes a WebSocket connection
- Subscribes to changes from other users

**Step 2: User Types**
User A types the letter "H". Locally:
- "H" appears immediately (no waiting)
- A "change event" is created: {position: 0, insert: "H"}

**Step 3: Change Sent to Server**
The change is sent via WebSocket to the Sync Service:
```json
{
  "doc_id": "doc123",
  "user_id": "userA",
  "operation": {"position": 0, "insert": "H"},
  "timestamp": 1642000000
}
```

**Step 4: Server Broadcasts Change**
The Sync Service:
- Validates the change
- Stores it in the database
- Broadcasts to all other connected users

**Step 5: Other Users Receive Update**
User B's app receives the change via WebSocket:
- Applies the change to their local document
- "H" appears on their screen

**Step 6: Conflict Resolution**
What if User A and B type at the same position simultaneously?
- Server uses timestamps or operation order
- One change is applied first, then the other
- Both users end up with same result

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Web Client | User interface and local editing | User experience |
| WebSocket Gateway | Maintains live connections | Real-time sync |
| Sync Service | Processes and broadcasts changes | Core synchronization |
| Document Store | Persists document content | Data durability |
| Presence Service | Shows who's online | Collaboration awareness |
| Cursor Tracker | Shows other users' cursors | Visual feedback |

### Real-time Message Flow
```
User A types "H"
       ↓ (0ms - instant locally)
WebSocket sends to server
       ↓ (20ms)
Server validates and broadcasts
       ↓ (20ms)
User B receives and applies
       ↓
Total: ~40ms end-to-end
```

### Why WebSocket?
Regular HTTP would require constant polling:
- Poll every 100ms = 600 requests/minute
- Slow updates (up to 100ms delay)
- Wasted bandwidth

WebSocket:
- One persistent connection
- Instant push when changes occur
- Efficient bandwidth usage

### Icons Explained

**Web Browser (User A & User B)** - Users editing the same document simultaneously in their browsers.

**WebSocket Server** - Gateway maintaining persistent real-time connections with all editors.

**Sync Service** - Core service that processes, validates, and broadcasts document changes.

**NoSQL Database** - Document Store persisting the document content and history.

**User Presence** - Tracks who is currently online and viewing/editing the document.

### How They Work Together

1. User A opens document → WebSocket Server connection established
2. User A types → Sync Service receives change via WebSocket
3. Sync Service validates and stores in NoSQL Database
4. Sync Service updates User Presence (who's editing where)
5. Sync Service broadcasts change back via WebSocket Server
6. User B receives change instantly (~40ms end-to-end)
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 250, id: 'User A'),
      _createIcon('Web Browser', 'Client & Interface', 50, 450, id: 'User B'),
      _createIcon('WebSocket Server', 'Networking', 250, 350),
      _createIcon('Sync Service', 'Application Services', 450, 350),
      _createIcon('NoSQL Database', 'Database & Storage', 650, 250),
      _createIcon('User Presence', 'Application Services', 650, 450),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Edit'),
      _createConnection(1, 2, label: 'Edit'),
      _createConnection(2, 3, label: 'Process'),
      _createConnection(3, 4, label: 'Persist'),
      _createConnection(3, 5, label: 'Track'),
      _createConnection(3, 2, label: 'Broadcast'),
    ],
  };

  // DESIGN 2: Operational Transformation
  static Map<String, dynamic> get otArchitecture => {
    'name': 'Operational Transformation (OT)',
    'description': 'Classic algorithm for conflict-free editing',
    'explanation': '''
## Operational Transformation (OT) Architecture

### What This System Does
OT is the algorithm that powers Google Docs. When two users edit simultaneously, OT transforms operations so they can be applied in any order and still produce the same result.

### How It Works Step-by-Step

**Step 1: Concurrent Edits Happen**
Document starts as: "HELLO"
- User A (at position 0): Insert "X" → "XHELLO"
- User B (at position 5): Insert "Y" → "HELLOY"
- Both edits happen at the same time!

**Step 2: Server Receives Both Operations**
Server receives operations in some order (say A first, then B):
- Op A: {pos: 0, insert: "X"}
- Op B: {pos: 5, insert: "Y"}

**Step 3: OT Transforms the Second Operation**
When applying B after A:
- A inserted at position 0, shifting everything right
- B's position 5 is now position 6
- Transform: {pos: 5, insert: "Y"} → {pos: 6, insert: "Y"}

**Step 4: Apply Transformed Operations**
- Apply A: "HELLO" → "XHELLO"
- Apply transformed B: "XHELLO" → "XHELLOY"

**Step 5: Broadcast to All Clients**
Each client receives:
- The operation they didn't perform
- Transformed relative to their local state

**Step 6: Convergence**
All clients end up with: "XHELLOY"
Order of applying operations locally doesn't matter - OT ensures convergence.

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| OT Engine | Transforms operations | Conflict resolution |
| Operation Log | Stores all operations | History and undo |
| State Machine | Tracks document versions | Consistency |
| Sync Server | Coordinates transformations | Central authority |
| Client OT | Local transformation | Offline support |

### OT Transformation Example
```
Initial: "CAT"

User A: Insert "B" at position 0
User B: Delete at position 2

Without OT:
  A: "BCAT" then B deletes pos 2: "BCT" ← Wrong! Deleted A, not T

With OT:
  A: "BCAT" then transform B's position: 2→3
  Delete at position 3: "BCA" ← Correct! Deleted T
```

### OT Complexity
OT has edge cases and is notoriously hard to implement correctly. Google Docs team spent years refining it. For this reason, many new systems use CRDTs instead.

### Icons Explained

**Web Browser** - Client where users type and receive real-time updates.

**WebSocket Server** - Maintains connections and receives operations from all users.

**Stream Processor** - OT Engine that transforms concurrent operations for consistency.

**Sync Service** - Sync Server coordinating which operations apply in what order.

**Logging Service** - Operation Log storing every operation for history and undo.

**NoSQL Database** - Persistent storage for document state.

**Configuration Service** - State Machine tracking document versions for consistency.

### How They Work Together

1. Web Browser sends operation → WebSocket Server receives
2. Stream Processor (OT Engine) transforms against concurrent ops
3. Sync Service coordinates the ordering of operations
4. Logging Service stores every operation for complete history
5. NoSQL Database persists the current document state
6. Configuration Service tracks version to ensure consistency
7. Transformed result broadcast back through WebSocket Server
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('WebSocket Server', 'Networking', 200, 350),
      _createIcon('Stream Processor', 'Data Processing', 400, 250),
      _createIcon('Sync Service', 'Application Services', 400, 450),
      _createIcon('Logging Service', 'Database & Storage', 600, 250),
      _createIcon('NoSQL Database', 'Database & Storage', 600, 450),
      _createIcon('Configuration Service', 'System Utilities', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Operations'),
      _createConnection(1, 2, label: 'Transform'),
      _createConnection(1, 3, label: 'Sync'),
      _createConnection(2, 4, label: 'Log'),
      _createConnection(3, 5, label: 'Store'),
      _createConnection(2, 6, label: 'State'),
      _createConnection(6, 1, label: 'Broadcast'),
    ],
  };

  // DESIGN 3: CRDT-based Editor
  static Map<String, dynamic> get crdtArchitecture => {
    'name': 'CRDT-based Editor',
    'description': 'Conflict-free data types for decentralized sync',
    'explanation': '''
## CRDT-based Editor Architecture

### What This System Does
CRDTs (Conflict-free Replicated Data Types) enable collaboration without a central server. Each user's edits can be synced in any order, and the result is always consistent. Used by Figma, Apple Notes, and many modern apps.

### How It Works Step-by-Step

**Step 1: Each Character Has Unique ID**
Unlike OT which uses positions, CRDTs give each character a unique ID:
- Character "H" → ID: {user: A, seq: 1}
- Character "E" → ID: {user: A, seq: 2}
- etc.

**Step 2: Insertions Reference Neighbors**
When inserting, we reference what comes before:
- Insert "X" after {user: A, seq: 2}
- This reference never changes, even if other inserts happen

**Step 3: Deletions Are Tombstones**
Deleting doesn't remove the character, it marks it as deleted:
- {user: A, seq: 1, deleted: true}
- This ensures consistent ordering even after deletes

**Step 4: Merge is Automatic**
When syncing:
- Compare IDs and relationships
- Insert missing characters in correct position
- Apply tombstones
- No transformation needed!

**Step 5: Peer-to-Peer Sync**
CRDTs don't need a central server:
- User A syncs directly with User B
- Both can sync with User C
- Any sync path produces same result

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| CRDT Engine | Manages conflict-free data | Core algorithm |
| Peer Sync | Direct peer communication | Decentralization |
| Local Storage | Offline document storage | Works offline |
| Merge Service | Combines different versions | Convergence |
| Sync Gateway | Optional server relay | NAT traversal |
| Vector Clock | Tracks causality | Ordering |

### CRDT vs OT Comparison
```
Feature              OT              CRDT
──────────────────────────────────────────────
Central server       Required        Optional
Offline editing      Limited         Full support
Complexity           Very high       High
Performance          Good            Can be slow
History              Full            Full
Peer-to-peer         No              Yes
```

### CRDT Text Example (Y.js style)
```
Document: "AB"
A = {id: (1,1), value: 'A', left: null}
B = {id: (1,2), value: 'B', left: (1,1)}

User 2 inserts "X" between A and B:
X = {id: (2,1), value: 'X', left: (1,1)}

Merge: A → X → B = "AXB"
(X comes after A, B comes after A but X has priority)
```

### Icons Explained

**Web Browser (User A & User B)** - Users editing with full offline capability via CRDTs.

**Stream Processor** - CRDT Engine that manages conflict-free merge operations.

**Object Storage** - Local Storage persisting documents for offline availability.

**Sync Service** - Peer Sync enabling direct user-to-user synchronization.

**API Gateway** - Optional Sync Gateway for relaying when direct P2P isn't possible.

**Scheduler** - Vector Clock tracking causality and ordering of operations.

### How They Work Together

1. Both users edit locally → Stream Processor (CRDT) manages state
2. Each user's operations stored in Object Storage locally
3. When online, Sync Service enables peer-to-peer sync
4. Users can sync directly (User A ↔ User B) without server
5. API Gateway provides relay when direct P2P fails (NAT issues)
6. Scheduler (Vector Clock) ensures causal ordering
7. Merge is automatic - no conflicts possible with CRDTs
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 250, id: 'User A'),
      _createIcon('Web Browser', 'Client & Interface', 50, 450, id: 'User B'),
      _createIcon('Stream Processor', 'Data Processing', 250, 350),
      _createIcon('Object Storage', 'Database & Storage', 450, 250),
      _createIcon('Sync Service', 'Networking', 450, 450),
      _createIcon('API Gateway', 'Networking', 650, 350),
      _createIcon('Scheduler', 'System Utilities', 650, 550),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Operations'),
      _createConnection(1, 2, label: 'Operations'),
      _createConnection(2, 3, label: 'Store'),
      _createConnection(2, 4, label: 'Sync'),
      _createConnection(4, 5, label: 'Relay'),
      _createConnection(2, 6, label: 'Track'),
      _createConnection(0, 1, label: 'P2P', color: 0xFF9C27B0),
    ],
  };

  // DESIGN 4: Presence and Cursors
  static Map<String, dynamic> get presenceArchitecture => {
    'name': 'Presence and Cursors',
    'description': 'Showing who is editing where in real-time',
    'explanation': '''
## Presence and Cursors Architecture

### What This System Does
In Google Docs, you see colored cursors showing where other users are typing. You see who's viewing the document. This system tracks and broadcasts user presence in real-time.

### How It Works Step-by-Step

**Step 1: User Joins Document**
When User A opens the document:
- WebSocket connection established
- Join message sent: {user: "Alice", doc: "doc123"}
- Server adds Alice to document's presence list

**Step 2: Presence Broadcast**
Server broadcasts to all users on this document:
- "Alice has joined"
- Current presence list: [Alice, Bob, Charlie]

**Step 3: Cursor Position Tracked**
Every time User A moves their cursor:
- Cursor event sent: {position: 42, selection: [42, 50]}
- Sent every 50-100ms while moving
- Debounced to reduce traffic

**Step 4: Cursor Broadcast**
Server broadcasts cursor positions:
- "Alice's cursor is at position 42, selecting 42-50"
- Other users render Alice's cursor with her color

**Step 5: User Leaves**
When User A closes the document:
- WebSocket closes
- Server removes Alice from presence list
- Broadcast: "Alice has left"
- Alice's cursor disappears for others

**Step 6: Heartbeat for Stale Detection**
Users send heartbeat every 30 seconds:
- If no heartbeat for 60 seconds, user is considered "away"
- If no heartbeat for 5 minutes, user is removed

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Presence Service | Tracks online users | Who's here |
| Cursor Tracker | Tracks cursor positions | Where they are |
| Broadcast Service | Sends updates to all | Distribution |
| Heartbeat Monitor | Detects disconnections | Stale detection |
| User Metadata | Names, colors, avatars | Visual identity |

### Presence Event Types
```
Event           Data                  When
───────────────────────────────────────────────
join            {user, doc}           Document opened
leave           {user, doc}           Document closed
cursor_move     {user, position}      Cursor moved
selection       {user, start, end}    Text selected
typing          {user}                Currently typing
away            {user}                Idle > 2 minutes
```

### Cursor Color Assignment
```
Users get consistent colors:
Alice → Blue (#4285F4)
Bob → Green (#0F9D58)
Charlie → Orange (#F4B400)
Diana → Red (#DB4437)

Color derived from hash of user ID
Same user always gets same color
```

### Icons Explained

**Web Browser (User A, B, C)** - Multiple users viewing and editing the document.

**WebSocket Server** - Gateway maintaining connections for presence updates.

**User Presence (Online)** - Presence Service tracking who is currently in the document.

**User Presence (Cursor)** - Cursor Tracker recording cursor positions and selections.

**Redis Cache** - Fast storage for real-time presence and cursor data.

**Message Queue** - Broadcast Service distributing presence updates to all users.

### How They Work Together

1. User A opens document → WebSocket Server notifies User Presence
2. User Presence updates list of online users
3. User B moves cursor → WebSocket Server → User Presence (Cursor)
4. All presence data cached in Redis Cache for speed
5. Message Queue broadcasts updates to all connected users
6. Everyone sees colored cursors and online indicators in real-time
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 250, id: 'User A'),
      _createIcon('Web Browser', 'Client & Interface', 50, 400, id: 'User B'),
      _createIcon('Web Browser', 'Client & Interface', 50, 550, id: 'User C'),
      _createIcon('WebSocket Server', 'Networking', 250, 400),
      _createIcon('User Presence', 'Application Services', 450, 300),
      _createIcon('User Presence', 'Application Services', 450, 500),
      _createIcon('Redis Cache', 'Caching,Performance', 650, 400),
      _createIcon('Message Queue', 'Message Systems', 850, 400),
    ],
    'connections': [
      _createConnection(0, 3, label: 'Join'),
      _createConnection(1, 3, label: 'Cursor'),
      _createConnection(2, 3, label: 'Heartbeat'),
      _createConnection(3, 4, label: 'Presence'),
      _createConnection(3, 5, label: 'Position'),
      _createConnection(4, 6, label: 'Store'),
      _createConnection(5, 6, label: 'Store'),
      _createConnection(6, 7, label: 'Broadcast'),
    ],
  };

  // DESIGN 5: Version History
  static Map<String, dynamic> get versionHistoryArchitecture => {
    'name': 'Version History',
    'description': 'Tracking changes and enabling time travel',
    'explanation': '''
## Version History Architecture

### What This System Does
Google Docs shows version history - you can see who changed what and when, and restore any previous version. This system tracks every change and enables "time travel".

### How It Works Step-by-Step

**Step 1: Every Operation Logged**
Each edit creates an operation record:
```json
{
  "op_id": "op123",
  "doc_id": "doc456",
  "user_id": "alice",
  "timestamp": 1642000000,
  "operation": {"type": "insert", "pos": 10, "text": "Hello"},
  "prev_op_id": "op122"
}
```

**Step 2: Operations Form a Chain**
Operations are linked by prev_op_id:
- op120 → op121 → op122 → op123 → ...
- This forms a complete history

**Step 3: Snapshots Created Periodically**
Every N operations (e.g., 100), create a snapshot:
- Full document content at that point
- Allows fast reconstruction without replaying all operations

**Step 4: User Requests Version History**
User clicks "Version History":
- Fetch snapshots within time range
- Group by day/hour for display
- Show who made changes in each period

**Step 5: Viewing Past Version**
User selects a past version:
- Find nearest snapshot before that time
- Replay operations from snapshot to target time
- Render read-only view of document at that point

**Step 6: Restore Past Version**
User clicks "Restore this version":
- Creates a new operation that replaces current content with old content
- This is itself logged (so you can undo the restore!)

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Operation Log | Stores all edits | Complete history |
| Snapshot Service | Creates point-in-time saves | Fast restoration |
| Version Browser | UI for history | User exploration |
| Diff Engine | Compares versions | Shows changes |
| Restore Service | Reverts to old versions | Recovery |
| Attribution | Tracks who wrote what | Blame/credit |

### Version History Storage
```
Storage strategy:
- Last 30 days: All operations (full granularity)
- 30-90 days: Hourly snapshots
- 90-365 days: Daily snapshots
- 1+ years: Weekly snapshots

Trade-off: Storage cost vs. granularity
```

### Diff Visualization
```
Original: "The quick brown fox"
Changed:  "The slow brown dog"

Diff shown:
"The [quick→slow] brown [fox→dog]"

Deletions in red, insertions in green
```

### Icons Explained

**Web Browser** - User viewing version history and restoring past versions.

**Sync Service** - Receives edits and routes them for logging and storage.

**Logging Service** - Operation Log storing every single edit with timestamps.

**Backup Service** - Snapshot Service creating periodic full document snapshots.

**Version Control** - Version Browser UI for exploring document history.

**Stream Processor** - Diff Engine comparing versions to show changes.

**Object Storage** - Stores snapshots for fast restoration without replaying all ops.

### How They Work Together

1. Every edit flows through Sync Service → Logging Service (logged)
2. Periodically, Backup Service creates full snapshots → Object Storage
3. User requests history → Version Control shows timeline
4. Stream Processor computes diffs between versions
5. User restores old version → new operation created (itself logged)
6. Complete history preserved - nothing is ever truly lost
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('Sync Service', 'Application Services', 250, 350),
      _createIcon('Logging Service', 'Database & Storage', 450, 250),
      _createIcon('Backup Service', 'Application Services', 450, 450),
      _createIcon('Version Control', 'Application Services', 650, 250),
      _createIcon('Stream Processor', 'Data Processing', 650, 450),
      _createIcon('Object Storage', 'Database & Storage', 850, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Edit'),
      _createConnection(1, 2, label: 'Log Op'),
      _createConnection(1, 3, label: 'Snapshot'),
      _createConnection(2, 4, label: 'History'),
      _createConnection(3, 6, label: 'Store'),
      _createConnection(4, 5, label: 'Compare'),
      _createConnection(2, 5, label: 'Ops'),
    ],
  };

  // DESIGN 6: Comments and Suggestions
  static Map<String, dynamic> get commentsArchitecture => {
    'name': 'Comments and Suggestions',
    'description': 'Document annotations and review workflow',
    'explanation': '''
## Comments and Suggestions Architecture

### What This System Does
Users can add comments to specific parts of a document, reply to comments, and make "suggestions" (proposed edits). Editors can accept or reject suggestions.

### How It Works Step-by-Step

**Step 1: User Selects Text and Comments**
User selects "quick brown fox" and adds comment "Consider using 'fast'":
```json
{
  "comment_id": "c123",
  "anchor": {"start": 4, "end": 9},
  "text": "Consider using 'fast'",
  "author": "Bob",
  "created_at": 1642000000
}
```

**Step 2: Anchor Tracked**
The anchor (start/end positions) must stay attached to the right text even as the document changes:
- If text before is inserted, anchor positions shift
- If anchored text is deleted, comment becomes "orphaned"

**Step 3: Comment Thread Created**
Others reply to the comment:
- Alice: "I prefer 'quick' actually"
- Bob: "OK, let's keep it"
Comments form a thread with parent-child relationships.

**Step 4: Suggestion Made**
User makes a suggestion (proposed edit):
- Original: "quick"
- Suggested: "rapid"
- Shown as strikethrough/green text inline

**Step 5: Author Accepts/Rejects**
Document owner reviews:
- Accept: Apply the change, mark suggestion resolved
- Reject: Discard suggestion, mark resolved
- Either way, suggestion is removed from view

**Step 6: Resolve Comment**
After discussion concludes:
- Any user marks comment as "resolved"
- Comment is hidden from default view
- Can still be seen in "resolved comments" filter

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Comment Service | Manages comments | Core functionality |
| Anchor Manager | Tracks text positions | Stable references |
| Thread Service | Manages replies | Conversation flow |
| Suggestion Engine | Handles proposed edits | Review workflow |
| Notification Service | Alerts on activity | Engagement |
| Resolution Tracker | Tracks resolved items | Cleanup |

### Anchor Stability Example
```
Document: "The quick brown fox"
Comment anchored to "quick" (positions 4-9)

Someone inserts "very " before "quick":
Document: "The very quick brown fox"

Anchor updates: "quick" now at positions 9-14
Comment still points to "quick"!
```

### Suggestion Workflow
```
State: pending → accepted/rejected → applied/discarded

Pending: Visible inline, owner can act
Accepted: Edit applied to document
Rejected: Suggestion removed, text unchanged
```

### Icons Explained

**Web Browser** - User adding comments and suggestions to the document.

**API Gateway** - Routes comment and suggestion requests to appropriate services.

**Comment System (Create)** - Comment Service managing comment creation and threads.

**Recommendation Engine** - Suggestion Engine handling proposed edits.

**Document Service** - Anchor Manager keeping comments attached to correct text.

**Comment System (Thread)** - Thread Service managing replies and conversations.

**Notification Service** - Alerts users when someone replies or acts on suggestions.

**NoSQL Database** - Stores all comments, threads, and suggestions.

### How They Work Together

1. User selects text and comments → API Gateway → Comment System
2. Comment System creates comment, Document Service anchors to text
3. Others reply → Comment System (Thread) manages conversation
4. Suggestions → Recommendation Engine tracks proposed changes
5. Owner accepts/rejects → Document Service applies or discards
6. Notification Service alerts participants of activity
7. All data persisted in NoSQL Database
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Comment System', 'Application Services', 400, 250),
      _createIcon('Recommendation Engine', 'Application Services', 400, 450),
      _createIcon('Document Service', 'Data Processing', 600, 250),
      _createIcon('Comment System', 'Application Services', 600, 450),
      _createIcon('Notification Service', 'Message Systems', 800, 350),
      _createIcon('NoSQL Database', 'Database & Storage', 800, 550),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Comment'),
      _createConnection(1, 2, label: 'Create'),
      _createConnection(1, 3, label: 'Suggest'),
      _createConnection(2, 4, label: 'Anchor'),
      _createConnection(2, 5, label: 'Replies'),
      _createConnection(3, 5, label: 'Review'),
      _createConnection(5, 6, label: 'Notify'),
      _createConnection(2, 7, label: 'Store'),
    ],
  };

  // DESIGN 7: Rich Text Formatting
  static Map<String, dynamic> get richTextArchitecture => {
    'name': 'Rich Text Formatting',
    'description': 'Bold, italic, headings, and complex formatting',
    'explanation': '''
## Rich Text Formatting Architecture

### What This System Does
Documents need more than plain text. This system handles bold, italic, headings, lists, tables, images, and complex formatting while keeping everything synchronized.

### How It Works Step-by-Step

**Step 1: User Applies Formatting**
User selects "Hello" and clicks Bold:
- Selection: positions 0-5
- Action: Apply bold formatting

**Step 2: Formatting as Operations**
Formatting is an operation like text insertion:
```json
{
  "type": "format",
  "range": {"start": 0, "end": 5},
  "attributes": {"bold": true}
}
```

**Step 3: Character-level Attributes**
Each character can have multiple attributes:
- H: {bold: true}
- e: {bold: true, italic: true}
- l: {bold: true}
- etc.

**Step 4: Block-level Formatting**
Paragraphs have block attributes:
- Heading level (H1, H2, H3)
- List type (bullet, numbered)
- Alignment (left, center, right)
- Indentation level

**Step 5: Sync Formatting Changes**
Formatting operations are synced like text:
- Apply locally immediately
- Send to server
- Broadcast to other users

**Step 6: Render Rich Content**
The rendering engine interprets attributes:
- {bold: true} → <strong> or font-weight: bold
- {heading: 1} → <h1>
- {list: "bullet"} → <li> in <ul>

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Format Engine | Applies/removes formatting | Core formatting |
| Attribute Model | Stores character attributes | State management |
| Block Manager | Handles paragraphs/lists | Structure |
| Render Engine | Converts to HTML/DOM | Display |
| Toolbar Service | UI formatting controls | User interface |
| Style Resolver | Computes final styles | Inheritance |

### Document Model (Quill/Slate style)
```
[
  {insert: "Hello", attributes: {bold: true}},
  {insert: " World"},
  {insert: "\\n", attributes: {header: 1}},
  {insert: "This is a paragraph."},
  {insert: "\\n"}
]
```

### Formatting Conflicts
```
User A: Make "Hello" bold
User B: Make "Hello" italic (same time)

Result after sync: "Hello" is bold AND italic
Formatting operations merge, they don't conflict!
```

### Icons Explained

**Web Browser** - User applying formatting (bold, italic, headings) to document.

**Configuration Service (Toolbar)** - Toolbar Service providing UI formatting controls.

**Stream Processor (Format)** - Format Engine applying and removing formatting.

**Document Service (Attributes)** - Attribute Model storing per-character formatting.

**Document Service (Blocks)** - Block Manager handling paragraphs, lists, and structure.

**Stream Processor (Render)** - Render Engine converting attributes to HTML/DOM.

**Configuration Service (Styles)** - Style Resolver computing final styles with inheritance.

### How They Work Together

1. User clicks Bold → Configuration Service (Toolbar) sends command
2. Stream Processor (Format) creates formatting operation
3. Document Service (Attributes) stores character-level formatting
4. Document Service (Blocks) handles paragraph/list structure
5. Stream Processor (Render) converts to displayable HTML
6. Configuration Service (Styles) resolves inherited styles
7. Formatted document displayed in Web Browser
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('Configuration Service', 'Application Services', 200, 250),
      _createIcon('Stream Processor', 'Data Processing', 200, 450),
      _createIcon('Document Service', 'Database & Storage', 400, 350),
      _createIcon('Document Service', 'Application Services', 600, 250),
      _createIcon('Stream Processor', 'Application Services', 600, 450),
      _createIcon('Configuration Service', 'Data Processing', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Bold'),
      _createConnection(1, 2, label: 'Apply'),
      _createConnection(2, 3, label: 'Store'),
      _createConnection(3, 4, label: 'Blocks'),
      _createConnection(4, 5, label: 'Render'),
      _createConnection(5, 6, label: 'Resolve'),
      _createConnection(6, 0, label: 'Display'),
    ],
  };

  // DESIGN 8: Offline Support
  static Map<String, dynamic> get offlineArchitecture => {
    'name': 'Offline Support',
    'description': 'Edit documents without internet connection',
    'explanation': '''
## Offline Support Architecture

### What This System Does
Users should be able to edit documents without internet. Changes are saved locally and synced when connection is restored. This is especially important for CRDTs which naturally support this.

### How It Works Step-by-Step

**Step 1: User Goes Offline**
Internet connection drops:
- App detects offline state
- Shows "Offline" indicator
- Continues allowing edits

**Step 2: Local Edits Continue**
User continues editing:
- Operations saved to Local Storage (IndexedDB)
- Document renders from local state
- No delay or blocking

**Step 3: Operations Queued**
All operations added to an "outbox":
```
Outbox: [op1, op2, op3, op4...]
Status: Pending sync
```

**Step 4: Connection Restored**
Internet returns:
- App detects online state
- Begins sync process

**Step 5: Sync Pending Operations**
Outbox operations sent to server:
- Server may have changes from other users
- Merge/transform as needed
- Clear outbox after success

**Step 6: Conflict Resolution**
If others edited while you were offline:
- CRDTs: Automatic merge
- OT: Server transforms your operations
- Result: Everyone converges to same state

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Local Storage | Persists documents locally | Offline availability |
| Operation Queue | Buffers pending operations | Reliable sync |
| Network Monitor | Detects online/offline | State awareness |
| Sync Engine | Reconciles changes | Convergence |
| Conflict Resolver | Handles divergent edits | Consistency |
| Cache Manager | Manages local cache | Performance |

### Offline Storage Strategy
```
Storage Type        Content              Size Limit
─────────────────────────────────────────────────────
IndexedDB           Full documents       50MB+
LocalStorage        Settings, prefs      5MB
Service Worker      App shell            Cache varies
```

### Sync Queue Example
```
Offline for 10 minutes:
Queue: [op1, op2, op3... op50]

Back online:
1. Send op1-op50 to server
2. Receive op60-op80 from others (their edits)
3. Merge server ops with local state
4. Clear queue
5. Resume real-time sync
```

### Icons Explained

**Web Browser** - User editing document even without internet connection.

**Object Storage** - Local Storage (IndexedDB) persisting documents locally.

**Message Queue** - Operation Queue buffering pending changes until online.

**Monitoring System** - Network Monitor detecting online/offline state.

**Sync Service** - Sync Engine reconciling local and server changes.

**WebSocket Server** - Reconnects when online to resume real-time sync.

**NoSQL Database** - Server-side persistent storage for documents.

### How They Work Together

1. User edits offline → saved to Object Storage locally
2. All operations queued in Message Queue (pending sync)
3. Monitoring System detects connection restored
4. Sync Service flushes Message Queue to server
5. Server may have other users' changes → merge/transform
6. WebSocket Server re-establishes real-time sync
7. NoSQL Database stores final merged state
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('Object Storage', 'Database & Storage', 250, 250),
      _createIcon('Message Queue', 'Message Systems', 250, 450),
      _createIcon('Monitoring System', 'System Utilities', 450, 350),
      _createIcon('Sync Service', 'Application Services', 650, 350),
      _createIcon('WebSocket Server', 'Networking', 850, 250),
      _createIcon('NoSQL Database', 'Database & Storage', 850, 450),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Local Save'),
      _createConnection(0, 2, label: 'Queue Op'),
      _createConnection(3, 4, label: 'Online'),
      _createConnection(2, 4, label: 'Flush'),
      _createConnection(4, 5, label: 'Sync'),
      _createConnection(5, 6, label: 'Persist'),
      _createConnection(6, 4, label: 'Updates'),
    ],
  };

  // DESIGN 9: Access Control
  static Map<String, dynamic> get accessControlArchitecture => {
    'name': 'Access Control',
    'description': 'Sharing, permissions, and document security',
    'explanation': '''
## Access Control Architecture

### What This System Does
Document owners control who can view, comment, or edit. This system manages sharing, permissions, link sharing, and ensures users only see what they're allowed to.

### How It Works Step-by-Step

**Step 1: Owner Creates Document**
When Alice creates a document:
- She's automatically the owner
- Default: Private (only Alice)
- She can share with others

**Step 2: Share with Specific People**
Alice shares with Bob:
- Enter Bob's email
- Select permission: Viewer/Commenter/Editor
- Bob receives notification

**Step 3: Permission Levels**
Three levels with increasing access:
- Viewer: Read only
- Commenter: Read + add comments
- Editor: Read + write + comment

**Step 4: Link Sharing**
Alice enables link sharing:
- Anyone with link can: View/Comment/Edit
- Optional: Require login
- Optional: Password protect

**Step 5: Access Check**
When Bob opens the document:
- System checks Bob's permissions
- Grants appropriate access
- Hides UI elements Bob can't use (Edit button if viewer)

**Step 6: Organization-wide Sharing**
Enterprise features:
- Share with entire domain (company.com)
- Inherit folder permissions
- Admin controls for external sharing

### Component Breakdown

| Component | What It Does | Why It's Needed |
|-----------|--------------|-----------------|
| Permission Service | Manages access rules | Authorization |
| Sharing Service | Handles share requests | Collaboration |
| Auth Service | Verifies identity | Authentication |
| Link Service | Manages share links | Anonymous access |
| Audit Log | Tracks access | Security |
| Policy Engine | Enforces org rules | Compliance |

### Permission Matrix
```
Action          Viewer    Commenter    Editor    Owner
───────────────────────────────────────────────────────
View content    ✓         ✓            ✓         ✓
Add comments    ✗         ✓            ✓         ✓
Edit content    ✗         ✗            ✓         ✓
Share           ✗         ✗            ✗         ✓
Delete          ✗         ✗            ✗         ✓
Change owner    ✗         ✗            ✗         ✓
```

### Share Link Security
```
Link: docs.app/d/a1b2c3d4e5f6

Security options:
- Anyone with link (public)
- Anyone in organization
- Specific people only
- Expire after date
- Password required
```

### Icons Explained

**Web Browser** - User accessing document, subject to permission checks.

**API Gateway** - Entry point routing requests through security checks.

**Authentication** - Auth Service verifying user identity (login).

**Authorization** - Permission Service checking if user can access document.

**Sync Service** - Sharing Service handling share requests and invitations.

**Document Service** - Link Service managing shareable link generation.

**Authorization (Policy)** - Policy Engine enforcing organization-wide rules.

**Logging Service** - Audit Log tracking all access for security.

### How They Work Together

1. User requests document → API Gateway → Authentication (who are you?)
2. Authorization checks permissions (can you access this?)
3. If shared via link → Document Service validates link
4. Authorization (Policy) enforces org rules (no external sharing)
5. Access granted or denied based on checks
6. Logging Service records access attempt for audit
7. Share requests → Sync Service sends invitations
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 350),
      _createIcon('API Gateway', 'Networking', 200, 350),
      _createIcon('Authentication', 'Security,Monitoring', 400, 200),
      _createIcon('Authorization', 'Security,Monitoring', 400, 350),
      _createIcon('Sync Service', 'Application Services', 400, 500),
      _createIcon('Document Service', 'Application Services', 600, 350),
      _createIcon('Authorization', 'Data Processing', 600, 500),
      _createIcon('Logging Service', 'Database & Storage', 800, 350),
    ],
    'connections': [
      _createConnection(0, 1, label: 'Access'),
      _createConnection(1, 2, label: 'Auth'),
      _createConnection(2, 3, label: 'Check'),
      _createConnection(1, 4, label: 'Share'),
      _createConnection(4, 5, label: 'Link'),
      _createConnection(3, 6, label: 'Policy'),
      _createConnection(3, 7, label: 'Log'),
    ],
  };

  // DESIGN 10: Complete Collaborative Editor
  static Map<String, dynamic> get completeArchitecture => {
    'name': 'Complete Collaborative Editor',
    'description': 'Full Google Docs-like architecture',
    'explanation': '''
## Complete Collaborative Editor Architecture

### What This System Does
This is the full Google Docs-like system combining real-time sync, presence, history, comments, permissions, and offline support into one integrated platform.

### How It Works Step-by-Step

**Step 1: User Opens Document**
Request flows through API Gateway → Auth check → Permission check → Document fetched

**Step 2: Real-time Connection**
WebSocket established → Join presence → Receive current document → Sync cursors

**Step 3: Collaborative Editing**
User edits → Local apply → Send to sync → Transform/merge → Broadcast → Others receive

**Step 4: Rich Features**
Comments attached → Suggestions made → History tracked → Versions snapshoted

**Step 5: Access Managed**
Sharing controlled → Links generated → Permissions enforced → Audit logged

**Step 6: Offline Works**
Connection lost → Local continues → Queue operations → Reconnect → Sync pending

### Full Component List

| Category | Components |
|----------|------------|
| Client | Web, Mobile, Desktop apps |
| Real-time | WebSocket, Presence, Cursors |
| Sync | OT/CRDT Engine, Conflict Resolution |
| Storage | Document Store, Version History |
| Features | Comments, Suggestions, Formatting |
| Access | Auth, Permissions, Sharing |
| Infrastructure | CDN, Load Balancer, Cache |

### Scale Numbers (Google Docs-like)
```
Concurrent documents: 10 million+
Operations per second: 1 million+
Max users per document: 100
Version history: Unlimited
Storage per doc: 50MB
```

### Architecture Principles
1. **Real-time First**: Sub-100ms latency for all syncs
2. **Conflict-free**: No user ever loses work
3. **Offline-capable**: Full functionality without internet
4. **Permission-strict**: Security at every layer
5. **History-complete**: Every change recoverable

### Icons Explained

**Web Browser** - Desktop user editing documents in browser.

**Mobile Client** - Mobile user editing via app.

**Global Load Balancer** - Distributes traffic across servers worldwide.

**WebSocket Server** - Maintains real-time connections for live sync.

**API Gateway** - Handles HTTP requests for document CRUD operations.

**Authentication** - Auth Service verifying user identity.

**Sync Service** - OT/CRDT Engine handling real-time document synchronization.

**Document Service** - Core service for document storage and retrieval.

**User Presence** - Tracks who's online and their cursor positions.

**Comment System** - Manages comments, threads, and suggestions.

**Version Control** - Tracks all changes and enables restoration.

**NoSQL Database** - Persistent storage for all document data.

**Redis Cache** - Fast cache for presence data and hot documents.

### How They Work Together

1. Web/Mobile → Global Load Balancer → WebSocket + API Gateway
2. Authentication verifies identity before any access
3. WebSocket Server → Sync Service for real-time edits
4. Document Service handles storage, Comment System handles annotations
5. User Presence shows who's editing, Version Control tracks history
6. NoSQL Database persists everything, Redis Cache speeds up hot paths
7. Result: Full Google Docs-like collaborative editing
''',
    'icons': [
      _createIcon('Web Browser', 'Client & Interface', 50, 200),
      _createIcon('Mobile Client', 'Client & Interface', 50, 400),
      _createIcon('Global Load Balancer', 'Networking', 200, 300),
      _createIcon('WebSocket Server', 'Networking', 350, 200),
      _createIcon('API Gateway', 'Networking', 350, 400),
      _createIcon('Authentication', 'Security,Monitoring', 500, 150),
      _createIcon('Sync Service', 'Application Services', 500, 300),
      _createIcon('Document Service', 'Application Services', 500, 450),
      _createIcon('User Presence', 'Application Services', 700, 200),
      _createIcon('Comment System', 'Application Services', 700, 350),
      _createIcon('Version Control', 'Application Services', 700, 500),
      _createIcon('NoSQL Database', 'Database & Storage', 900, 300),
      _createIcon('Redis Cache', 'Caching,Performance', 900, 450),
    ],
    'connections': [
      _createConnection(0, 2, label: 'Request'),
      _createConnection(1, 2, label: 'Request'),
      _createConnection(2, 3, label: 'WebSocket'),
      _createConnection(2, 4, label: 'HTTP'),
      _createConnection(4, 5, label: 'Auth'),
      _createConnection(3, 6, label: 'Sync'),
      _createConnection(4, 7, label: 'CRUD'),
      _createConnection(6, 8, label: 'Presence'),
      _createConnection(7, 9, label: 'Comments'),
      _createConnection(7, 10, label: 'Versions'),
      _createConnection(7, 11, label: 'Store'),
      _createConnection(8, 12, label: 'Cache'),
    ],
  };

  static List<Map<String, dynamic>> getAllDesigns() {
    return [
      basicArchitecture,
      otArchitecture,
      crdtArchitecture,
      presenceArchitecture,
      versionHistoryArchitecture,
      commentsArchitecture,
      richTextArchitecture,
      offlineArchitecture,
      accessControlArchitecture,
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
          'color': conn['color'] ?? 0xFF9C27B0,
          'strokeWidth': conn['strokeWidth'] ?? 2.0,
          'label': conn['label'],
        });
      }
    }
    return lines;
  }
}
