// frontend/lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? fromUser;
  final String? roomName;
  final Map<String, dynamic>? relatedData;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.fromUser,
    this.roomName,
    this.relatedData,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      fromUser: json['fromUserId']?['name'] ?? json['fromUser'],
      roomName: json['roomId']?['roomName'] ?? json['roomName'],
      relatedData: json['relatedData'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  // 알림 타입별 아이콘 반환
  IconData get icon {
    switch (type) {
      case 'member_joined':
        return Icons.person_add;
      case 'member_left':
        return Icons.person_remove;
      case 'member_kicked':
        return Icons.remove_circle_outline;
      case 'ownership_transferred':
        return Icons.star;
      case 'chore_assigned':
        return Icons.assignment;
      case 'chore_completed':
        return Icons.check_circle;
      case 'reservation_created':
        return Icons.event_available;
      case 'reservation_approved':
        return Icons.thumb_up;
      case 'visitor_request':
        return Icons.emoji_people;
      case 'category_created':
        return Icons.category;
      case 'room_updated':
        return Icons.edit;
      case 'invite_code_generated':
        return Icons.share;
      default:
        return Icons.notifications;
    }
  }

  // 알림 타입별 색상 반환
  Color get color {
    switch (type) {
      case 'member_joined':
      case 'reservation_approved':
      case 'chore_completed':
        return Colors.green;
      case 'member_left':
      case 'member_kicked':
        return Colors.red;
      case 'ownership_transferred':
        return Colors.amber;
      case 'chore_assigned':
        return Colors.blue;
      case 'reservation_created':
      case 'visitor_request':
        return Colors.purple;
      case 'category_created':
      case 'room_updated':
      case 'invite_code_generated':
        return Colors.grey[600]!;
      default:
        return Colors.grey;
    }
  }

  // 상대적 시간 표시
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${createdAt.month}/${createdAt.day}';
    }
  }
}