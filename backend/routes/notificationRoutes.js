// backend/routes/notificationRoutes.js
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { simpleAuth } = require('../middlewares/simpleAuth');

// [GET] /notifications - 알림 목록 조회
router.get('/', simpleAuth, notificationController.getNotifications);

// [GET] /notifications/unread-count - 읽지 않은 알림 개수 조회
router.get('/unread-count', simpleAuth, notificationController.getUnreadCount);

// [PATCH] /notifications/:notificationId/read - 알림 읽음 처리
router.patch('/:notificationId/read', simpleAuth, notificationController.markAsRead);

// [PATCH] /notifications/read-all - 모든 알림 읽음 처리
router.patch('/read-all', simpleAuth, notificationController.markAllAsRead);

module.exports = router;