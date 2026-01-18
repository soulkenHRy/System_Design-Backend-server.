import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './quiz_statistics.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PersonalStatScreen extends StatelessWidget {
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return 'N/A';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes min ${remainingSeconds} sec';
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.saira(
              textStyle: const TextStyle(
                fontSize: 18,
                color: Color(0xFFFFE4B5),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.saira(
              textStyle: const TextStyle(
                fontSize: 18,
                color: Color(0xFFFFE4B5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<QuizStatistics> history) {
    if (history.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3D2817),
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: const Color(0xFFFFE4B5).withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            'No quiz history yet\nTake a quiz to see your progress!',
            textAlign: TextAlign.center,
            style: GoogleFonts.saira(
              textStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFFFFE4B5),
              ),
            ),
          ),
        ),
      );
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].percentage));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2817),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: const Color(0xFFFFE4B5).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Last ${history.length} Quiz Result${history.length > 1 ? 's' : ''}',
            style: GoogleFonts.saira(
              textStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFFFFE4B5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: history.length > 5 ? 2 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < history.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 42,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                minX: 0,
                maxX: (history.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor:
                        (touchedSpot) => Colors.black.withOpacity(0.8),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        final index = flSpot.x.toInt();
                        if (index >= 0 && index < history.length) {
                          final result = history[index];
                          return LineTooltipItem(
                            'Quiz ${index + 1}\n${result.percentage.toStringAsFixed(1)}%\n${result.score}/${result.totalQuestions}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.8),
                        Colors.lightGreenAccent.withOpacity(0.8),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // Color dots based on performance
                        Color dotColor = Colors.green;
                        if (spot.y >= 80) {
                          dotColor = Colors.green;
                        } else if (spot.y >= 60) {
                          dotColor = Colors.orange;
                        } else {
                          dotColor = Colors.red;
                        }

                        return FlDotCirclePainter(
                          radius: 5,
                          color: dotColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.2),
                          Colors.green.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  const PersonalStatScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            'Your Personal Stats',
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 24,
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
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: QuizStatistics.getStatistics(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFE4B5),
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return Center(
                              child: Text(
                                'No quiz attempts yet',
                                style: GoogleFonts.saira(
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFE4B5),
                                  ),
                                ),
                              ),
                            );
                          }

                          final stats = snapshot.data!;
                          final latest = stats['latest'] as QuizStatistics;
                          final best = stats['best'] as QuizStatistics;
                          final totalQuizzes = stats['totalQuizzes'] as int;

                          // Check if user has taken any quizzes
                          if (totalQuizzes == 0 &&
                              latest.score == 0 &&
                              latest.totalQuestions == 0) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.quiz,
                                    size: 80,
                                    color: const Color(
                                      0xFFFFE4B5,
                                    ).withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No quiz attempts yet',
                                    style: GoogleFonts.saira(
                                      textStyle: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFE4B5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Take a quiz to see your statistics!',
                                    style: GoogleFonts.saira(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        color: const Color(
                                          0xFFFFE4B5,
                                        ).withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return FutureBuilder<List<QuizStatistics>>(
                            future: QuizStatistics.getQuizHistory(),
                            builder: (context, historySnapshot) {
                              final history = historySnapshot.data ?? [];

                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      'Total Quizzes Taken: $totalQuizzes',
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFE4B5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    // Line Chart Section
                                    Text(
                                      'Performance History:',
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 22,
                                          color: Color(0xFF4CAF50),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildLineChart(history),
                                    const SizedBox(height: 40),
                                    Text(
                                      'Latest Quiz Result:',
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 22,
                                          color: Color(0xFF4CAF50),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildStatRow(
                                      'Score',
                                      '${latest.score}/${latest.totalQuestions}',
                                    ),
                                    _buildStatRow(
                                      'Percentage',
                                      '${latest.percentage.toStringAsFixed(1)}%',
                                    ),
                                    _buildStatRow(
                                      'Questions Attempted',
                                      '${latest.attempted}',
                                    ),
                                    _buildStatRow(
                                      'Time Taken',
                                      _formatTime(latest.timeTakenInSeconds),
                                    ),
                                    _buildStatRow(
                                      'Date',
                                      _formatDate(latest.dateTime),
                                    ),
                                    const SizedBox(height: 40),
                                    Text(
                                      'Best Performance:',
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 22,
                                          color: Color(0xFF4CAF50),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildStatRow(
                                      'Score',
                                      '${best.score}/${best.totalQuestions}',
                                    ),
                                    _buildStatRow(
                                      'Percentage',
                                      '${best.percentage.toStringAsFixed(1)}%',
                                    ),
                                    _buildStatRow(
                                      'Time Taken',
                                      _formatTime(best.timeTakenInSeconds),
                                    ),
                                    _buildStatRow(
                                      'Date',
                                      _formatDate(best.dateTime),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
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
}
