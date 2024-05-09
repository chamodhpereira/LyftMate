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
import 'package:lyft_mate/screens/find_ride/find_rides.dart';
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
import 'package:lyft_mate/testing-demo/endoded_polyline.dart';
import 'package:lyft_mate/testing-demo/map_gpx_new.dart';
import 'package:lyft_mate/testing-demo/saved/map_gpx_nav.dart';
import 'package:lyft_mate/userprofile_screen.dart';
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

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();

  if (Firebase.apps.isNotEmpty) {
      NotificationService.initNotifications();
  }

  runApp(LyftMate());
}

class LyftMate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Use MultiProvider for multiple providers
      providers: [
        // ChangeNotifierProvider(create: (_) => LoggedUser()),
        // ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_)=> NotificationProvider()),
        // ChangeNotifierProvider(create: (context) => RadiusProvider()),
        // ChangeNotifierProvider(create: (_) => UserM()),
        // ChangeNotifierProvider(create: (_) => UserProvider()),
        // ChangeNotifierProvider(create: (_) => AuthenticationService()), // Provide AuthenticationService
      ],
      child: MaterialApp(
        theme: LyftMateAppTheme.lightTheme,
        darkTheme: LyftMateAppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home:OnBoardingScreen(),
        // home: LocationPickScreen(),
        // home: NavigationScreen(),
        // home: VehicleScreen(),
        // home:RidePublishedPage(),
        // home: MapGPX(),
        // home: PolylineEncodingPage(),
        // home: LoginScreen(),
        // home: OTPScreen(phoneNumber: "1234567890",),
        // home: RideOptions(),
        // home: SignupScreen(),
        // home: FindRides(),
        // home: HomePage(),
        // home: MapPage(),
        // home: PaymentScreen(),
        routes: {
          '/navigationScreen': (context) => const NavigationScreen(),
          '/loginScreen': (context) => LoginScreen(),
        },
      ),
    );
  }
}
