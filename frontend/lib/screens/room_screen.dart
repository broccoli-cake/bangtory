import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import 'main_screen.dart';

class RoomScreen extends StatefulWidget {
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _roomNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    _addressController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 이름을 입력해주세요')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.createRoom(
        roomName: _roomNameController.text.trim(),
        address: _addressController.text.trim(),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 생성 실패: $e')),
      );
    }
  }

  Future<void> _joinRoom() async {
    if (_inviteCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대 코드를 입력해주세요')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.joinRoom(_inviteCodeController.text.trim());

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 참여 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('방 설정')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '방을 생성하거나 참여하세요',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // 방 생성 섹션
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '새 방 생성',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _roomNameController,
                          decoration: InputDecoration(
                            labelText: '방 이름',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: '주소 (선택사항)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: appState.isLoading ? null : _createRoom,
                            child: Text('방 생성'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                Text('또는', textAlign: TextAlign.center),

                SizedBox(height: 16),

                // 방 참여 섹션
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '기존 방 참여',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _inviteCodeController,
                          decoration: InputDecoration(
                            labelText: '초대 코드',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: appState.isLoading ? null : _joinRoom,
                            child: Text('방 참여'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (appState.isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}