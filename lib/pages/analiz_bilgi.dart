import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:horse_betting/pages/mac_detaylari.dart'; // Import the details page

class AnalizEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.analysis), // Set app bar title with localization
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('analysis').snapshots(), // Stream data from Firestore
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Show error message if data fetching fails
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No analysis data available.')); // Show message if no data
          }

          final analysisData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: analysisData.length, // Number of analysis items
            itemBuilder: (context, index) {
              final data = analysisData[index].data() as Map<String, dynamic>; 

              // Null-safe data retrieval with default values
              final wins = data['wins'] ?? 0;
              final losses = data['losses'] ?? 0;
              final matchName = data['matchName'] ?? 'No Match Name';
              final favorite = data['favorite'] ?? 'N/A';

              // Calculate win percentage and handle division by zero
              final totalRaces = wins + losses;
              final winPercentage = totalRaces == 0 ? 0.0 : (wins / totalRaces) * 100;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetayliIstatistikler(matchId: analysisData[index].id),
                    ),
                  );
                },
                child: Card( // Display each analysis in a card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Win/Loss Pie Chart
                            SizedBox(
                              width: 80.0, 
                              height: 80.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint( // Draw the pie chart
                                    size: Size.square(80.0), 
                                    painter: WinLossPieChart(winPercentage), // Pass win percentage to the painter
                                  ),
                                  // Display win/loss counts on the chart
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center, 
                                    children: [
                                      Text(
                                        "${wins}W",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      Text(
                                        "${losses}L",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 16), // Spacing
                            // Match Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("$favorite", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Win/Lose Percentage Text
                        
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class WinLossPieChart extends CustomPainter {
  final double winPercentage;

  WinLossPieChart(this.winPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke // Only draw the outline of the chart
      ..strokeWidth = 8.0; // Thickness of the stroke

    final center = Offset(size.width / 2, size.height / 2); // Center of the circle
    final radius = size.width / 2;

    // Draw the win portion (green)
    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start angle at the top (12 o'clock position)
      2 * math.pi * (winPercentage / 100), // Sweep angle based on percentage
      false, // Don't fill the arc
      paint,
    );

    // Draw the loss portion (red)
    paint.color = Colors.red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + 2 * math.pi * (winPercentage / 100), // Start where win portion ended
      2 * math.pi * ((100 - winPercentage) / 100), // Remaining angle for loss
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Always repaint
}

