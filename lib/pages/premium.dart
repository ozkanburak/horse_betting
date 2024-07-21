import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // RevenueCat
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart'; 


final Uri _url = Uri.parse('https://burakozkan.com/horse-racing-privacy');
final Uri _url2 = Uri.parse('https://burakozkan.com/horse-racing-terms-of');

class PremiumEkrani extends StatefulWidget {
  @override
  _PremiumEkraniState createState() => _PremiumEkraniState();
}

class _PremiumEkraniState extends State<PremiumEkrani> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAbone = false; // Abonelik durumunu takip eder
  Stream<QuerySnapshot>? _premiumMaclarStream;

  @override
  void initState() {
    super.initState();
    _abonelikDurumuKontrolEt();
  }

  Future<void> _abonelikDurumuKontrolEt() async {
    // RevenueCat ile abonelik durumunu kontrol et
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    setState(() {
      _isAbone = customerInfo.entitlements.all['Pro']?.isActive ?? false;
      if (_isAbone) {
        _premiumMaclarStream = _firestore.collection('premium_maclar').snapshots();
      }
    });
  }

  Future<void> _aboneOl() async {
    // RevenueCat ile abonelik satın alma işlemini başlat
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        final package = offerings.current!.availablePackages.first;
        await Purchases.purchasePackage(package);
        _abonelikDurumuKontrolEt(); // Abonelik durumunu güncelle
      }
    } catch (e) {
      // Hata yönetimi
      print('Abonelik hatası: $e');
    }
  }
   Future<void> _aboneligiGeriYukle() async {
    try {
      await Purchases.restorePurchases();
      _abonelikDurumuKontrolEt();
    } catch (e) {
      print('Geri yükleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(title: Text(AppLocalizations.of(context)!.premiumTitle),
        ),
      ),
      body: _isAbone ? _premiumMaclariGoster() : _premiumBilgileriGoster(),
      
    );
  }

  Widget _premiumBilgileriGoster() {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
        elevation: 5,
        margin: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.premiumOz, style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.premiumBir),
              Text(AppLocalizations.of(context)!.premiumIki),
              Text(AppLocalizations.of(context)!.premiumUc),
              SizedBox(height: 120),
        
              ElevatedButton(onPressed: _aboneOl, child: Text(AppLocalizations.of(context)!.subscribe),),
              SizedBox(height: 10), // Butonlar arasına boşluk eklendi  
              TextButton(onPressed: _aboneligiGeriYukle, child: Text(AppLocalizations.of(context)!.restoreSubscription),),
              SizedBox(height: 20),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _launchUrl(), // Replace with your actual URL
                    child: Text(AppLocalizations.of(context)!.privacyPolicy, style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                  SizedBox(width: 10),
                  Text('•'), // Separator dot
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () => _launchUrl2(),  // Replace with your actual URL
                    child: Text(AppLocalizations.of(context)!.termsOfUse, style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumMaclariGoster() {
    return StreamBuilder<QuerySnapshot>(
      stream: _premiumMaclarStream,
      builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final yarislar = snapshot.data!.docs;

          return ListView.builder(
            itemCount: yarislar.length,
            itemBuilder: (context, index) {
              final yaris = yarislar[index].data() as Map<String, dynamic>;
              final String sonuc = yaris['sonuc']; // sonuc'u string olarak al

              return Card(
                child: ListTile(
                  leading: Icon(
                    size: 40,
                    sonuc == 'W' ? Icons.check_circle : (sonuc == 'L' ? Icons.cancel : Icons.help),
                    color: sonuc == 'W' ? Colors.green : (sonuc == 'L' ? Colors.red : Colors.grey),
                  ),
                  title: Text(yaris['macAdi'].toString()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tahmin: ${yaris['tahmin']}'),
                      Text('Oran: ${yaris['oran']}'),
                      Text('Zaman: ${yaris['macSaati']}' + '   ' + 'Lig: ${yaris['lig']}'),
                     
                    ],
                  ),
                  // Bahis butonu veya diğer detaylar burada eklenebilir
                ),
              );
            },
          );
        
      },
    );
  }
  


}
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
Future<void> _launchUrl2() async {
  if (!await launchUrl(_url2)) {
    throw Exception('Could not launch $_url2');
  }
}