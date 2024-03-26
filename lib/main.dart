import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/models/loggeduser.dart';
import 'package:lyft_mate/models/user.dart';
import 'package:lyft_mate/screens/login/login_screen.dart';
import 'package:lyft_mate/screens/signup/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:lyft_mate/screens/signup/signup_form.dart';


import 'constants/theme.dart';
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
    return ChangeNotifierProvider(
      create: (context) => LoggedUser(),
      child: MaterialApp(
        theme: LyftMateAppTheme.lightTheme,
        darkTheme: LyftMateAppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SignupScreen(),
      ),
    );
  }
}
