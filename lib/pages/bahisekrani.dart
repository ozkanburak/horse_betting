import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rflutter_alert/rflutter_alert.dart'; 

class BahisEkrani extends StatefulWidget {



  @override
  _BahisEkraniState createState() => _BahisEkraniState();
}

class _BahisEkraniState extends State<BahisEkrani> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _tahminlerStream;

  @override
  void initState() {
    super.initState();
    init();
    _tahminlerStream = _firestore.collection('tahminler')
    .where('goster', isEqualTo: 1)
    .snapshots();
  }

   init() async {
    String deviceToken = await getDeviceToken();
    print("###### PRINT DEVICE TOKEN TO USE FOR PUSH NOTIFCIATION ######");
    print(deviceToken);
    print("############################################################");

    // listen for user to click on notification 
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      String? title = remoteMessage.notification!.title;
      String? description = remoteMessage.notification!.body;

      //im gonna have an alertdialog when clicking from push notification
      Alert(
        context: context,
        type: AlertType.error,
        title: title, // title from push notification data
        desc: description, // description from push notifcation data
        buttons: [
          DialogButton(
            child: Text(
              "COOL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(title: Text(AppLocalizations.of(context)!.freeTitle),
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
                    sonuc == 'W' ? Icons.check_circle : (sonuc == 'L' ? Icons.cancel : Icons.access_time),
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
  Future getDeviceToken() async {
    //request user permission for push notification 
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessage.getToken();
    return (deviceToken == null) ? "" : deviceToken;
  }

}
