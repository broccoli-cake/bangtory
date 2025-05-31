import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../models/chore.dart';
import '../models/room_model.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<ChoreCategory> _choreCategories = [];
  List<RoomMember> _roomMembers = [];
  bool _isLoadingChores = false;
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadChoreCategories();
    await _loadRoomMembers();
  }

  Future<void> _loadChoreCategories() async {
    setState(() {
      _isLoadingChores = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      _choreCategories = await appState.apiService.getChoreCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 로드 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoadingChores = false;
      });
    }
  }

  Future<void> _loadRoomMembers() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentRoom == null) return;

    setState(() {
      _isLoadingMembers = true;
    });

    try {
      _roomMembers = await appState.apiService.getRoomMembers(appState.currentRoom!.roomId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('멤버 로드 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoadingMembers = false;
      });
    }
  }

  void _showCreateCategoryDialog() {
    final nameController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('새 카테고리 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '카테고리 이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: InputDecoration(
                labelText: '아이콘 (이모지)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || iconController.text.trim().isEmpty) {
                return;
              }

              try {
                final appState = Provider.of<AppState>(context, listen: false);
                await appState.apiService.createChoreCategory(
                  name: nameController.text.trim(),
                  icon: iconController.text.trim(),
                );

                Navigator.of(context).pop();
                await _loadChoreCategories();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('카테고리가 생성되었습니다')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('카테고리 생성 실패: $e')),
                );
              }
            },
            child: Text('생성'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃'),
        content: Text('정말로 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appState.currentRoom?.roomName ?? '방토리'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(appState),
              _buildChoresTab(),
              _buildRoomTab(appState),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cleaning_services),
                label: '집안일',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: '방 관리',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeTab(AppState appState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요, ${appState.currentUser?.nickname ?? '사용자'}님!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text('현재 방: ${appState.currentRoom?.roomName ?? '없음'}'),
                  if (appState.currentRoom?.address != null)
                    Text('주소: ${appState.currentRoom!.address}'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '오늘의 할 일',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Expanded(
            child: Card(
              child: Center(
                child: Text(
                  '일정 기능은 추후 구현 예정입니다',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoresTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '집안일 카테고리',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: _showCreateCategoryDialog,
                icon: Icon(Icons.add),
                label: Text('추가'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: _isLoadingChores
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _choreCategories.length,
              itemBuilder: (context, index) {
                final category = _choreCategories[index];
                return Card(
                  child: ListTile(
                    leading: Text(
                      category.icon,
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(category.name),
                    subtitle: Text('타입: ${category.type}'),
                    trailing: category.type == 'custom'
                        ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // 삭제 기능 구현 예정
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('삭제 기능은 추후 구현 예정입니다')),
                        );
                      },
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTab(AppState appState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '방 정보',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text('방 이름: ${appState.currentRoom?.roomName ?? '없음'}'),
                  if (appState.currentRoom?.address != null)
                    Text('주소: ${appState.currentRoom!.address}'),
                  Text('내 권한: ${appState.currentRoom?.isOwner == true ? '방장' : '멤버'}'),
                  if (appState.currentRoom?.inviteCode != null) ...[
                    SizedBox(height: 8),
                    Text('초대 코드: ${appState.currentRoom!.inviteCode}'),
                    Text('만료까지: ${appState.currentRoom!.expiresIn ?? 0}분'),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '방 멤버 (${_roomMembers.length}명)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Expanded(
            child: _isLoadingMembers
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _roomMembers.length,
              itemBuilder: (context, index) {
                final member = _roomMembers[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(member.nickname[0]),
                    ),
                    title: Text(member.nickname),
                    subtitle: Text(member.isOwner ? '방장' : '멤버'),
                    trailing: Text(
                      '${member.joinedAt.month}/${member.joinedAt.day} 참여',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}