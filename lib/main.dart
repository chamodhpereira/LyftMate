import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/models/loggeduser.dart';
import 'package:lyft_mate/models/user.dart';
import 'package:lyft_mate/providers/ride_provider.dart';
import 'package:lyft_mate/providers/user_provider.dart';
import 'package:lyft_mate/screens/chat/user_list.dart';
import 'package:lyft_mate/screens/home/home.dart';
import 'package:lyft_mate/screens/login/login_screen.dart';
import 'package:lyft_mate/screens/signup/signup_screen.dart';
import 'package:lyft_mate/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:lyft_mate/screens/signup/signup_form.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'constants/theme.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Use MultiProvider for multiple providers
      providers: [
        // ChangeNotifierProvider(create: (_) => LoggedUser()),
        // ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => UserM()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationService()), // Provide AuthenticationService
      ],
      child: MaterialApp(
        theme: LyftMateAppTheme.lightTheme,
        darkTheme: LyftMateAppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: HomePage(),
        // routes: ,
      ),
    );
  }
}
