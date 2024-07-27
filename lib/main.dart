import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:horse_betting/firebase_options.dart';
import 'package:horse_betting/mainclass.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
import 'package:url_launcher/url_launcher.dart';

//ca-app-pub-3610454142571657/2098946770
//ca-app-pub-3610454142571657~6144372686


//ADs
AppOpenAd? appOpenAd;
bool _isShowingAd = false; // Track if the ad is currently showing
bool _hasShownPaywall = false;

bool _isAdLoadingComplete = false;

void loadAppOpenAd() {
  AppOpenAd.load(
    adUnitId: Platform.isAndroid
        ? 'ca-app-pub-3610454142571657/2098946770'
        : 'ca-app-pub-3610454142571657/2098946770',
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        appOpenAd = ad;
        appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            appOpenAd = null;
            _isShowingAd = false;
            _configureSDK(); // Reklam kapatıldığında paywall'u göster
          },
        );

        _showAdIfAvailable(); // Reklam yüklenince hemen göster
      },
      onAdFailedToLoad: (error) {
        print('AppOpenAd failed to load: $error');
        _showPaywallIfNeeded(); // Reklam yüklenemezse paywall'u göster
      },
    ),
  );
}

void _showAdIfAvailable() {
  if (appOpenAd != null && !_isShowingAd) {
    _isShowingAd = true;
    appOpenAd!.show();
  }
}

Future<void> _showPaywallIfNeeded() async {
  // Show paywall only if the ad loading is complete and the paywall hasn't been shown
  if (_isAdLoadingComplete && !_hasShownPaywall) {
    _hasShownPaywall = true;
    await _configureSDK(); // Show paywall only once
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  loadAppOpenAd();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleModel(),
      child: MyApp(),
    ),
  );

}

//Reneve
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

//Localization
class LocaleModel extends ChangeNotifier {
  Locale _locale = Locale('en'); // Default locale

  Locale get locale => _locale;

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners(); // Notify listeners when locale changes
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Provider.of<LocaleModel>(context).locale, // Access locale from provider
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('ja', ''),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,  
          brightness: Brightness.light, 
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.green, 
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white,
          fontSize: 24),
        ),
        useMaterial3: true
      ),
      
      
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}


