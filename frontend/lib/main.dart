import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ✅ ADD THIS LINE
import 'screens/splash_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    print('🟡 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // ✅ USE THIS
    );

      Stripe.publishableKey = 'pk_test_51RogKfRwPzE7J33vm0solBTz8ZN3Ygr9d6nqzq41wcV7GqRHnnZurI6BH2PBGAkiymeiERFVrZNikbNB3tJM1Tsj00iIDsDOJt'; // replace with your real key

    print('✅ Firebase initialized.');
      await Stripe.instance.applySettings();


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
