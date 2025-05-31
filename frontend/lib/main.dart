import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'utils/app_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Bangtory',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: OnboardingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}