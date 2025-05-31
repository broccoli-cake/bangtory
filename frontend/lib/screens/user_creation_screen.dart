import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'profile_setup_screen.dart';

class UserCreationScreen extends StatefulWidget {
  @override
  _UserCreationScreenState createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreationScreen> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.createUser(nickname: _nicknameController.text.trim());

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 생성 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사용자 생성')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '방토리에 오신 것을 환영합니다!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: '닉네임 (선택사항)',
                    hintText: '닉네임을 입력하지 않으면 랜덤으로 생성됩니다',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: appState.isLoading ? null : _createUser,
                    child: appState.isLoading
                        ? CircularProgressIndicator()
                        : Text('시작하기'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}