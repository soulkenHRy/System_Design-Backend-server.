import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'url_shortener_canvas_designs.dart';
import 'url_shortener_demo_canvas.dart';
import 'dart:math';

/// Gallery screen to preview and load URL Shortener designs
class URLShortenerDesignsGallery extends StatelessWidget {
  const URLShortenerDesignsGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final designs = URLShortenerCanvasDesigns.getAllDesigns();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        child: Stack(
          children: [
            // Cozy pixel-style stars/dots background
            ...List.generate(40, (index) {
              final random = Random(index);
              return Positioned(
                left: random.nextDouble() * screenWidth,
                top: random.nextDouble() * screenHeight,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4B5).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
            SafeArea(
              child: Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A3420),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: const Color(0xFFFFE4B5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 0,
                                offset: const Offset(2, 2),
                              ),
                            ],
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
                          child: Text(
                            'URL Shortener Design Gallery',
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE4B5),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Designs List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: designs.length,
                      itemBuilder: (context, index) {
                        final design = designs[index];
                        final name = design['name'] as String;
                        final description = design['description'] as String;
                        final iconCount = (design['icons'] as List).length;
                        final connectionCount =
                            (design['connections'] as List).length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A3420),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.7),
                              width: 1,
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
                              onTap: () => _openDesignInCanvas(context, design),
                              borderRadius: BorderRadius.circular(0),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple
                                                .withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: GoogleFonts.saira(
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFE4B5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFFFFE4B5),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      description,
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildStatChip(
                                          Icons.widgets,
                                          '$iconCount icons',
                                          Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatChip(
                                          Icons.connecting_airports,
                                          '$connectionCount connections',
                                          Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.saira(
              textStyle: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDesignInCanvas(BuildContext context, Map<String, dynamic> design) {
    // Convert connections to lines for the canvas
    final lines = URLShortenerCanvasDesigns.connectionsToLines(design);

    // Prepare canvas data with explanation
    final canvasData = {
      'icons': design['icons'],
      'lines': lines,
      'explanation': design['explanation'],
    };

    // Navigate to simplified demo canvas screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => URLShortenerDemoCanvas(
              designName: design['name'] as String,
              designData: canvasData,
            ),
      ),
    );
  }
}
