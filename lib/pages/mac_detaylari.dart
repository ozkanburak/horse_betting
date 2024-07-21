import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:horse_betting/pages/analiz_bilgi.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetayliIstatistikler extends StatelessWidget {
  final String matchId; // Now takes matchId

  DetayliIstatistikler({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.horseJockeyDetails),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('analysis').doc(matchId).get(), // Fetch analysis document
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading analysis data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final analysisData = snapshot.data!.data() as Map<String, dynamic>?;
          final favoriteHorseData = analysisData?['favoriteHorseData'] as Map<String, dynamic>?; // Get favorite horse data directly

          final last5Results = List<int>.from(favoriteHorseData?['last5Results'] ?? []); // Default to empty list if missing


          final wins = favoriteHorseData?['wins'] ?? 0; 
          final losses = favoriteHorseData?['losses'] ?? 0;
          final winPercentage = (wins + losses) == 0 ? 0.0 : (wins / (wins + losses)) * 100;


         return SingleChildScrollView(
           child: Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horse Name
                    Text(
                      favoriteHorseData?['name'] ?? 'Unknown Horse',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // Last 5 Results (Wrapped in Card with Header)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0), // Adjust padding as needed
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header (Last 5 Matches)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                AppLocalizations.of(context)!.last5Matches, // Localized header
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // List of Results
                            for (var result in last5Results)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Lottie.network(
                                      'https://lottie.host/550e8a24-0153-4720-a1a2-23609f690901/VD27pNUmRT.json',
                                      height: 30, // Reduced Lottie size
                                      width: 30,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text('Error loading animation'),
                                    ),
                                    SizedBox(width: 12), // Smaller spacing
                                    Text(
                                      AppLocalizations.of(context)!.yarisSiralama + ' : '+ (result + 1).toString(),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.toplamYaris,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: Size.square(80),
                                    painter: WinLossPieChart(winPercentage),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$wins W",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      Text(
                                        "$losses L",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}