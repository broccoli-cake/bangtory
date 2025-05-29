import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../screens/profile_setup_screen.dart';

class AuthService {
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // 구글 로그인 실행
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 로그인 취소됨

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception("idToken이 없습니다.");

      // Node.js 서버로 idToken 전송
      final response = await http.post(
        Uri.parse('http://localhost:3000/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: 서버 오류 (${response.statusCode})')),
        );
      }
    } catch (e) {
      print('구글 로그인 중 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구글 로그인 실패')),
      );
    }
  }
}
