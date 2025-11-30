import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/prediction_screen.dart';
import 'screens/lookup_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_wrapper.dart';

void main() {
  runApp(const CalorieApp());
}

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calorie Tracker",
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/login',
      routes: {
        // NOT CONST (contains controllers)
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),

        // CONST screens (stateless, no controllers)
        '/home': (context) => const HomeWrapper(),
        '/camera': (context) => const CameraScreen(),
        '/prediction': (context) => const PredictionScreen(),
        '/lookup': (context) => const LookupScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
