import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
// import 'dev/sample_data_loader.dart'; // Uncomment if you use it

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    print('🟡 Initializing Firebase...');
    await Firebase.initializeApp();
    print('✅ Firebase initialized.');

    // await loadSampleData(); // Only if you have dev/test data to load

    runApp(const MyApp());
  }, (error, stackTrace) {
    print('❌ Caught error in main(): $error');
    print('🧠 Stack trace:\n$stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🚀 Building MyApp widget...');
    return MaterialApp(
      title: 'Ubuntu Interiors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const SplashScreen(),
    );
  }
}
