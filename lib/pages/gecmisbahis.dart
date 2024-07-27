import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class GecmisBahis extends StatefulWidget {



  @override
  _GecmisBahisState createState() => _GecmisBahisState();
}

class _GecmisBahisState extends State<GecmisBahis> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _tahminlerStream;

  @override
  void initState() {
    super.initState();
    _tahminlerStream = _firestore.collection('tahminler')
    .where('goster', isEqualTo: 0)
    .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(title: Text(AppLocalizations.of(context)!.oldTips),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _tahminlerStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final tahminler = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tahminler.length,
            itemBuilder: (context, index) {
              final tahmin = tahminler[index].data() as Map<String, dynamic>;
              final String sonuc = tahmin['sonuc']; // sonuc'u string olarak al

              return Card(
                child: ListTile(
                  leading: Icon(
                    size: 40,
                    sonuc == 'W' ? Icons.check_circle : (sonuc == 'L' ? Icons.cancel : Icons.help),
                    color: sonuc == 'W' ? Colors.green : (sonuc == 'L' ? Colors.red : Colors.grey),
                  ),
                  title: Text(tahmin['macAdi'].toString()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${tahmin['tahmin']}'),
                      Text(AppLocalizations.of(context)!.cardRate + ':' + ' ${tahmin['oran']}'),
                      Text(AppLocalizations.of(context)!.cardTime + ':' + ' ${tahmin['macSaati']}' + '   ' + AppLocalizations.of(context)!.cardLig + ':' + ' ${tahmin['lig']}'),
               
                    
                     
                    ],
                  ),
                  // Bahis butonu veya diğer detaylar burada eklenebilir
                ),
              );
            },
          );
        },
      ),
    );
  }
}
