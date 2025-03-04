import 'package:diet_plan_app/screens/first_page.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:timezone/data/latest.dart' as tz;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
//import 'package:permission_handler/permission_handler.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 10, 220, 199),
  ),
  textTheme: GoogleFonts.oswaldTextTheme(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for both web and mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBCXVnE66U46kDgQUmXPo2XCxz7HWzcLOw",
        appId: "1:1090389233935:android:f9c50f631716785f01ae7a",
        messagingSenderId: "1090389233935",
        projectId: "diet-plan-f6636",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBCXVnE66U46kDgQUmXPo2XCxz7HWzcLOw",
        appId: "1:1090389233935:android:f9c50f631716785f01ae7a",
        messagingSenderId: "1090389233935",
        projectId: "diet-plan-f6636",
      ),
    );
  }

  //tz.initializeTimeZones(); // Initialize timezone data

  // Initialize notifications
  await _initializeNotifications();

  runApp(const App());
}

Future<void> _initializeNotifications() async {
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } catch (e) {
    print('Error initializing notifications: $e');
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const FirstPage(),
    );
  }
}
