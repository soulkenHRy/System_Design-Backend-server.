// Simplified Demo Canvas Screen for URL Shortener Designs
// This screen shows only the diagram and explanation (no editing controls)

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data class for dropped icons on the canvas
class DemoDroppedIcon {
  final String name;
  final IconData icon;
  final String category;
  Offset position;

  DemoDroppedIcon({
    required this.name,
    required this.icon,
    required this.category,
    required this.position,
  });

  factory DemoDroppedIcon.fromJson(Map<String, dynamic> json) {
    return DemoDroppedIcon(
      name: json['name'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
      ),
      category: json['category'] as String,
      position: Offset(
        (json['positionX'] as num).toDouble(),
        (json['positionY'] as num).toDouble(),
      ),
    );
  }
}

/// Data class for drawn lines on the canvas
class DemoDrawnLine {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final String? label;

  DemoDrawnLine({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
    this.label,
  });

  factory DemoDrawnLine.fromJson(Map<String, dynamic> json) {
    return DemoDrawnLine(
      start: Offset(
        (json['startX'] as num).toDouble(),
        (json['startY'] as num).toDouble(),
      ),
      end: Offset(
        (json['endX'] as num).toDouble(),
        (json['endY'] as num).toDouble(),
      ),
      color: Color(json['color'] as int? ?? 0xFF2196F3),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      label: json['label'] as String?,
    );
  }
}

/// Simplified Demo Canvas Screen for viewing URL Shortener designs
class URLShortenerDemoCanvas extends StatefulWidget {
  final String designName;
  final Map<String, dynamic> designData;

  const URLShortenerDemoCanvas({
    super.key,
    required this.designName,
    required this.designData,
  });

  @override
  State<URLShortenerDemoCanvas> createState() => _URLShortenerDemoCanvasState();
}

