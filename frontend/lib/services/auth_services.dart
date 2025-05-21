import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<bool> signInWithGoogle() async {
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
        print("로그인 성공! JWT: $jwt");

        // JWT 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);

        return true; // 성공
      } else {
        print("백엔드 로그인 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      print("구글 로그인 에러: $e");
      return false;
    }
  }

  Future<bool> signInWithKakao() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      final accessToken = token.accessToken;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/social'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'kakao',
          'accessToken': accessToken
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jwt = data['jwt'];
        print("카카오 로그인 성공! JWT: $jwt");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);

        return true;
      } else {
        print("백엔드 로그인 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      print("카카오 로그인 에러: $e");
      return false;
    }
  }
}
