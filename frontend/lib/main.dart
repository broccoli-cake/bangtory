import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart'; //온보딩화면만 보임
//import 'screens/profile_setup_screen.dart';  // 프로필 설정화면만 보임
//import 'screens/login_screen.dart';
//import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
//import 'screens/home_screen.dart';

void main() {
  //KakaoSdk.init(nativeAppKey: '895568f04a81d7ea98d525d6eb33f170');
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
      //home: HomeScreen(roomName: '우리집', userName: '김민영'),  //임시로 설정
      debugShowCheckedModeBanner: false,
    );
  }
}