class _URLShortenerDemoCanvasState extends State<URLShortenerDemoCanvas> {
  List<DemoDroppedIcon> icons = [];
  List<DemoDrawnLine> lines = [];
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _loadDesign();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _loadDesign() {
    final iconsData = widget.designData['icons'] as List<dynamic>? ?? [];
    final linesData = widget.designData['lines'] as List<dynamic>? ?? [];

    setState(() {
      icons =
          iconsData
              .map(
                (json) =>
                    DemoDroppedIcon.fromJson(json as Map<String, dynamic>),
              )
              .toList();
      lines =
          linesData
              .map(
                (json) => DemoDrawnLine.fromJson(json as Map<String, dynamic>),
              )
              .toList();
    });

    // Auto-fit the design to screen after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitDesignToScreen();
    });
  }

  void _fitDesignToScreen() {
    if (icons.isEmpty) return;

    // Calculate bounds of all icons
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final icon in icons) {
      minX = math.min(minX, icon.position.dx);
      minY = math.min(minY, icon.position.dy);
      maxX = math.max(maxX, icon.position.dx + 70); // icon width
      maxY = math.max(maxY, icon.position.dy + 80); // icon height
    }

    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final canvasWidth = screenSize.width;
    final canvasHeight = screenSize.height - 150; // Subtract header height

    // Calculate scale to fit
    final designWidth = maxX - minX + 100; // padding
    final designHeight = maxY - minY + 100; // padding
    final scaleX = canvasWidth / designWidth;
    final scaleY = canvasHeight / designHeight;
    final scale = math.min(scaleX, scaleY) * 0.8; // 80% to leave some margin

    // Calculate translation to center
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final translateX = canvasWidth / 2 - centerX * scale;
    final translateY = canvasHeight / 2 - centerY * scale;

    // Apply transformation
    final matrix =
        Matrix4.identity()
          ..translate(translateX, translateY)
          ..scale(scale);

    _transformationController.value = matrix;
  }

  void _showExplanationSheet() {
    final explanation =
        widget.designData['explanation'] as String? ??
        'No explanation available for this design.';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 20, 20, 30),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.purpleAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.designName,
                                style: GoogleFonts.saira(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      // Explanation content - Simple styled text
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          child: _buildFormattedExplanation(explanation),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  /// Build formatted explanation from markdown-like text
  Widget _buildFormattedExplanation(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('## ')) {
        // H2 Header
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(3),
              style: GoogleFonts.saira(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // H3 Header
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(4),
              style: GoogleFonts.saira(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
          ),
        );
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold text
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(2, line.length - 2),
              style: GoogleFonts.saira(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        // Bullet point
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: GoogleFonts.saira(
                    fontSize: 14,
                    color: Colors.purpleAccent,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: GoogleFonts.saira(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('```') || line.endsWith('```')) {
        // Skip code block markers
        continue;
      } else if (line.contains('→') ||
          line.contains('│') ||
          line.contains('└') ||
          line.contains('├') ||
          line.contains('┌') ||
          line.contains('┐') ||
          line.contains('┘') ||
          line.contains('─') ||
          line.trim().startsWith('[')) {
        // Code/diagram content
        widgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: Colors.black38,
            child: Text(
              line,
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: Colors.greenAccent,
              ),
            ),
          ),
        );
      } else if (line.contains(':') && line.indexOf(':') < 25) {
        // Key-value style content
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line,
              style: GoogleFonts.saira(
                fontSize: 13,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
          ),
        );
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line,
              style: GoogleFonts.saira(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Client & Interface': Colors.blue,
      'Networking': Colors.orange,
      'Servers & Computing': Colors.green,
      'Database & Storage': Colors.red,
      'Caching,Performance': Colors.yellow,
      'Message Systems': Colors.purple,
      'Security,Monitoring': Colors.pink,
      'Cloud,Infrastructure': Colors.cyan,
      'System Utilities': Colors.teal,
      'Data Processing': Colors.indigo,
      'External Services': Colors.amber,
      'Application Services': Colors.lightGreen,
      'Geospatial': Colors.deepOrange,
    };
    return colors[category] ?? Colors.grey;
  }

  Widget _buildIconOnCanvas(DemoDroppedIcon iconData) {
    final categoryColor = _getCategoryColor(iconData.category);

    return Positioned(
      left: iconData.position.dx,
      top: iconData.position.dy,
      child: Container(
        width: 70,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: categoryColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData.icon, color: categoryColor, size: 28),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                iconData.name,
                style: GoogleFonts.saira(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Cozy pixel-like gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810), // Dark brown
              Color(0xFF3D2817), // Medium brown
              Color(0xFF4A3420), // Light brown
              Color(0xFF5C4129), // Tan
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3420),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFFFE4B5).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2817),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: const Color(0xFFFFE4B5),
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFFFFE4B5),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.designName,
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE4B5),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Text(
                            '${icons.length} components • ${lines.length} connections',
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Explanation button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2817),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.7),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 0,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showExplanationSheet,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Colors.purpleAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: GoogleFonts.saira(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFFE4B5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Canvas area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3D2817), Color(0xFF2C1810)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return InteractiveViewer(
                        transformationController: _transformationController,
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 0.1,
                        maxScale: 3.0,
                        constrained: false,
                        child: Container(
                          width: math.max(constraints.maxWidth, 2000),
                          height: math.max(constraints.maxHeight, 1500),
                          child: Stack(
                            children: [
                              // Grid background
                              CustomPaint(
                                size: Size(
                                  math.max(constraints.maxWidth, 2000),
                                  math.max(constraints.maxHeight, 1500),
                                ),
                                painter: _GridPainter(),
                              ),
                              // Draw lines with arrows
                              CustomPaint(
                                size: Size(
                                  math.max(constraints.maxWidth, 2000),
                                  math.max(constraints.maxHeight, 1500),
                                ),
                                painter: _DemoLinePainter(lines: lines),
                              ),
                              // Draw icons
                              ...icons.map((icon) => _buildIconOnCanvas(icon)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom info bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pinch to zoom • Drag to pan',
                      style: GoogleFonts.saira(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid painter for canvas background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 0.5;

    const gridSize = 50.0;

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

/// Line painter with arrows
class _DemoLinePainter extends CustomPainter {
  final List<DemoDrawnLine> lines;

  _DemoLinePainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint =
          Paint()
            ..color = line.color
            ..strokeWidth = line.strokeWidth
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

      // Draw the line
      canvas.drawLine(line.start, line.end, paint);

      // Draw arrow head
      _drawArrowHead(canvas, line.start, line.end, paint);

      // Draw label if exists
      if (line.label != null && line.label!.isNotEmpty) {
        _drawLabel(canvas, line);
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    final arrowPaint =
        Paint()
          ..color = paint.color
          ..strokeWidth = paint.strokeWidth
          ..style = PaintingStyle.fill;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = math.atan2(dy, dx);

    const arrowLength = 12.0;
    const arrowAngle = 0.5;

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowLength * math.cos(angle - arrowAngle),
      end.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    path.lineTo(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );
    path.close();

    canvas.drawPath(path, arrowPaint);
  }

  void _drawLabel(Canvas canvas, DemoDrawnLine line) {
    final midPoint = Offset(
      (line.start.dx + line.end.dx) / 2,
      (line.start.dy + line.end.dy) / 2,
    );

    final textSpan = TextSpan(
      text: line.label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        backgroundColor: Colors.black.withOpacity(0.6),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Draw background
    final bgRect = Rect.fromCenter(
      center: midPoint,
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = Colors.black.withOpacity(0.7),
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        midPoint.dx - textPainter.width / 2,
        midPoint.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _DemoLinePainter oldDelegate) {
    return lines != oldDelegate.lines;
  }
}
