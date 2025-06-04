// backend/controllers/notificationController.js
const notificationService = require('../services/notificationService');

// 응답 포맷 생성 함수
const createResponse = (status, message, data = null) => {
  const response = {
    resultCode: status.toString(),
    resultMessage: message
  };
  if (data) {
    Object.assign(response, data);
  }
  return response;
};

const notificationController = {
  /**
   * 사용자의 알림 목록 조회
   */
  async getNotifications(req, res) {
    try {
      const userId = req.user._id;
      const { page = 1, limit = 20, unreadOnly = false } = req.query;

      const result = await notificationService.getUserNotifications(userId, {
        page: parseInt(page),
        limit: parseInt(limit),
        unreadOnly: unreadOnly === 'true'
      });

      return res.status(200).json(
        createResponse(200, '알림 목록 조회 성공', result)
      );
    } catch (error) {
      console.error('알림 목록 조회 중 에러:', error);
      return res.status(500).json(
        createResponse(500, '서버 오류가 발생했습니다.')
      );
    }
  },

  /**
   * 읽지 않은 알림 개수 조회
   */
  async getUnreadCount(req, res) {
    try {
      const userId = req.user._id;
      const count = await notificationService.getUnreadCount(userId);

      return res.status(200).json(
        createResponse(200, '읽지 않은 알림 개수 조회 성공', { count })
      );
    } catch (error) {
      console.error('읽지 않은 알림 개수 조회 중 에러:', error);
      return res.status(500).json(
        createResponse(500, '서버 오류가 발생했습니다.')
      );
    }
  },

  /**
   * 알림 읽음 처리
   */
  async markAsRead(req, res) {
    try {
      const userId = req.user._id;
      const { notificationId } = req.params;

      const notification = await notificationService.markAsRead(notificationId, userId);

      if (!notification) {
        return res.status(404).json(
          createResponse(404, '알림을 찾을 수 없습니다.')
        );
      }

      return res.status(200).json(
        createResponse(200, '알림 읽음 처리 완료', { notification })
      );
    } catch (error) {
      console.error('알림 읽음 처리 중 에러:', error);
      return res.status(500).json(
        createResponse(500, '서버 오류가 발생했습니다.')
      );
    }
  },

  /**
   * 모든 알림 읽음 처리
   */
  async markAllAsRead(req, res) {
    try {
      const userId = req.user._id;
      const result = await notificationService.markAllAsRead(userId);

      return res.status(200).json(
        createResponse(200, '모든 알림 읽음 처리 완료', {
          modifiedCount: result.modifiedCount
        })
      );
    } catch (error) {
      console.error('모든 알림 읽음 처리 중 에러:', error);
      return res.status(500).json(
        createResponse(500, '서버 오류가 발생했습니다.')
      );
    }
  }
};

module.exports = notificationController;