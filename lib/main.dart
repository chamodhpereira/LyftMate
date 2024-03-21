import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/screens/onboarding/onboarding_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:lyft_mate/constants/theme.dart';

import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: LyftMateAppTheme.lightTheme,
      darkTheme: LyftMateAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: OnBoardingScreen(),

    );
  }
}

