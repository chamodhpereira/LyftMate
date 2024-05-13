import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lyft_mate/screens/reviews/reviews_screen.dart';
import 'package:lyft_mate/screens/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lyft_mate/providers/notification_provider.dart';
import 'package:lyft_mate/screens/login/login_screen.dart';
import 'package:lyft_mate/screens/navigation/navigation_screen.dart';
import 'package:lyft_mate/screens/onboarding/onboarding_screen.dart';
import 'package:lyft_mate/services/notifications/notifications_service.dart';

import 'constants/theme.dart';
import 'firebase_options.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();

  if (Firebase.apps.isNotEmpty) {
      NotificationService.initNotifications();
  }

  runApp(LyftMate(hasSeenOnboarding: hasSeenOnboarding));
}

class LyftMate extends StatelessWidget {
  final bool hasSeenOnboarding;

  const LyftMate({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> NotificationProvider()),
      ],
      child: MaterialApp(
        theme: LyftMateAppTheme.lightTheme,
        themeMode: ThemeMode.system,
        home: hasSeenOnboarding ? const WelcomeScreen() : const OnBoardingScreen(),
        routes: {
          '/navigationScreen': (context) => const NavigationScreen(),
          '/loginScreen': (context) => LoginScreen(),
          '/driverReviewScreen' : (context) => const ReviewsScreen(),
        },
      ),
    );
  }
}


