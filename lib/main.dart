import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sensy_patient_app/screens/generic_device_pairing_page.dart';
import 'firebase_options.dart';

import 'screens/device_pairing_page.dart';
import 'screens/home_page.dart';
import 'screens/sign_in_page.dart';

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
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Color(0xFF3A6470),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF3A6470),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF75939B)),
                foregroundColor: Color(0xFF3A6470),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
          textTheme: TextTheme(
              titleMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253228),
              ),
              bodyMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253228),
              )),
          useMaterial3: true,
        ),
        home: const SignInPage(),
        routes: {
          '/signinpage': (context) => SignInPage(),
          '/homepage': (context) => HomePage(),
          '/devicepairingpage': (context) => DevicePairingPage(),
          '/genericdevicepairingpage': (context) => GenericDevicePairingPage(),
        });
  }
}
