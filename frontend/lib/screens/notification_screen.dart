// frontend/lib/screens/notification_screen.dart - 완전히 새로운 버전
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/app_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _unreadCount = 0;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadNotifications();
    _loadUnreadCount();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeService() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentUser != null) {
      _notificationService.setUserId(appState.currentUser!.id);
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _notifications.clear();
        _hasMore = true;
        _isLoading = true;
      });
    }

    try {
      final result = await _notificationService.getNotifications(
        page: _currentPage,
        limit: 20,
      );

      final newNotifications = result['notifications'] as List<NotificationModel>;
      final pagination = result['pagination'];

      setState(() {
        if (refresh) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }

        _unreadCount = result['unreadCount'] ?? 0;
        _hasMore = _currentPage < pagination['pages'];
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림을 불러오는데 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      setState(() {
        _unreadCount = count;
      });
    } catch (e) {
      print('읽지 않은 알림 개수 조회 실패: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _loadNotifications();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await _notificationService.markAsRead(notification.id);

      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            fromUser: notification.fromUser,
            roomName: notification.roomName,
            relatedData: notification.relatedData,
            createdAt: notification.createdAt,
            isRead: true,
          );
        }
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      });

      // AppState의 읽지 않은 알림 개수도 업데이트
      final appState = Provider.of<AppState>(context, listen: false);
      appState.updateUnreadNotificationCount(_unreadCount);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('알림 읽음 처리 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      setState(() {
        _notifications = _notifications.map((notification) =>
            NotificationModel(
              id: notification.id,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              fromUser: notification.fromUser,
              roomName: notification.roomName,
              relatedData: notification.relatedData,
              createdAt: notification.createdAt,
              isRead: true,
            )
        ).toList();
        _unreadCount = 0;
      });

      // AppState의 읽지 않은 알림 개수도 업데이트
      final appState = Provider.of<AppState>(context, listen: false);
      appState.updateUnreadNotificationCount(0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 알림을 읽음 처리했습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('모든 알림 읽음 처리 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.color.withOpacity(0.2),
          child: Icon(
            notification.icon,
            color: notification.color,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (notification.fromUser != null) ...[
                  Icon(Icons.face, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    notification.fromUser!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  notification.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFFA2E55),
            shape: BoxShape.circle,
          ),
        ),
        onTap: () => _markAsRead(notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              '알림',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA2E55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                '모두 읽음',
                style: TextStyle(
                  color: Color(0xFFFA2E55),
                  fontSize: 14,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _loadNotifications(refresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '알림이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _notifications.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return _buildNotificationItem(_notifications[index]);
          },
        ),
      ),
    );
  }
}