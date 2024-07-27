import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:horse_betting/main.dart'; // Import your main.dart file
import 'package:horse_betting/pages/analiz_bilgi.dart';
import 'package:horse_betting/pages/bahisekrani.dart';
import 'package:horse_betting/pages/gecmisbahis.dart';
import 'package:horse_betting/pages/macyukele.dart';
import 'package:horse_betting/pages/premium.dart';
import 'package:horse_betting/pages/transparancy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart'; 


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; 

  final List<Widget> _screens = [
    BahisEkrani(),
    PremiumEkrani(),
    GecmisBahis(),
    AnalizEkrani(),
    MacYuklemeEkrani()
  ];

  @override
  void initState() {
    initPlugin(context);  
    super.initState();
    
    _handleInitialScreen();
  }

  Future<void> _handleInitialScreen() async {
    if (_currentIndex == 1) {
      await _showPaywallIfNeeded();
    }
  }

  Future<void> _showPaywallIfNeeded() async {
    final customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.all['Pro']?.isActive != true) { // Check if the user is not already subscribed
      await _configureSDK(); // Show the paywall only if they're not subscribed
    }
  }
  Future<void> _configureSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration? configuration;

  if (Platform.isAndroid){

  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration("appl_dHrqHYDauQjspmZsoIkHmuCvCBC");
  }

  if(configuration != null){
    await Purchases.configure(configuration);

    final PaywallResult = await RevenueCatUI.presentPaywallIfNeeded("Pro");
    log('Paywall result: $PaywallResult');
  }
}

  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title text
        title: const Text("Horse Racing Tips & Picks", // Set the title text directly
        style: TextStyle(fontSize: 22,
        fontWeight: FontWeight.bold,
        ),
        
        ),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (locale) => localeModel.changeLocale(locale),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<Locale>(
                value: Locale('en', ''),
                child: Text('English'),
              ),
              PopupMenuItem<Locale>(
                value: Locale('ja', ''),
                child: Text('Japanese'),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green, // Set your desired background color here
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 1) {
            // If PremiumEkrani is selected
            await _showPaywallIfNeeded(); // Show paywall before navigating
          }
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: AppLocalizations.of(context)!.freeTitle),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: AppLocalizations.of(context)!.premiumTitle),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: AppLocalizations.of(context)!.oldTips),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: AppLocalizations.of(context)!.analysis,),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ADdd'),

        ],
      ),
    );
  }
}
