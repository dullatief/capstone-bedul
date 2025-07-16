import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:klinik_bedul/screens/sign_in_screen.dart';
import 'package:klinik_bedul/screens/sign_up_screen.dart';
import 'package:klinik_bedul/screens/profil_screen.dart';
import 'package:klinik_bedul/screens/home/home_screen.dart';
import 'package:klinik_bedul/screens/home/riwayat_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:klinik_bedul/screens/splash_screen.dart';
import 'package:klinik_bedul/utils/notification_helper.dart';
import 'package:klinik_bedul/theme/app_theme.dart';
import 'package:klinik_bedul/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize other services
  await initializeDateFormatting('id_ID', null);
  await initializeNotification();
  await FirebaseService.initializeFirebaseAuth();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PREDIKSI AIR MINUM',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const SignInScreen(),
        '/register': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/riwayat': (context) => const RiwayatContent(),
        '/profil': (context) => const ProfilScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      },
    );
  }
}
