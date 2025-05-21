import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication auth = await account!.authentication;

      final idToken = auth.idToken;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/social'), // 👈 실제 백엔드 주소로 변경
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'google',
          'accessToken': idToken
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jwt = data['jwt'];
        print("✅ 로그인 성공! JWT: $jwt");

        // TODO: JWT 저장 및 다음 화면 이동
      } else {
        print("❌ 백엔드 로그인 실패: ${response.body}");
      }
    } catch (e) {
      print("❌ 구글 로그인 에러: $e");
    }
  }
}
