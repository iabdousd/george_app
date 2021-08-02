import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stackedtasks/services/cache/initializers.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stackedtasks/views/main.dart';

import 'config/app_preferences.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  await Firebase.initializeApp();
  await AppPreferences.initPreferences();

  if (!kIsWeb) await initializeCache();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return GetMaterialApp(
      title: 'Stackedtasks',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      theme: lightThemeData(context),
      darkTheme: lightThemeData(context), // darkThemeData(context),
      home: AppViews(),
    );
  }
}
