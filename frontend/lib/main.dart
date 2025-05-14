import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart'; //온보딩화면만 보임
//import 'screens/profile_setup_screen.dart';  // 프로필 설정화면만 보임
//import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnboardingScreen(),         //온보딩화면만 보임
      //home: ProfileSetupScreen(),    //프로필 설정 화면만 보임
      //home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}