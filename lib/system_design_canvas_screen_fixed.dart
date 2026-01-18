import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'system_design_icons.dart';
import 'system_description_notebook.dart';
import 'icon_library_dialog.dart';
import 'design_comparison_service.dart';

class SystemDesignCanvasScreen extends StatefulWidget {
  final String systemName;
  final Map<String, dynamic>? initialCanvasData;
  final Function(
    String question,
    String notes,
    CanvasValidationData? canvasData,
  )?
  onSubmitDesign;

  const SystemDesignCanvasScreen({
    super.key,
    required this.systemName,
    this.initialCanvasData,
    this.onSubmitDesign,
  });

  @override
  State<SystemDesignCanvasScreen> createState() =>
      SystemDesignCanvasScreenState();
}

class SystemDesignCanvasScreenState extends State<SystemDesignCanvasScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Track which categories are expanded
  Set<String> expandedCategories = {};

  // Track dragged items on the canvas
  List<DroppedIcon> droppedIcons = [];

  // Track selected icons (by index)
  Set<int> selectedIcons = {};

  // Track selected lines (by index)
  Set<int> selectedLines = {};

  // Drawing functionality
  bool isDrawingMode = false;
  List<DrawnLine> drawnLines = [];
  Offset? drawingStart;
  Offset? drawingEnd;
  bool isDrawing = false;

  // Debug flag to show invisible extended lines (set to true to visualize them)
  bool showExtendedLines = false;

  // Track which icons are connected to each line (by line index)
  Map<int, LineConnection> lineConnections = {};

  // Undo/Redo functionality
  List<CanvasState> _undoStack = [];
  List<CanvasState> _redoStack = [];
  static const int _maxHistorySize =
      50; // Limit history to prevent memory issues

  // ScrollController for horizontal icon list
  late ScrollController _horizontalScrollController;

  // Transform controller for zoom functionality
  late TransformationController _transformationController;

  // Animation controller for data flow on green arrows
  late AnimationController _dataFlowAnimationController;

  @override
  void initState() {
    super.initState();

    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Initialize controllers
    _horizontalScrollController = ScrollController();
    _transformationController = TransformationController();

    // Initialize data flow animation controller
    _dataFlowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // Continuously animate

    // Always load saved design data when screen opens
    _loadDesign();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save when app goes to background or is paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveDesignSync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Use sync save to ensure it completes before disposal
    _saveDesignSync();
    _horizontalScrollController.dispose();
    _transformationController.dispose();
    _dataFlowAnimationController.dispose();
    super.dispose();
  }

  // Debug utility to check what's stored
  Future<void> _debugCheckStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final designKey = 'design_${widget.systemName}';
      final jsonString = prefs.getString(designKey);

      if (jsonString != null) {
        final data = jsonDecode(jsonString);
        final storedLines = (data['lines'] as List?)?.length ?? 0;
        print(
          '🔍 STORED DATA CHECK: Key="$designKey" has $storedLines connections',
        );
        if (storedLines > 0) {
          print('   Sample line data: ${(data['lines'] as List)[0]}');
        }
      } else {
        print('🔍 STORED DATA CHECK: No data found for key="$designKey"');
      }
    } catch (e) {
      print('🔍 STORED DATA CHECK ERROR: $e');
    }
  }

  // Synchronous save that blocks until complete - used in dispose
  void _saveDesignSync() {
    try {
      final iconsData = droppedIcons.map((icon) => icon.toJson()).toList();
      final linesData = drawnLines.map((line) => line.toJson()).toList();
      final designData = {'icons': iconsData, 'lines': linesData};
      final jsonString = jsonEncode(designData);
      final designKey = 'design_${widget.systemName}';

      print(
        '💾 SYNC SAVE: Attempting to save ${linesData.length} connections for key="$designKey"',
      );

      // Use a microtask to ensure save starts immediately
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(designKey, jsonString);
        print(
          '💾 SYNC SAVE: Completed for key: $designKey with ${linesData.length} lines',
        );
      });
    } catch (e) {
      print('❌ ERROR in _saveDesignSync: $e');
    }
  }

  // Save the current design to local storage
  Future<void> _saveDesign() async {
    try {
      print('💾 ASYNC SAVE: Starting for systemName: ${widget.systemName}');
      final prefs = await SharedPreferences.getInstance();
      final designKey = 'design_${widget.systemName}';

      // Convert dropped icons and drawn lines to JSON
      final iconsData = droppedIcons.map((icon) => icon.toJson()).toList();
      final linesData = drawnLines.map((line) => line.toJson()).toList();

      final designData = {'icons': iconsData, 'lines': linesData};
      final jsonString = jsonEncode(designData);

      await prefs.setString(designKey, jsonString);
      print('💾 ASYNC SAVE: ✅ Successfully saved to key="$designKey"');
      print(
        '   📊 Saved ${droppedIcons.length} icons and ${linesData.length} connections',
      );

      // Verify the save worked
      await _debugCheckStoredData();
    } catch (e) {
      print('❌ ERROR in _saveDesign: $e');
    }
  }

  // Public method to get current canvas data
  Map<String, dynamic> getCanvasData() {
    final iconsData = droppedIcons.map((icon) => icon.toJson()).toList();
    final linesData = drawnLines.map((line) => line.toJson()).toList();
    return {'icons': iconsData, 'lines': linesData};
  }

  // Load the saved design from local storage or from initialCanvasData
  Future<void> _loadDesign() async {
    try {
      print('\n📂 LOAD: Starting load for systemName: ${widget.systemName}');

      // First, try to load from SharedPreferences (user's saved work has priority)
      final prefs = await SharedPreferences.getInstance();
      final designKey = 'design_${widget.systemName}';

      final jsonString = prefs.getString(designKey);
      if (jsonString != null) {
        // Load from saved design
        print(
          '📂 LOAD: Found saved data in SharedPreferences for key: $designKey',
        );
        final dynamic designData = jsonDecode(jsonString);

        setState(() {
          if (designData is List) {
            // Old format - just icons
            print('📂 LOAD: Using old format (icons only)');
            droppedIcons =
                designData.map((json) => DroppedIcon.fromJson(json)).toList();
            drawnLines = [];
          } else if (designData is Map) {
            // New format - icons and lines
            final iconsData = designData['icons'] as List<dynamic>? ?? [];
            final linesData = designData['lines'] as List<dynamic>? ?? [];

            print(
              '📂 LOAD: Using new format - parsing ${iconsData.length} icons and ${linesData.length} connections',
            );

            droppedIcons =
                iconsData.map((json) => DroppedIcon.fromJson(json)).toList();
            drawnLines =
                linesData.map((json) => DrawnLine.fromJson(json)).toList();

            print(
              '📂 LOAD: ✅ Successfully loaded ${droppedIcons.length} icons and ${drawnLines.length} connections from SharedPreferences',
            );
          }
        });

        // Rebuild line connections after loading
        if (drawnLines.isNotEmpty) {
          print('🔄 LOAD: Rebuilding ${drawnLines.length} line connections...');
          _updateAllLineConnections();
          print('🔄 LOAD: Line connections rebuilt successfully');
        }

        return; // Successfully loaded from saved data
      } else {
        print(
          '📂 LOAD: No saved data found in SharedPreferences for key: $designKey',
        );
      }

      // If no saved data exists, use initialCanvasData as fallback (template/initial state)
      if (widget.initialCanvasData != null) {
        final designData = widget.initialCanvasData!;
        final iconsCount = (designData['icons'] as List?)?.length ?? 0;
        final linesCount = (designData['lines'] as List?)?.length ?? 0;

        print('📂 LOAD: Using initialCanvasData (template) as fallback');
        print(
          '   📊 Template has $iconsCount icons and $linesCount connections',
        );
        setState(() {
          final iconsData = designData['icons'] as List<dynamic>? ?? [];
          final linesData = designData['lines'] as List<dynamic>? ?? [];

          droppedIcons =
              iconsData
                  .map(
                    (json) =>
                        DroppedIcon.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();
          drawnLines =
              linesData
                  .map(
                    (json) => DrawnLine.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();

          print(
            '📂 LOAD: Loaded ${droppedIcons.length} icons and ${drawnLines.length} lines from template',
          );
        });

        // Rebuild line connections after loading from template
        if (drawnLines.isNotEmpty) {
          print(
            '🔄 LOAD: Rebuilding ${drawnLines.length} line connections from template...',
          );
          _updateAllLineConnections();
        }
      } else {
        print(
          '📂 LOAD: No saved data and no initialCanvasData for: $designKey',
        );
      }
    } catch (e) {
      print('ERROR in _loadDesign: $e');
    }
  }

  // Delete selected icons and lines
  void _deleteSelectedIcons() {
    // Safety check - only proceed if something is actually selected
    if (selectedIcons.isEmpty && selectedLines.isEmpty) {
      return;
    }

    _saveStateToHistory(); // Save state before deletion

    setState(() {
      // Delete selected icons
      if (selectedIcons.isNotEmpty) {
        // Sort indices in descending order to avoid index shifting issues
        final sortedIndices =
            selectedIcons.toList()..sort((a, b) => b.compareTo(a));

        // Remove icons starting from highest index
        for (final index in sortedIndices) {
          if (index < droppedIcons.length) {
            droppedIcons.removeAt(index);
          }
        }

        // Update line connections after icons are deleted
        _updateAllLineConnections();
      }

      // Delete selected lines
      if (selectedLines.isNotEmpty) {
        // Sort indices in descending order to avoid index shifting issues
        final sortedLineIndices =
            selectedLines.toList()..sort((a, b) => b.compareTo(a));

        // Remove lines starting from highest index
        for (final index in sortedLineIndices) {
          if (index < drawnLines.length) {
            drawnLines.removeAt(index);
            // Remove connection data for this line
            lineConnections.remove(index);
          }
        }

        // Rebuild lineConnections map with updated indices
        final newConnections = <int, LineConnection>{};
        lineConnections.forEach((oldIndex, connection) {
          // Calculate how many indices were removed before this one
          final removedBefore =
              sortedLineIndices.where((i) => i < oldIndex).length;
          final newIndex = oldIndex - removedBefore;
          newConnections[newIndex] = connection;
        });
        lineConnections = newConnections;
      }

      // Clear selections
      selectedIcons.clear();
      selectedLines.clear();
    });
    _saveDesign(); // Save after deletion
  }

  // Show confirmation dialog before clearing everything
  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Clear Canvas',
                style: GoogleFonts.saira(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to clear all icons and connections?\n\nThis action cannot be undone.',
            style: GoogleFonts.saira(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.saira(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCanvas();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.saira(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Clear all icons and lines from the canvas
  void _clearCanvas() {
    _saveStateToHistory(); // Save state before clearing
    setState(() {
      droppedIcons.clear();
      drawnLines.clear();
      lineConnections.clear();
      selectedIcons.clear();
      selectedLines.clear();
      isDrawing = false;
      drawingStart = null;
      drawingEnd = null;
    });
    _saveDesign(); // Save the cleared state

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Canvas cleared', style: GoogleFonts.saira()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Undo/Redo functionality
  void _saveStateToHistory() {
    final state = CanvasState(
      icons: droppedIcons.map((icon) => icon.copy()).toList(),
      lines: drawnLines.map((line) => line.copy()).toList(),
      connections: Map<int, LineConnection>.from(lineConnections),
    );

    _undoStack.add(state);
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0); // Remove oldest state
    }

    // Clear redo stack when new action is performed
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;

    // Save current state to redo stack
    final currentState = CanvasState(
      icons: droppedIcons.map((icon) => icon.copy()).toList(),
      lines: drawnLines.map((line) => line.copy()).toList(),
      connections: Map<int, LineConnection>.from(lineConnections),
    );
    _redoStack.add(currentState);

    // Restore previous state
    final previousState = _undoStack.removeLast();
    setState(() {
      droppedIcons = previousState.icons.map((icon) => icon.copy()).toList();
      drawnLines = previousState.lines.map((line) => line.copy()).toList();
      lineConnections = Map<int, LineConnection>.from(
        previousState.connections,
      );
      selectedIcons.clear();
      selectedLines.clear();
    });

    _saveDesign();
  }

  void _redo() {
    if (_redoStack.isEmpty) return;

    // Save current state to undo stack
    final currentState = CanvasState(
      icons: droppedIcons.map((icon) => icon.copy()).toList(),
      lines: drawnLines.map((line) => line.copy()).toList(),
      connections: Map<int, LineConnection>.from(lineConnections),
    );
    _undoStack.add(currentState);

    // Restore next state
    final nextState = _redoStack.removeLast();
    setState(() {
      droppedIcons = nextState.icons.map((icon) => icon.copy()).toList();
      drawnLines = nextState.lines.map((line) => line.copy()).toList();
      lineConnections = Map<int, LineConnection>.from(nextState.connections);
      selectedIcons.clear();
      selectedLines.clear();
    });

    _saveDesign();
  }

  // The 14 data source icons - these are the starting points for data flow
  static const Set<String> dataSourceIcons = {
    // Primary Sources - User/Client Entry Points (7 icons)
    'Mobile Client',
    'Desktop Client',
    'Tablet Client',
    'Web Browser',
    'User',
    'Admin User',
    'Group Users',
    // External Data Sources (4 icons)
    'Third Party API',
    'Weather Service',
    'Social Media API',
    'GPS Tracking',
    // Internal Event Generators (3 icons)
    'Scheduler',
    'Alert System',
    'Push Notification',
  };

  // Get the set of line indices that should have active data flow
  // Data flow is only active if the line's tail icon is connected
  // (directly or indirectly) to one of the 14 data source icons
  Set<int> _getActiveDataFlowLines() {
    // Build a reverse graph: for each icon, which icons connect TO it (via valid green lines)
    // This allows us to trace backwards from any icon to see if it reaches a source
    Map<int, Set<int>> incomingConnections = {};

    // Build the reverse connection graph from valid (green) lines only
    for (final entry in lineConnections.entries) {
      final lineIndex = entry.key;
      final connection = entry.value;

      if (lineIndex >= drawnLines.length) continue;
      final line = drawnLines[lineIndex];
      if (line.color != Colors.green) continue;

      final tailIdx = connection.tailIconIndex;
      final headIdx = connection.headIconIndex;

      if (tailIdx != null && headIdx != null) {
        // headIcon can be reached FROM tailIcon
        // So in reverse: headIcon has incoming connection from tailIcon
        incomingConnections.putIfAbsent(headIdx, () => {});
        incomingConnections[headIdx]!.add(tailIdx);
      }
    }

    // Find all icons that ARE data sources (by name)
    Set<int> sourceIconIndices = {};
    for (int i = 0; i < droppedIcons.length; i++) {
      if (dataSourceIcons.contains(droppedIcons[i].name)) {
        sourceIconIndices.add(i);
      }
    }

    // BFS backwards: find all icons that can reach a source icon
    // Start from all icons and see which ones can trace back to a source
    Set<int> iconsReachableFromSource = Set.from(sourceIconIndices);
    List<int> queue = sourceIconIndices.toList();

    // We need to go FORWARD from sources to find all reachable icons
    // Build forward graph
    Map<int, Set<int>> outgoingConnections = {};
    for (final entry in lineConnections.entries) {
      final lineIndex = entry.key;
      final connection = entry.value;

      if (lineIndex >= drawnLines.length) continue;
      final line = drawnLines[lineIndex];
      if (line.color != Colors.green) continue;

      final tailIdx = connection.tailIconIndex;
      final headIdx = connection.headIconIndex;

      if (tailIdx != null && headIdx != null) {
        outgoingConnections.putIfAbsent(tailIdx, () => {});
        outgoingConnections[tailIdx]!.add(headIdx);
      }
    }

    // BFS forward from source icons to find all reachable icons
    while (queue.isNotEmpty) {
      final currentIcon = queue.removeAt(0);
      final nextIcons = outgoingConnections[currentIcon] ?? {};

      for (final nextIcon in nextIcons) {
        if (!iconsReachableFromSource.contains(nextIcon)) {
          iconsReachableFromSource.add(nextIcon);
          queue.add(nextIcon);
        }
      }
    }

    // A line should have data flow if:
    // 1. It's a valid (green) connection
    // 2. Its tail icon is reachable from a data source
    Set<int> activeLines = {};
    for (final entry in lineConnections.entries) {
      final lineIndex = entry.key;
      final connection = entry.value;

      if (lineIndex >= drawnLines.length) continue;
      final line = drawnLines[lineIndex];
      if (line.color != Colors.green) continue;

      final tailIdx = connection.tailIconIndex;
      if (tailIdx != null && iconsReachableFromSource.contains(tailIdx)) {
        activeLines.add(lineIndex);
      }
    }

    return activeLines;
  }

  // Build canvas validation data for the notebook
  CanvasValidationData _buildCanvasValidationData() {
    // Convert icons to validation format
    final icons =
        droppedIcons
            .map(
              (icon) => {
                'name': icon.name,
                'category': icon.category,
                'positionX': icon.position.dx,
                'positionY': icon.position.dy,
              },
            )
            .toList();

    // Convert connections to validation format
    final connections = <Map<String, dynamic>>[];
    for (final entry in lineConnections.entries) {
      final lineIndex = entry.key;
      final connection = entry.value;

      if (lineIndex < drawnLines.length) {
        final line = drawnLines[lineIndex];
        connections.add({
          'fromIconIndex': connection.tailIconIndex,
          'toIconIndex': connection.headIconIndex,
          'isGreen': line.color == Colors.green,
        });
      }
    }

    return CanvasValidationData(icons: icons, connections: connections);
  }

  // Update connections for all lines
  void _updateAllLineConnections() {
    for (int i = 0; i < drawnLines.length; i++) {
      _updateLineConnection(i);
    }
  }

  // Update connection for a specific line
  void _updateLineConnection(int lineIndex) {
    if (lineIndex >= drawnLines.length) return;

    final line = drawnLines[lineIndex];
    int? tailIconIndex;
    int? headIconIndex;

    // Find first icon intersecting with tail extension (closest to arrow start)
    if (line.extendedTailStart != null && line.extendedTailEnd != null) {
      tailIconIndex = _findFirstIconIntersectingLine(
        line.extendedTailStart!,
        line.extendedTailEnd!,
        referencePoint: line.start, // Find icon closest to arrow start
      );
    }

    // Find first icon intersecting with head extension (closest to arrow end)
    if (line.extendedHeadStart != null && line.extendedHeadEnd != null) {
      headIconIndex = _findFirstIconIntersectingLine(
        line.extendedHeadStart!,
        line.extendedHeadEnd!,
        referencePoint: line.end, // Find icon closest to arrow end
      );
    }

    // If both tail and head are connected to icons, snap the line to touch them
    if (tailIconIndex != null && headIconIndex != null) {
      final tailIcon = droppedIcons[tailIconIndex];
      final headIcon = droppedIcons[headIconIndex];

      // Get the visual centers of both icons
      final tailCenter = _getIconCenter(tailIcon);
      final headCenter = _getIconCenter(headIcon);

      // Calculate edge points: from tail icon towards head icon
      final newStart = _getClosestPointOnIconEdge(tailIcon, headCenter);

      // Calculate edge points: from head icon towards tail icon
      final newEnd = _getClosestPointOnIconEdge(headIcon, tailCenter);

      // Check if connecting the same icon instance to itself (always invalid)
      bool isValidConnection;
      if (tailIconIndex == headIconIndex) {
        // Same icon instance - ALWAYS invalid (red)
        isValidConnection = false;
        print('  ⚠️ Same icon instance connected to itself - INVALID');
      } else {
        // Different icon instances - validate the connection
        isValidConnection = SystemDesignIcons.isValidConnection(
          tailIcon.name,
          headIcon.name,
        );
      }

      // Set color based on validity: green for valid, red for invalid
      final connectionColor = isValidConnection ? Colors.green : Colors.red;

      // Update the line with new snapped positions and validation color
      // Don't use setState here, let the caller handle it
      drawnLines[lineIndex] = DrawnLine.withExtendedLines(
        start: newStart,
        end: newEnd,
        color: connectionColor,
        strokeWidth: line.strokeWidth,
        canvasWidth: 2000,
        canvasHeight: 1500,
      );

      print('Line $lineIndex snapped to connect icons:');
      print('  From ${tailIcon.name} at $newStart');
      print('  To ${headIcon.name} at $newEnd');
      print(
        '  Valid connection: $isValidConnection (${isValidConnection ? "GREEN" : "RED"})',
      );
    } else {
      // Line doesn't connect two icons - keep it gray/neutral
      drawnLines[lineIndex] = DrawnLine.withExtendedLines(
        start: line.start,
        end: line.end,
        color: Colors.grey,
        strokeWidth: line.strokeWidth,
        canvasWidth: 2000,
        canvasHeight: 1500,
      );
    }

    // Store the connection (after potentially updating the line)
    lineConnections[lineIndex] = LineConnection(
      lineIndex: lineIndex,
      tailIconIndex: tailIconIndex,
      headIconIndex: headIconIndex,
    );

    // Debug output
    if (tailIconIndex != null || headIconIndex != null) {
      print('Line $lineIndex connections:');
      if (tailIconIndex != null) {
        print('  Tail: ${droppedIcons[tailIconIndex].name}');
      }
      if (headIconIndex != null) {
        print('  Head: ${droppedIcons[headIconIndex].name}');
      }
    }
  }

  // Get the visual center of an icon (position is top-left corner)
  Offset _getIconCenter(DroppedIcon icon) {
    bool isInterfaceCategory =
        icon.category == 'Client & Interface' ||
        icon.category == 'Network & Communication';

    // Icon box size (not including label)
    final double iconSize = isInterfaceCategory ? 50.0 : 70.0;

    // The position is the top-left of the widget
    // The icon box center is at position + half the icon size
    return Offset(
      icon.position.dx + iconSize / 2,
      icon.position.dy + iconSize / 2,
    );
  }

  // Get the closest point on an icon's edge towards a target position
  Offset _getClosestPointOnIconEdge(DroppedIcon icon, Offset targetPosition) {
    // Get the actual visual center of the icon
    final iconCenter = _getIconCenter(icon);

    // Calculate direction from icon center to target
    final dx = targetPosition.dx - iconCenter.dx;
    final dy = targetPosition.dy - iconCenter.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance == 0) return iconCenter;

    // Normalize direction
    final dirX = dx / distance;
    final dirY = dy / distance;

    // Determine icon size based on category
    bool isInterfaceCategory =
        icon.category == 'Client & Interface' ||
        icon.category == 'Network & Communication';

    // Icon radius (half of the actual icon size to reach the edge)
    final double iconRadius = isInterfaceCategory ? 25.0 : 35.0;

    // Calculate point on the edge of the icon
    return Offset(
      iconCenter.dx + dirX * iconRadius,
      iconCenter.dy + dirY * iconRadius,
    );
  }

  // Find the first icon that intersects with a line segment
  int? _findFirstIconIntersectingLine(
    Offset lineStart,
    Offset lineEnd, {
    Offset? referencePoint,
  }) {
    double minDistance = double.infinity;
    int? closestIconIndex;

    // Use the reference point if provided, otherwise use lineStart
    final refPoint = referencePoint ?? lineStart;

    for (int i = 0; i < droppedIcons.length; i++) {
      final icon = droppedIcons[i];

      // Get the actual visual center of the icon
      final iconCenter = _getIconCenter(icon);

      // Determine icon size for rect calculation
      bool isInterfaceCategory =
          icon.category == 'Client & Interface' ||
          icon.category == 'Network & Communication';
      final double iconSize = isInterfaceCategory ? 50.0 : 70.0;

      // Create a rect for the icon centered on its visual center with generous padding
      final iconRect = Rect.fromCenter(
        center: iconCenter,
        width: iconSize + 20, // Icon size plus padding for detection
        height: iconSize + 20,
      );

      // Also check distance from line to icon center as additional detection method
      final distanceToIcon = _distanceFromPointToLineSegment(
        iconCenter,
        lineStart,
        lineEnd,
      );

      // Check if the line intersects with the icon's bounding box OR is very close
      if (_lineIntersectsRect(lineStart, lineEnd, iconRect) ||
          distanceToIcon < 50) {
        // Calculate distance from reference point to icon center
        final distance = (iconCenter - refPoint).distance;

        if (distance < minDistance) {
          minDistance = distance;
          closestIconIndex = i;
        }
      }
    }

    return closestIconIndex;
  }

  // Calculate minimum distance from a point to a line segment
  double _distanceFromPointToLineSegment(
    Offset point,
    Offset lineStart,
    Offset lineEnd,
  ) {
    final A = lineStart;
    final B = lineEnd;
    final P = point;

    final AB = Offset(B.dx - A.dx, B.dy - A.dy);
    final AP = Offset(P.dx - A.dx, P.dy - A.dy);

    final abSquared = AB.dx * AB.dx + AB.dy * AB.dy;

    if (abSquared == 0) {
      // A and B are the same point
      return (P - A).distance;
    }

    final t = (AP.dx * AB.dx + AP.dy * AB.dy) / abSquared;
    final clampedT = t.clamp(0.0, 1.0);

    final closestPoint = Offset(
      A.dx + clampedT * AB.dx,
      A.dy + clampedT * AB.dy,
    );

    return (P - closestPoint).distance;
  }

  // Check if a line segment intersects with a rectangle
  bool _lineIntersectsRect(Offset lineStart, Offset lineEnd, Rect rect) {
    // Expand the rect slightly for more forgiving detection
    final expandedRect = rect.inflate(5);

    // Check if either endpoint is inside the rect
    if (expandedRect.contains(lineStart) || expandedRect.contains(lineEnd)) {
      return true;
    }

    // Check if line passes through the center area
    final center = expandedRect.center;
    final distToCenter = _distanceFromPointToLineSegment(
      center,
      lineStart,
      lineEnd,
    );
    if (distToCenter < expandedRect.width / 2) {
      return true;
    }

    // Check intersection with each edge of the rectangle
    final topLeft = expandedRect.topLeft;
    final topRight = expandedRect.topRight;
    final bottomLeft = expandedRect.bottomLeft;
    final bottomRight = expandedRect.bottomRight;

    return _linesIntersect(lineStart, lineEnd, topLeft, topRight) ||
        _linesIntersect(lineStart, lineEnd, topRight, bottomRight) ||
        _linesIntersect(lineStart, lineEnd, bottomRight, bottomLeft) ||
        _linesIntersect(lineStart, lineEnd, bottomLeft, topLeft);
  }

  // Check if two line segments intersect
  bool _linesIntersect(Offset a1, Offset a2, Offset b1, Offset b2) {
    final denom =
        ((b2.dy - b1.dy) * (a2.dx - a1.dx)) -
        ((b2.dx - b1.dx) * (a2.dy - a1.dy));

    if (denom == 0) return false; // Lines are parallel

    final ua =
        (((b2.dx - b1.dx) * (a1.dy - b1.dy)) -
            ((b2.dy - b1.dy) * (a1.dx - b1.dx))) /
        denom;
    final ub =
        (((a2.dx - a1.dx) * (a1.dy - b1.dy)) -
            ((a2.dy - a1.dy) * (a1.dx - b1.dx))) /
        denom;

    return (ua >= 0 && ua <= 1) && (ub >= 0 && ub <= 1);
  }

  // Check if a point is near a line (for line selection)
  bool _isPointNearLine(
    Offset point,
    DrawnLine line, {
    double tolerance = 10.0,
  }) {
    // Calculate distance from point to line segment
    final A = line.start;
    final B = line.end;
    final P = point;

    final AB = Offset(B.dx - A.dx, B.dy - A.dy);
    final AP = Offset(P.dx - A.dx, P.dy - A.dy);

    final abSquared = AB.dx * AB.dx + AB.dy * AB.dy;

    if (abSquared == 0) {
      // A and B are the same point
      return (P - A).distance <= tolerance;
    }

    final t = (AP.dx * AB.dx + AP.dy * AB.dy) / abSquared;
    final clampedT = t.clamp(0.0, 1.0);

    final closestPoint = Offset(
      A.dx + clampedT * AB.dx,
      A.dy + clampedT * AB.dy,
    );

    return (P - closestPoint).distance <= tolerance;
  }

  // Find line index at given point
  int? _findLineAtPoint(Offset point) {
    for (int i = drawnLines.length - 1; i >= 0; i--) {
      if (_isPointNearLine(point, drawnLines[i])) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SafeArea(
        child: Column(
          children: [
            // Top header with back button and title
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D2817), Color(0xFF2C1810)],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFFFE4B5).withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFFFFE4B5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.systemName} Design',
                      style: GoogleFonts.saira(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFE4B5),
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.architecture,
                    color: Color(0xFFFF6B35),
                    size: 28,
                  ),
                ],
              ),
            ),

            // Horizontal category selector
            Container(
              height: 140, // Increased from 120 to 140
              decoration: BoxDecoration(
                color: const Color(0xFF3D2817).withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFFFE4B5).withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: SystemDesignIcons.getIconsByCategory().length,
                itemBuilder: (context, index) {
                  final categories = SystemDesignIcons.getIconsByCategory();
                  final categoryName = categories.keys.elementAt(index);
                  final isExpanded = expandedCategories.contains(categoryName);

                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color:
                          isExpanded
                              ? _getCategoryColor(categoryName).withOpacity(0.3)
                              : const Color(0xFF4A3420),
                      borderRadius: BorderRadius.circular(0), // Pixel style
                      border: Border.all(
                        color:
                            isExpanded
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFFFFE4B5),
                        width: isExpanded ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 0,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            expandedCategories.remove(categoryName);
                          } else {
                            expandedCategories
                                .clear(); // Only allow one category open at a time
                            expandedCategories.add(categoryName);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCategoryIcon(categoryName),
                              color:
                                  isExpanded
                                      ? const Color(0xFFFF6B35)
                                      : const Color(0xFFFFE4B5),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categoryName,
                              style: GoogleFonts.saira(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFE4B5),
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Expanded category icons (when a category is selected)
            if (expandedCategories.isNotEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    expandedCategories.first,
                  ).withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true, // Always show scrollbar
                  trackVisibility: true, // Show scroll track
                  child: ListView.builder(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    physics:
                        const BouncingScrollPhysics(), // Better scroll physics
                    itemCount:
                        SystemDesignIcons.getIconsByCategory()[expandedCategories
                                .first]!
                            .length,
                    itemBuilder: (context, index) {
                      final categoryName = expandedCategories.first;
                      final icons =
                          SystemDesignIcons.getIconsByCategory()[categoryName]!;
                      final iconEntry = icons.entries.elementAt(index);

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: LongPressDraggable<IconDropData>(
                          data: IconDropData(
                            name: iconEntry.key,
                            icon: iconEntry.value,
                            category: categoryName,
                          ),
                          delay: const Duration(
                            milliseconds: 200,
                          ), // Short delay before drag starts
                          feedback: _buildIconWidget(
                            iconEntry.key,
                            iconEntry.value,
                            categoryName,
                            isDragging: true,
                          ),
                          childWhenDragging: _buildIconWidget(
                            iconEntry.key,
                            iconEntry.value,
                            categoryName,
                            isDragging: true,
                            isPlaceholder: true,
                          ),
                          child: _buildIconWidget(
                            iconEntry.key,
                            iconEntry.value,
                            categoryName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ), // Canvas area with free positioning
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A0F09), // Darker cozy brown
                      Color(0xFF2C1810), // Base cozy brown
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        InteractiveViewer(
                          transformationController: _transformationController,
                          boundaryMargin: const EdgeInsets.all(20),
                          minScale: 0.1, // Allow zooming out to see full design
                          maxScale: 3.0, // Allow zooming in for detail work
                          constrained:
                              false, // Allow content to be larger than viewport
                          child: Container(
                            // Make canvas larger than screen to allow scrolling/zooming
                            width: math.max(
                              constraints.maxWidth,
                              2000,
                            ), // Larger canvas
                            height: math.max(
                              constraints.maxHeight,
                              1500,
                            ), // Larger canvas
                            child: DragTarget<IconDropData>(
                              onWillAccept: (data) => true,
                              onAcceptWithDetails: (details) {
                                final RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                final Offset localPosition = renderBox
                                    .globalToLocal(details.offset);

                                setState(() {
                                  // Transform the position to account for zoom and pan
                                  final Matrix4 transform =
                                      _transformationController.value;
                                  final Matrix4 invertedTransform =
                                      Matrix4.inverted(transform);
                                  final vector.Vector3 transformed =
                                      invertedTransform.transform3(
                                        vector.Vector3(
                                          localPosition.dx,
                                          localPosition.dy,
                                          0,
                                        ),
                                      );

                                  final transformedPosition = Offset(
                                    transformed.x,
                                    transformed.y,
                                  );

                                  droppedIcons.add(
                                    DroppedIcon(
                                      name: details.data.name,
                                      icon: details.data.icon,
                                      category: details.data.category,
                                      position: Offset(
                                        transformedPosition.dx.clamp(
                                          0,
                                          2000 -
                                              80, // Use expanded canvas width
                                        ),
                                        transformedPosition.dy.clamp(
                                          20,
                                          1500 -
                                              80, // Use expanded canvas height
                                        ),
                                      ),
                                    ),
                                  );
                                  // Update all line connections after adding an icon
                                  _updateAllLineConnections();
                                });
                                _saveStateToHistory(); // Save state after adding icon
                                _saveDesign(); // Auto-save after icon is added
                              },
                              builder: (context, candidateData, rejectedData) {
                                return GestureDetector(
                                  onTapDown: (details) {
                                    // Handle both icon and line selection when not in drawing mode
                                    if (!isDrawingMode && !isDrawing) {
                                      final RenderBox renderBox =
                                          context.findRenderObject()
                                              as RenderBox;
                                      final Offset localPosition = renderBox
                                          .globalToLocal(
                                            details.globalPosition,
                                          );

                                      bool tappedOnSomething = false;

                                      // Check if tap is on an icon first
                                      for (
                                        int i = 0;
                                        i < droppedIcons.length;
                                        i++
                                      ) {
                                        final icon = droppedIcons[i];
                                        final iconRect = Rect.fromLTWH(
                                          icon.position.dx - 25,
                                          icon.position.dy - 25,
                                          50,
                                          50,
                                        );
                                        if (iconRect.contains(localPosition)) {
                                          setState(() {
                                            if (selectedIcons.contains(i)) {
                                              selectedIcons.remove(i);
                                            } else {
                                              selectedIcons.add(i);
                                            }
                                            // Clear line selection when selecting icons
                                            selectedLines.clear();
                                          });
                                          tappedOnSomething = true;
                                          break;
                                        }
                                      }

                                      // If didn't tap on icon, check if tap is on a line
                                      if (!tappedOnSomething) {
                                        final lineIndex = _findLineAtPoint(
                                          localPosition,
                                        );
                                        if (lineIndex != null) {
                                          setState(() {
                                            if (selectedLines.contains(
                                              lineIndex,
                                            )) {
                                              selectedLines.remove(lineIndex);
                                            } else {
                                              selectedLines.add(lineIndex);
                                            }
                                            // Clear icon selection when selecting lines
                                            selectedIcons.clear();
                                          });
                                          tappedOnSomething = true;
                                        }
                                      }

                                      // If didn't tap on anything, clear all selections
                                      if (!tappedOnSomething) {
                                        setState(() {
                                          selectedIcons.clear();
                                          selectedLines.clear();
                                        });
                                      }
                                    }
                                  },
                                  onPanStart:
                                      isDrawingMode
                                          ? (details) {
                                            final RenderBox renderBox =
                                                context.findRenderObject()
                                                    as RenderBox;
                                            final Offset localPosition =
                                                renderBox.globalToLocal(
                                                  details.globalPosition,
                                                );

                                            setState(() {
                                              isDrawing = true;
                                              drawingStart = localPosition;
                                              drawingEnd = localPosition;
                                            });
                                          }
                                          : null,
                                  onPanUpdate:
                                      isDrawingMode
                                          ? (details) {
                                            if (isDrawing) {
                                              final RenderBox renderBox =
                                                  context.findRenderObject()
                                                      as RenderBox;
                                              final Offset localPosition =
                                                  renderBox.globalToLocal(
                                                    details.globalPosition,
                                                  );

                                              setState(() {
                                                drawingEnd = localPosition;
                                              });
                                            }
                                          }
                                          : null,
                                  onPanEnd:
                                      isDrawingMode
                                          ? (details) {
                                            if (isDrawing &&
                                                drawingStart != null &&
                                                drawingEnd != null) {
                                              // Add the completed line with extended lines
                                              setState(() {
                                                drawnLines.add(
                                                  DrawnLine.withExtendedLines(
                                                    start: drawingStart!,
                                                    end: drawingEnd!,
                                                    color:
                                                        Colors
                                                            .grey, // Initial color, will be updated
                                                    strokeWidth: 2.0,
                                                    canvasWidth: 2000,
                                                    canvasHeight: 1500,
                                                  ),
                                                );
                                                // Update connection for the newly added line
                                                // This will validate and set the color
                                                _updateLineConnection(
                                                  drawnLines.length - 1,
                                                );
                                                isDrawing = false;
                                                drawingStart = null;
                                                drawingEnd = null;
                                                // Clear any selections when drawing
                                                selectedIcons.clear();
                                                selectedLines.clear();
                                              });
                                              _saveStateToHistory(); // Save state after drawing line
                                              _saveDesign(); // Save after drawing a line
                                            }
                                          }
                                          : null,
                                  child: Stack(
                                    children: [
                                      // Canvas background with grid
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: CustomPaint(
                                          painter: GridPainter(),
                                        ),
                                      ),

                                      // Line drawing layer with data flow animation
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: AnimatedBuilder(
                                          animation:
                                              _dataFlowAnimationController,
                                          builder: (context, child) {
                                            // Calculate which lines should have active data flow
                                            final activeLines =
                                                _getActiveDataFlowLines();
                                            return CustomPaint(
                                              painter: LinePainter(
                                                lines: drawnLines,
                                                selectedLineIndices:
                                                    selectedLines,
                                                activeDataFlowLines:
                                                    activeLines,
                                                currentStart: drawingStart,
                                                currentEnd: drawingEnd,
                                                showExtendedLines:
                                                    showExtendedLines,
                                                dataFlowProgress:
                                                    _dataFlowAnimationController
                                                        .value,
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // Canvas header
                                      Positioned(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3D2817),
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ), // Pixel style
                                            border: Border.all(
                                              color: const Color(0xFFFFE4B5),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                blurRadius: 0,
                                                offset: const Offset(3, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.architecture,
                                                color: Color(0xFFFF6B35),
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                isDrawingMode
                                                    ? 'Drawing Mode: Drag to draw lines'
                                                    : 'Drag and Drop Components Here',
                                                style: GoogleFonts.saira(
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isDrawingMode
                                                            ? const Color(
                                                              0xFFFF6B35,
                                                            )
                                                            : const Color(
                                                              0xFFFFE4B5,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Connection count indicator
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      drawnLines.isEmpty
                                                          ? const Color(
                                                            0xFF4A3420,
                                                          )
                                                          : const Color(
                                                            0xFF228B22,
                                                          ).withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        0,
                                                      ), // Pixel style
                                                  border: Border.all(
                                                    color:
                                                        drawnLines.isEmpty
                                                            ? const Color(
                                                              0xFFFFE4B5,
                                                            ).withOpacity(0.5)
                                                            : const Color(
                                                              0xFF228B22,
                                                            ),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      color: const Color(
                                                        0xFFFFE4B5,
                                                      ),
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      '${drawnLines.length} connections',
                                                      style: GoogleFonts.saira(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Selection status overlay
                                      if (selectedIcons.isNotEmpty ||
                                          selectedLines.isNotEmpty)
                                        Positioned(
                                          top: 80,
                                          left: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.yellow.withOpacity(
                                                0.9,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.orange,
                                                width: 2,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.black,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${selectedIcons.length} icons, ${selectedLines.length} lines selected',
                                                  style: GoogleFonts.saira(
                                                    textStyle: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      // Instruction overlay for selection
                                      if ((droppedIcons.isNotEmpty ||
                                              drawnLines.isNotEmpty) &&
                                          selectedIcons.isEmpty &&
                                          selectedLines.isEmpty &&
                                          !isDrawingMode)
                                        Positioned(
                                          top: 120,
                                          left: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.lightBlue,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.touch_app,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Tap on icons or lines to select and delete them',
                                                  style: GoogleFonts.saira(
                                                    textStyle: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      // Dropped icons with free positioning
                                      ...droppedIcons.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final droppedIcon = entry.value;

                                        return Positioned(
                                          left: droppedIcon.position.dx,
                                          top: droppedIcon.position.dy,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (selectedIcons.contains(
                                                  index,
                                                )) {
                                                  selectedIcons.remove(index);
                                                } else {
                                                  selectedIcons.add(index);
                                                }
                                              });
                                            },
                                            child: Draggable<int>(
                                              data:
                                                  index, // Pass the index to identify which icon is being dragged
                                              feedback: Transform.scale(
                                                scale:
                                                    1.1, // Slightly larger when dragging
                                                child: Opacity(
                                                  opacity: 0.8,
                                                  child: _buildCanvasIconWidget(
                                                    droppedIcon.name,
                                                    droppedIcon.icon,
                                                    droppedIcon.category,
                                                    isSelected: selectedIcons
                                                        .contains(index),
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity:
                                                    0.3, // Semi-transparent placeholder
                                                child: _buildCanvasIconWidget(
                                                  droppedIcon.name,
                                                  droppedIcon.icon,
                                                  droppedIcon.category,
                                                  isSelected: selectedIcons
                                                      .contains(index),
                                                ),
                                              ),
                                              onDragEnd: (details) {
                                                // Update position when drag ends - drop exactly where released
                                                final RenderBox renderBox =
                                                    context.findRenderObject()
                                                        as RenderBox;
                                                final Offset localPosition =
                                                    renderBox.globalToLocal(
                                                      details.offset,
                                                    );

                                                setState(() {
                                                  // For repositioning within canvas, use direct localPosition
                                                  // The drag happens within the transformed coordinate system
                                                  final newPosition = Offset(
                                                    localPosition.dx.clamp(
                                                      0,
                                                      2000 -
                                                          80, // Use expanded canvas width
                                                    ),
                                                    localPosition.dy.clamp(
                                                      20,
                                                      1500 -
                                                          80, // Use expanded canvas height
                                                    ),
                                                  );

                                                  droppedIcons[index] =
                                                      DroppedIcon(
                                                        name: droppedIcon.name,
                                                        icon: droppedIcon.icon,
                                                        category:
                                                            droppedIcon
                                                                .category,
                                                        position: newPosition,
                                                      );
                                                  // Update all line connections after moving an icon
                                                  _updateAllLineConnections();
                                                });
                                                _saveStateToHistory(); // Save state after moving icon
                                                _saveDesign(); // Auto-save after icon is moved
                                              },
                                              child: _buildCanvasIconWidget(
                                                droppedIcon.name,
                                                droppedIcon.icon,
                                                droppedIcon.category,
                                                isSelected: selectedIcons
                                                    .contains(index),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),

                                      // Drop hint when dragging
                                      if (candidateData.isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: const Color(
                                            0xFFFF6B35,
                                          ).withOpacity(0.1),
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF3D2817,
                                                ).withOpacity(0.9),
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFFF6B35,
                                                  ),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Text(
                                                'Drop here to add to canvas',
                                                style: GoogleFonts.saira(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFFFE4B5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Debug panel for connection data - HIDDEN
                        if (false) // Hide debug panel
                          Positioned(
                            top: 180,
                            left: 16,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 350,
                                maxHeight: 400,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.greenAccent,
                                  width: 2,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.bug_report,
                                          color: Colors.greenAccent,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'DEBUG: Connection Data',
                                          style: GoogleFonts.saira(
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.greenAccent.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    SizedBox(height: 8),

                                    // Icons section
                                    Text(
                                      'Icons on Canvas: ${droppedIcons.length}',
                                      style: GoogleFonts.saira(
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    ...droppedIcons.asMap().entries.map((
                                      entry,
                                    ) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          bottom: 2,
                                        ),
                                        child: Text(
                                          '[${entry.key}] ${entry.value.name}',
                                          style: GoogleFonts.saira(
                                            textStyle: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    SizedBox(height: 12),

                                    // Lines section
                                    Text(
                                      'Lines/Arrows: ${drawnLines.length}',
                                      style: GoogleFonts.saira(
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),

                                    // Connection details
                                    if (lineConnections.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          'No connections detected',
                                          style: GoogleFonts.saira(
                                            textStyle: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ...lineConnections.entries.map((entry) {
                                        final lineIndex = entry.key;
                                        final connection = entry.value;

                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: 8,
                                            left: 8,
                                          ),
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(
                                                0.5,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Line $lineIndex',
                                                style: GoogleFonts.saira(
                                                  textStyle: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.lightBlue,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.arrow_back,
                                                    size: 12,
                                                    color: Colors.orange,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      connection.tailIconIndex !=
                                                              null
                                                          ? 'Tail: [${connection.tailIconIndex}] ${droppedIcons[connection.tailIconIndex!].name}'
                                                          : 'Tail: None',
                                                      style: GoogleFonts.saira(
                                                        textStyle: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              connection.tailIconIndex !=
                                                                      null
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.arrow_forward,
                                                    size: 12,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      connection.headIconIndex !=
                                                              null
                                                          ? 'Head: [${connection.headIconIndex}] ${droppedIcons[connection.headIconIndex!].name}'
                                                          : 'Head: None',
                                                      style: GoogleFonts.saira(
                                                        textStyle: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              connection.headIconIndex !=
                                                                      null
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Zoom controls overlay
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Compare with Demos button (NEW - at the top)
                              SizedBox(
                                height: 30,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Get current canvas data with connection info
                                    final iconsData =
                                        droppedIcons
                                            .map((icon) => icon.toJson())
                                            .toList();

                                    // Build connections list from lineConnections map
                                    final connectionsData =
                                        <Map<String, dynamic>>[];
                                    lineConnections.forEach((
                                      lineIndex,
                                      connection,
                                    ) {
                                      if (connection.tailIconIndex != null &&
                                          connection.headIconIndex != null) {
                                        connectionsData.add({
                                          'fromIconIndex':
                                              connection.tailIconIndex,
                                          'toIconIndex':
                                              connection.headIconIndex,
                                        });
                                      }
                                    });

                                    showDesignComparisonDialog(
                                      context: context,
                                      systemName: widget.systemName,
                                      userIcons: iconsData,
                                      userConnections: connectionsData,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D2817),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: const BorderSide(
                                        color: Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.compare_arrows,
                                    size: 14,
                                    color: Color(0xFFFF6B35),
                                  ),
                                  label: const Text(
                                    'Compare designs',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Clear button
                              SizedBox(
                                height: 30,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showClearConfirmationDialog();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B0000),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: const BorderSide(
                                        color: Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.clear_all, size: 14),
                                  label: const Text(
                                    'Clear All',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Undo/Redo buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Undo button
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: ElevatedButton(
                                      onPressed:
                                          _undoStack.isEmpty ? null : _undo,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _undoStack.isEmpty
                                                ? const Color(0xFF4A3420)
                                                : const Color(0xFF3D2817),
                                        foregroundColor: const Color(
                                          0xFFFFE4B5,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                          side: BorderSide(
                                            color:
                                                _undoStack.isEmpty
                                                    ? const Color(
                                                      0xFFFFE4B5,
                                                    ).withOpacity(0.3)
                                                    : const Color(0xFFFFE4B5),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.undo,
                                        size: 14,
                                        color:
                                            _undoStack.isEmpty
                                                ? const Color(
                                                  0xFFFFE4B5,
                                                ).withOpacity(0.3)
                                                : const Color(0xFFFF6B35),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Redo button
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: ElevatedButton(
                                      onPressed:
                                          _redoStack.isEmpty ? null : _redo,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _redoStack.isEmpty
                                                ? const Color(0xFF4A3420)
                                                : const Color(0xFF3D2817),
                                        foregroundColor: const Color(
                                          0xFFFFE4B5,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                          side: BorderSide(
                                            color:
                                                _redoStack.isEmpty
                                                    ? const Color(
                                                      0xFFFFE4B5,
                                                    ).withOpacity(0.3)
                                                    : const Color(0xFFFFE4B5),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.redo,
                                        size: 14,
                                        color:
                                            _redoStack.isEmpty
                                                ? const Color(
                                                  0xFFFFE4B5,
                                                ).withOpacity(0.3)
                                                : const Color(0xFFFF6B35),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Library button
                              SizedBox(
                                height: 30,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) =>
                                              const IconLibraryDialog(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D2817),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: const BorderSide(
                                        color: Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.library_books,
                                    size: 14,
                                    color: Color(0xFFFF6B35),
                                  ),
                                  label: const Text(
                                    'Icon Library',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Delete button (positioned above drawing button)
                              if (selectedIcons.isNotEmpty ||
                                  selectedLines.isNotEmpty)
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _deleteSelectedIcons();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B0000),
                                      foregroundColor: const Color(0xFFFFE4B5),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                        side: const BorderSide(
                                          color: Color(0xFFFFE4B5),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      size: 14,
                                      color: Color(0xFFFFE4B5),
                                    ),
                                  ),
                                ),
                              if (selectedIcons.isNotEmpty ||
                                  selectedLines.isNotEmpty)
                                const SizedBox(height: 10),
                              // Drawing mode toggle button
                              SizedBox(
                                height: 30,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isDrawingMode = !isDrawingMode;
                                      selectedIcons
                                          .clear(); // Clear selections when switching modes
                                      selectedLines.clear();
                                      // Cancel any ongoing drawing
                                      isDrawing = false;
                                      drawingStart = null;
                                      drawingEnd = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isDrawingMode
                                            ? const Color(0xFF2E5930)
                                            : const Color(0xFF3D2817),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(
                                        color:
                                            isDrawingMode
                                                ? const Color(0xFF90EE90)
                                                : const Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color:
                                        isDrawingMode
                                            ? const Color(0xFF90EE90)
                                            : const Color(0xFFFF6B35),
                                  ),
                                  label: const Text(
                                    'Connect',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Debug button to check stored data - HIDDEN
                              // FloatingActionButton.small(
                              //   heroTag: "debug_check",
                              //   onPressed: () async {
                              //     await _debugCheckStoredData();
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(
                              //         content: Text(
                              //           'Current: ${drawnLines.length} connections\nCheck console for stored data',
                              //         ),
                              //         duration: Duration(seconds: 3),
                              //       ),
                              //     );
                              //   },
                              //   backgroundColor: Colors.orange.withOpacity(0.8),
                              //   child: const Icon(
                              //     Icons.bug_report,
                              //     color: Colors.white,
                              //   ),
                              //   tooltip: 'Debug: Check Stored Data',
                              // ),
                              // const SizedBox(height: 10),
                              SizedBox(
                                height: 30,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Build canvas validation data
                                    final canvasData =
                                        _buildCanvasValidationData();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) => SystemDescriptionNotebook(
                                              systemId: widget.systemName
                                                  .toLowerCase()
                                                  .replaceAll(' ', '_'),
                                              systemName: widget.systemName,
                                              usedComponents:
                                                  droppedIcons
                                                      .map((icon) => icon.name)
                                                      .toList(),
                                              onSubmitDesign:
                                                  widget
                                                      .onSubmitDesign, // Pass the callback
                                              canvasData:
                                                  canvasData, // Pass canvas data for validation
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D2817),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: const BorderSide(
                                        color: Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.description,
                                    size: 14,
                                    color: Color(0xFFFF6B35),
                                  ),
                                  label: const Text(
                                    'Add Description',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final Matrix4 matrix =
                                        _transformationController.value.clone();
                                    matrix.scale(1.2); // Zoom in by 20%
                                    _transformationController.value = matrix;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D2817),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: const BorderSide(
                                        color: Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.zoom_in,
                                    size: 14,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final Matrix4 matrix =
                                        _transformationController.value.clone();
                                    matrix.scale(0.8); // Zoom out by 20%
                                    _transformationController.value = matrix;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D2817),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: const BorderSide(
                                        color: Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.zoom_out,
                                    size: 14,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _transformationController.value =
                                        Matrix4.identity();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D2817),
                                    foregroundColor: const Color(0xFFFFE4B5),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: const BorderSide(
                                        color: Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.fit_screen,
                                    size: 14,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                              ),
                              // Submit Design Button removed - now handled by notebook submit
                              // Users can submit for AI evaluation via the notes button
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get design notes for submission to AI evaluation

  // Helper function to split text into multiple lines for better readability
  List<String> _splitTextIntoLines(String text) {
    // Split by spaces and group into lines
    List<String> words = text.split(' ');
    if (words.length <= 1) return [text];

    // For 2 words, put each on separate line
    if (words.length == 2) return words;

    // For more words, try to balance the lines
    List<String> lines = [];
    int midPoint = (words.length / 2).ceil();
    lines.add(words.sublist(0, midPoint).join(' '));
    lines.add(words.sublist(midPoint).join(' '));

    return lines;
  }

  Widget _buildIconWidget(
    String name,
    IconData icon,
    String category, {
    bool isDragging = false,
    bool isPlaceholder = false,
  }) {
    // Make Client Interface and Network Communication icons smaller
    bool isInterfaceCategory =
        category == 'Client & Interface' ||
        category == 'Network & Communication';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color:
            isPlaceholder
                ? Colors.grey.withOpacity(0.3)
                : _getCategoryColor(
                  category,
                ).withOpacity(isDragging ? 0.9 : 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getCategoryColor(category),
          width: isDragging ? 2 : 1,
        ),
        boxShadow:
            isDragging
                ? [
                  BoxShadow(
                    color: _getCategoryColor(category).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isPlaceholder ? Colors.grey : Colors.white,
            size:
                isInterfaceCategory
                    ? (isDragging
                        ? 16
                        : 12) // Much smaller icons for interface categories
                    : (isDragging ? 24 : 20),
          ),
          const SizedBox(height: 2),
          Column(
            mainAxisSize: MainAxisSize.min,
            children:
                _splitTextIntoLines(name)
                    .map(
                      (line) => Text(
                        line.length > 6 ? '${line.substring(0, 5)}..' : line,
                        style: TextStyle(
                          fontSize: 7,
                          color: isPlaceholder ? Colors.grey : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasIconWidget(
    String name,
    IconData icon,
    String category, {
    bool isSelected = false,
  }) {
    // Make Client Interface and Network Communication icons smaller
    bool isInterfaceCategory =
        category == 'Client & Interface' ||
        category == 'Network & Communication';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isInterfaceCategory ? 50 : 70, // Smaller for interface icons
          height: isInterfaceCategory ? 50 : 70,
          decoration: BoxDecoration(
            color: _getCategoryColor(
              category,
            ).withOpacity(isSelected ? 1.0 : 0.8),
            borderRadius: BorderRadius.circular(0), // Pixel style
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFFFE4B5),
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isSelected
                        ? const Color(0xFFFF6B35).withOpacity(0.5)
                        : Colors.black.withOpacity(0.5),
                blurRadius: 0, // Pixel style - no blur
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size:
                isInterfaceCategory
                    ? 16
                    : 28, // Much smaller icon for interface categories
          ),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF3D2817),
            borderRadius: BorderRadius.circular(0), // Pixel style
            border: Border.all(
              color: const Color(0xFFFFE4B5).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                _splitTextIntoLines(name)
                    .map(
                      (line) => Text(
                        line,
                        style: GoogleFonts.saira(
                          textStyle: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFFFFE4B5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Client & Interface':
        return Colors.blue;
      case 'Networking':
        return Colors.green;
      case 'Servers & Computing':
        return Colors.orange;
      case 'Database & Storage':
        return Colors.red;
      case 'Caching,Performance':
        return Colors.purple;
      case 'Message Systems':
        return Colors.amber;
      case 'Security,Monitoring':
        return Colors.indigo;
      case 'Cloud,Infrastructure':
        return Colors.cyan;
      case 'System Utilities':
        return Colors.brown;
      case 'Data Processing':
        return Colors.teal;
      case 'External Services':
        return Colors.pink;
      case 'Application Services':
        return Colors.deepOrange;
      case 'Geospatial & Location':
        return Colors.lime;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Client & Interface':
        return Icons.devices;
      case 'Networking':
        return Icons.network_check;
      case 'Servers & Computing':
        return Icons.dns;
      case 'Database & Storage':
        return Icons.storage;
      case 'Caching,Performance':
        return Icons.speed;
      case 'Message Systems':
        return Icons.message;
      case 'Security,Monitoring':
        return Icons.security;
      case 'Cloud,Infrastructure':
        return Icons.cloud_queue;
      case 'System Utilities':
        return Icons.build;
      case 'Data Processing':
        return Icons.data_usage;
      case 'External Services':
        return Icons.extension;
      case 'Application Services':
        return Icons.apps;
      case 'Geospatial & Location':
        return Icons.location_on;
      default:
        return Icons.category;
    }
  }
}

// Data class for drag and drop
class IconDropData {
  final String name;
  final IconData icon;
  final String category;

  IconDropData({
    required this.name,
    required this.icon,
    required this.category,
  });
}

// Class for dropped icons on canvas
class DroppedIcon {
  final String name;
  final IconData icon;
  final String category;
  final Offset position;

  DroppedIcon({
    required this.name,
    required this.icon,
    required this.category,
    required this.position,
  });

  // Convert to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'category': category,
      'positionX': position.dx,
      'positionY': position.dy,
    };
  }

  // Create from JSON for loading
  factory DroppedIcon.fromJson(Map<String, dynamic> json) {
    return DroppedIcon(
      name: json['name'],
      icon: IconData(json['iconCodePoint'], fontFamily: json['iconFontFamily']),
      category: json['category'],
      position: Offset(
        json['positionX'].toDouble(),
        json['positionY'].toDouble(),
      ),
    );
  }

  // Create a copy for undo/redo
  DroppedIcon copy() {
    return DroppedIcon(
      name: name,
      icon: icon,
      category: category,
      position: position,
    );
  }
}

// Custom painter for grid background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Class to store line connection information
class LineConnection {
  final int lineIndex;
  final int? tailIconIndex;
  final int? headIconIndex;

  LineConnection({
    required this.lineIndex,
    this.tailIconIndex,
    this.headIconIndex,
  });

  @override
  String toString() {
    return 'LineConnection(lineIndex: $lineIndex, tailIcon: $tailIconIndex, headIcon: $headIconIndex)';
  }
}

// Class to represent a drawn line between points
class DrawnLine {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  // Extended line endpoints that go across the entire canvas
  final Offset? extendedTailStart;
  final Offset? extendedTailEnd;
  final Offset? extendedHeadStart;
  final Offset? extendedHeadEnd;

  DrawnLine({
    required this.start,
    required this.end,
    this.color = Colors.blue,
    this.strokeWidth = 2.0,
    this.extendedTailStart,
    this.extendedTailEnd,
    this.extendedHeadStart,
    this.extendedHeadEnd,
  });

  // Calculate extended lines across the canvas
  factory DrawnLine.withExtendedLines({
    required Offset start,
    required Offset end,
    Color color = Colors.blue,
    double strokeWidth = 2.0,
    double canvasWidth = 2000,
    double canvasHeight = 1500,
  }) {
    // Calculate the direction vector
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);

    if (length == 0) {
      return DrawnLine(
        start: start,
        end: end,
        color: color,
        strokeWidth: strokeWidth,
      );
    }

    // Normalize the direction vector
    final dirX = dx / length;
    final dirY = dy / length;

    // Extended line from tail (start point) - extends backwards
    final tailExtendedStart = _extendToCanvasBoundary(
      start,
      -dirX,
      -dirY,
      canvasWidth,
      canvasHeight,
    );
    final tailExtendedEnd = start;

    // Extended line from head (end point) - extends forwards
    final headExtendedStart = end;
    final headExtendedEnd = _extendToCanvasBoundary(
      end,
      dirX,
      dirY,
      canvasWidth,
      canvasHeight,
    );

    return DrawnLine(
      start: start,
      end: end,
      color: color,
      strokeWidth: strokeWidth,
      extendedTailStart: tailExtendedStart,
      extendedTailEnd: tailExtendedEnd,
      extendedHeadStart: headExtendedStart,
      extendedHeadEnd: headExtendedEnd,
    );
  }

  // Helper method to extend a line to canvas boundary
  static Offset _extendToCanvasBoundary(
    Offset point,
    double dirX,
    double dirY,
    double canvasWidth,
    double canvasHeight,
  ) {
    // Calculate how far we can extend in each direction before hitting a boundary
    double tMax = double.infinity;

    // Check x boundaries
    if (dirX > 0) {
      tMax = math.min(tMax, (canvasWidth - point.dx) / dirX);
    } else if (dirX < 0) {
      tMax = math.min(tMax, -point.dx / dirX);
    }

    // Check y boundaries
    if (dirY > 0) {
      tMax = math.min(tMax, (canvasHeight - point.dy) / dirY);
    } else if (dirY < 0) {
      tMax = math.min(tMax, -point.dy / dirY);
    }

    // Extend the line to the boundary
    return Offset(
      (point.dx + dirX * tMax).clamp(0.0, canvasWidth),
      (point.dy + dirY * tMax).clamp(0.0, canvasHeight),
    );
  }

  // Convert to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'startX': start.dx,
      'startY': start.dy,
      'endX': end.dx,
      'endY': end.dy,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'extendedTailStartX': extendedTailStart?.dx,
      'extendedTailStartY': extendedTailStart?.dy,
      'extendedTailEndX': extendedTailEnd?.dx,
      'extendedTailEndY': extendedTailEnd?.dy,
      'extendedHeadStartX': extendedHeadStart?.dx,
      'extendedHeadStartY': extendedHeadStart?.dy,
      'extendedHeadEndX': extendedHeadEnd?.dx,
      'extendedHeadEndY': extendedHeadEnd?.dy,
    };
  }

  // Create from JSON for loading
  factory DrawnLine.fromJson(Map<String, dynamic> json) {
    return DrawnLine(
      start: Offset(
        json['startX']?.toDouble() ?? 0.0,
        json['startY']?.toDouble() ?? 0.0,
      ),
      end: Offset(
        json['endX']?.toDouble() ?? 0.0,
        json['endY']?.toDouble() ?? 0.0,
      ),
      color: Color(json['color'] ?? Colors.blue.value),
      strokeWidth: json['strokeWidth']?.toDouble() ?? 2.0,
      extendedTailStart:
          json['extendedTailStartX'] != null &&
                  json['extendedTailStartY'] != null
              ? Offset(
                json['extendedTailStartX'].toDouble(),
                json['extendedTailStartY'].toDouble(),
              )
              : null,
      extendedTailEnd:
          json['extendedTailEndX'] != null && json['extendedTailEndY'] != null
              ? Offset(
                json['extendedTailEndX'].toDouble(),
                json['extendedTailEndY'].toDouble(),
              )
              : null,
      extendedHeadStart:
          json['extendedHeadStartX'] != null &&
                  json['extendedHeadStartY'] != null
              ? Offset(
                json['extendedHeadStartX'].toDouble(),
                json['extendedHeadStartY'].toDouble(),
              )
              : null,
      extendedHeadEnd:
          json['extendedHeadEndX'] != null && json['extendedHeadEndY'] != null
              ? Offset(
                json['extendedHeadEndX'].toDouble(),
                json['extendedHeadEndY'].toDouble(),
              )
              : null,
    );
  }

  // Create a copy for undo/redo
  DrawnLine copy() {
    return DrawnLine(
      start: start,
      end: end,
      color: color,
      strokeWidth: strokeWidth,
      extendedTailStart: extendedTailStart,
      extendedTailEnd: extendedTailEnd,
      extendedHeadStart: extendedHeadStart,
      extendedHeadEnd: extendedHeadEnd,
    );
  }
}

// Custom painter for drawing lines with data flow animation
class LinePainter extends CustomPainter {
  final List<DrawnLine> lines;
  final Set<int> selectedLineIndices;
  final Set<int> activeDataFlowLines; // Lines connected to data sources
  final Offset? currentStart;
  final Offset? currentEnd;
  final bool showExtendedLines;
  final double dataFlowProgress;

  LinePainter({
    required this.lines,
    required this.selectedLineIndices,
    required this.activeDataFlowLines,
    this.currentStart,
    this.currentEnd,
    this.showExtendedLines = true,
    this.dataFlowProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Debug: Log when painter is called
    if (lines.isNotEmpty) {
      print('🎨 PAINTER: Drawing ${lines.length} connections on canvas');
    }

    // Draw existing lines
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isSelected = selectedLineIndices.contains(i);

      // Determine if this is a valid (green) or invalid (red) connection
      final isValidConnection = line.color == Colors.green;
      final isInvalidConnection = line.color == Colors.red;

      // Draw glow effect for valid/invalid connections
      if (isValidConnection || isInvalidConnection) {
        final glowPaint =
            Paint()
              ..color = line.color.withOpacity(0.3)
              ..strokeWidth = 8.0
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

        canvas.drawLine(line.start, line.end, glowPaint);
      }

      final paint =
          Paint()
            ..color = isSelected ? Colors.yellow : line.color
            ..strokeWidth = isSelected ? line.strokeWidth + 1 : line.strokeWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(line.start, line.end, paint);

      // Draw arrow at the end
      _drawArrow(canvas, line.start, line.end, paint);

      // Draw data flow animation only on lines connected to data sources
      // Line must be: valid (green), not selected, and connected to a data source
      if (isValidConnection && !isSelected && activeDataFlowLines.contains(i)) {
        _drawDataFlow(canvas, line.start, line.end);
      }

      // Draw selection indicator
      if (isSelected) {
        final selectionPaint =
            Paint()
              ..color = Colors.yellow.withOpacity(0.3)
              ..strokeWidth = 8
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;

        canvas.drawLine(line.start, line.end, selectionPaint);
      }

      // Draw extended invisible lines (visible only when debugging)
      if (showExtendedLines) {
        final extendedPaint =
            Paint()
              ..color = Colors.red.withOpacity(0.3)
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;

        // Draw extended line from tail (backwards)
        if (line.extendedTailStart != null && line.extendedTailEnd != null) {
          canvas.drawLine(
            line.extendedTailStart!,
            line.extendedTailEnd!,
            extendedPaint,
          );
        }

        // Draw extended line from head (forwards)
        if (line.extendedHeadStart != null && line.extendedHeadEnd != null) {
          canvas.drawLine(
            line.extendedHeadStart!,
            line.extendedHeadEnd!,
            extendedPaint,
          );
        }
      }
    }

    // Draw current line being drawn
    if (currentStart != null && currentEnd != null) {
      final paint =
          Paint()
            ..color = Colors.blue.withOpacity(0.7)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(currentStart!, currentEnd!, paint);
      _drawArrow(canvas, currentStart!, currentEnd!, paint);
    }
  }

  // Draw animated data flow dots along the line
  void _drawDataFlow(Canvas canvas, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final lineLength = math.sqrt(dx * dx + dy * dy);

    // Number of dots based on line length
    const dotSpacing = 30.0; // Space between dots
    final numDots = (lineLength / dotSpacing).floor().clamp(2, 8);

    // Draw multiple animated dots
    for (int i = 0; i < numDots; i++) {
      // Calculate position along the line with offset based on animation progress
      final dotProgress = ((dataFlowProgress + (i / numDots)) % 1.0);

      final dotX = start.dx + dx * dotProgress;
      final dotY = start.dy + dy * dotProgress;

      // Fade in/out at ends
      double opacity = 1.0;
      if (dotProgress < 0.1) {
        opacity = dotProgress / 0.1;
      } else if (dotProgress > 0.9) {
        opacity = (1.0 - dotProgress) / 0.1;
      }

      // Draw outer glow
      final glowPaint =
          Paint()
            ..color = const Color(0xFF00FF00).withOpacity(0.3 * opacity)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(Offset(dotX, dotY), 6, glowPaint);

      // Draw main dot with cozy orange color
      final dotPaint =
          Paint()
            ..color = const Color(0xFFFF6B35).withOpacity(opacity)
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);

      // Draw inner bright core
      final corePaint =
          Paint()
            ..color = const Color(0xFFFFE4B5).withOpacity(opacity)
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 2, corePaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double arrowLength = 10.0;
    const double arrowAngle = 0.5;

    final double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

    final Offset arrowP1 = Offset(
      end.dx - arrowLength * math.cos(angle - arrowAngle),
      end.dy - arrowLength * math.sin(angle - arrowAngle),
    );

    final Offset arrowP2 = Offset(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    canvas.drawLine(end, arrowP1, paint);
    canvas.drawLine(end, arrowP2, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.selectedLineIndices != selectedLineIndices ||
        oldDelegate.activeDataFlowLines != activeDataFlowLines ||
        oldDelegate.currentStart != currentStart ||
        oldDelegate.currentEnd != currentEnd ||
        oldDelegate.showExtendedLines != showExtendedLines ||
        oldDelegate.dataFlowProgress != dataFlowProgress;
  }
}

// Canvas state for undo/redo functionality
class CanvasState {
  final List<DroppedIcon> icons;
  final List<DrawnLine> lines;
  final Map<int, LineConnection> connections;

  CanvasState({
    required this.icons,
    required this.lines,
    required this.connections,
  });
}
