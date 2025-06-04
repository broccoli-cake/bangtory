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
          // 전체 앱의 기본 색상 스키마를 화이트 기반으로 설정
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFA2E55), // 앱의 메인 컬러
            brightness: Brightness.light, // 라이트 테마 사용
            primary: const Color(0xFFFA2E55),
            secondary: Colors.grey[600]!,
            surface: Colors.white, // 표면 색상 (카드, 다이얼로그 등)
            background: Colors.white, // 배경 색상
          ),

          // 스캐폴드(기본 화면) 배경색
          scaffoldBackgroundColor: Colors.white,

          // AppBar 테마
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.black),
          ),

          // 카드 테마
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // 다이얼로그 테마
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // 텍스트 테마
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black87),
            titleLarge: TextStyle(color: Colors.black),
            titleMedium: TextStyle(color: Colors.black),
            titleSmall: TextStyle(color: Colors.black),
          ),

          // 버튼 테마
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA2E55),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // 텍스트 버튼 테마
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFA2E55),
            ),
          ),

          // 입력 필드 테마
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFA2E55)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),

          // 리스트 타일 테마
          listTileTheme: const ListTileThemeData(
            tileColor: Colors.white,
            textColor: Colors.black87,
          ),

          // 바텀 내비게이션 바 테마
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFFFA2E55),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),

          // 스위치 테마
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFFFA2E55);
              }
              return Colors.grey;
            }),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFFFA2E55).withOpacity(0.3);
              }
              return Colors.grey[300];
            }),
          ),

          // 프로그레스 인디케이터 색상
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFFFA2E55),
          ),

          // 체크박스 테마
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFFFA2E55);
              }
              return Colors.white;
            }),
            checkColor: MaterialStateProperty.all(Colors.white),
          ),

          // 스낵바 테마
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.black87,
            contentTextStyle: TextStyle(color: Colors.white),
          ),

          // Material 3 사용
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}