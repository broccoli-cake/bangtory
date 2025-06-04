// backend/services/notificationService.js
const Notification = require('../models/Notification');
const RoomMember = require('../models/RoomMember');

const notificationService = {
  /**
   * 알림 생성 및 실시간 전송
   */
  async createNotification({
    userId,
    fromUserId = null,
    roomId,
    type,
    title,
    message,
    relatedData = null,
  }) {
    try {
      const notification = new Notification({
        userId,
        fromUserId,
        roomId,
        type,
        title,
        message,
        relatedData
      });

      const savedNotification = await notification.save();

      // 알림 데이터를 populate하여 완전한 정보 조회
      const populatedNotification = await Notification.findById(savedNotification._id)
        .populate('fromUserId', 'name')
        .populate('userId', 'name')
        .populate('roomId', 'roomName');

      // Socket.IO를 통해 실시간 알림 전송
      try {
        const io = require('../app').io; // app.js에서 io 인스턴스 가져오기
        if (io) {
          const notificationData = {
            id: populatedNotification._id,
            type: populatedNotification.type,
            title: populatedNotification.title,
            message: populatedNotification.message,
            fromUser: populatedNotification.fromUserId?.name || null,
            roomName: populatedNotification.roomId?.roomName || null,
            relatedData: populatedNotification.relatedData,
            createdAt: populatedNotification.createdAt,
            isRead: populatedNotification.isRead
          };

          // 일반 알림 전송
          io.emit('notification', notificationData);

          // 사용자별 알림 전송
          io.to(`user_${userId}`).emit('user_notification', notificationData);
        }
      } catch (socketError) {
        console.error('실시간 알림 전송 실패:', socketError);
      }

      return populatedNotification;
    } catch (error) {
      console.error('알림 생성 오류:', error);
      throw error;
    }
  },

  /**
   * 방의 모든 멤버에게 알림 전송 (발신자 제외)
   */
  async notifyRoomMembers({
    roomId,
    fromUserId,
    type,
    title,
    message,
    relatedData = null,
    excludeUserIds = []
  }) {
    try {
      // 방의 모든 멤버 조회
      const roomMembers = await RoomMember.find({ roomId })
        .select('userId')
        .populate('userId', '_id');

      const notifications = [];

      for (const member of roomMembers) {
        const userId = member.userId._id;

        // 발신자와 제외 목록에 있는 사용자는 제외
        if (userId.toString() === fromUserId?.toString() ||
            excludeUserIds.includes(userId.toString())) {
          continue;
        }

        const notification = await this.createNotification({
          userId,
          fromUserId,
          roomId,
          type,
          title,
          message,
          relatedData
        });

        notifications.push(notification);
      }

      return notifications;
    } catch (error) {
      console.error('방 멤버 알림 전송 오류:', error);
      throw error;
    }
  },

  /**
   * 특정 사용자에게 개별 알림 전송
   */
  async notifyUser({
    userId,
    fromUserId = null,
    roomId,
    type,
    title,
    message,
    relatedData = null
  }) {
    try {
      return await this.createNotification({
        userId,
        fromUserId,
        roomId,
        type,
        title,
        message,
        relatedData
      });
    } catch (error) {
      console.error('개별 사용자 알림 전송 오류:', error);
      throw error;
    }
  },

  /**
   * 사용자의 알림 목록 조회
   */
  async getUserNotifications(userId, { page = 1, limit = 20, unreadOnly = false } = {}) {
    try {
      const query = { userId };
      if (unreadOnly) {
        query.isRead = false;
      }

      const skip = (page - 1) * limit;

      const notifications = await Notification.find(query)
        .populate('fromUserId', 'name')
        .populate('roomId', 'roomName')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit);

      const total = await Notification.countDocuments(query);
      const unreadCount = await Notification.countDocuments({
        userId,
        isRead: false
      });

      return {
        notifications,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        },
        unreadCount
      };
    } catch (error) {
      console.error('알림 조회 오류:', error);
      throw error;
    }
  },

  /**
   * 알림 읽음 처리
   */
  async markAsRead(notificationId, userId) {
    try {
      const notification = await Notification.findOneAndUpdate(
        { _id: notificationId, userId },
        {
          isRead: true,
          readAt: new Date()
        },
        { new: true }
      );

      return notification;
    } catch (error) {
      console.error('알림 읽음 처리 오류:', error);
      throw error;
    }
  },

  /**
   * 모든 알림 읽음 처리
   */
  async markAllAsRead(userId) {
    try {
      const result = await Notification.updateMany(
        { userId, isRead: false },
        {
          isRead: true,
          readAt: new Date()
        }
      );

      return result;
    } catch (error) {
      console.error('전체 알림 읽음 처리 오류:', error);
      throw error;
    }
  },

  /**
   * 읽지 않은 알림 개수 조회
   */
  async getUnreadCount(userId) {
    try {
      return await Notification.countDocuments({
        userId,
        isRead: false
      });
    } catch (error) {
      console.error('읽지 않은 알림 개수 조회 오류:', error);
      return 0;
    }
  },

  /**
   * 오래된 알림 정리 (30일 이상)
   */
  async cleanupOldNotifications() {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const result = await Notification.deleteMany({
        createdAt: { $lt: thirtyDaysAgo },
        isRead: true
      });

      console.log(`정리된 오래된 알림: ${result.deletedCount}개`);
      return result.deletedCount;
    } catch (error) {
      console.error('오래된 알림 정리 오류:', error);
      throw error;
    }
  }
};

module.exports = notificationService;