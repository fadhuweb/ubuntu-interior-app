import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ✅ ADD THIS LINE
import 'screens/splash_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('🟡 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // ✅ USE THIS
    );
    debugPrint('✅ Firebase initialized.');

    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('❌ Caught error in main(): $error');
    debugPrint('🧠 Stack trace:\n$stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🚀 Building MyApp widget...');
    return MaterialApp(
      title: 'Ubuntu Interiors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const SplashScreen(),
    );
  }
}

