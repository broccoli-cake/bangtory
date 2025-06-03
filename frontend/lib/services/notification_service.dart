// frontend/lib/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  String? _userId;

  String? get userId => _userId;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_userId != null) 'X-User-ID': _userId!,
  };

  void setUserId(String userId) {
    _userId = userId;
  }

  // 알림 목록 조회
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'unreadOnly': unreadOnly.toString(),
      };

      final uri = Uri.parse('$baseUrl/notifications')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final notifications = (data['notifications'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        return {
          'notifications': notifications,
          'pagination': data['pagination'],
          'unreadCount': data['unreadCount'],
        };
      } else {
        throw Exception('알림 조회 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('알림 조회 중 오류 발생: $e');
    }
  }

  // 읽지 않은 알림 개수 조회
  Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception('읽지 않은 알림 개수 조회 실패: ${response.body}');
      }
    } catch (e) {
      print('읽지 않은 알림 개수 조회 오류: $e');
      return 0;
    }
  }

  // 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('알림 읽음 처리 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('알림 읽음 처리 중 오류 발생: $e');
    }
  }

  // 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('모든 알림 읽음 처리 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('모든 알림 읽음 처리 중 오류 발생: $e');
    }
  }