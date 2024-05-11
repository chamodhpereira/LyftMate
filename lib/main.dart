import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lyft_mate/home.dart';

import 'package:lyft_mate/models/loggeduser.dart';
import 'package:lyft_mate/models/user.dart';
import 'package:lyft_mate/providers/notification_provider.dart';
import 'package:lyft_mate/providers/ride_provider.dart';
import 'package:lyft_mate/providers/user_provider.dart';
import 'package:lyft_mate/screens/chat/user_list.dart';

import 'package:lyft_mate/screens/find_ride/ride_request_sent_screen.dart';
import 'package:lyft_mate/screens/home/ui/home.dart';
import 'package:lyft_mate/screens/map/map_screen.dart';
import 'package:lyft_mate/screens/offer_ride/ui/offer_ride_screen.dart';
import 'package:lyft_mate/screens/login/login_screen.dart';
import 'package:lyft_mate/screens/navigation/navigation_screen.dart';
import 'package:lyft_mate/screens/offer_ride/ui/ride_offered_screen.dart';
import 'package:lyft_mate/screens/onboarding/onboarding_screen.dart';
import 'package:lyft_mate/screens/otp/otp_screen.dart';
import 'package:lyft_mate/screens/payment/payment_screen.dart';
// import 'package:lyft_mate/screens/payment/card_form_screen.dart';
import 'package:lyft_mate/screens/profile/initial_setup.dart';
import 'package:lyft_mate/screens/profile/user_profile_screen.dart';
import 'package:lyft_mate/screens/ride/ride_options_screen.dart';
import 'package:lyft_mate/screens/signup/screens/signup_emergency_contacts_page.dart';
import 'package:lyft_mate/screens/signup/screens/signup_screen.dart';
import 'package:lyft_mate/screens/vehicles/vehicle_screen.dart';

import 'package:lyft_mate/services/authentication_service.dart';
import 'package:lyft_mate/services/notifications/notifications_service.dart';
import 'package:lyft_mate/userprofile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'constants/theme.dart';
import 'firebase_options.dart';
// import 'map_test/radius_provider.dart';

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

  LyftMate({required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> NotificationProvider()),
      ],
      child: MaterialApp(
        theme: LyftMateAppTheme.lightTheme,
        // darkTheme: LyftMateAppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home:OnBoardingScreen(),
        routes: {
          '/navigationScreen': (context) => const NavigationScreen(),
          '/loginScreen': (context) => LoginScreen(),
        },
      ),
    );
  }
}
