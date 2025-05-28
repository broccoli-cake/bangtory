// backend/routes/reservation.js
const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const reservationScheduleController = require('../controllers/reservationScheduleController');
const { isAuthenticated } = require('../middlewares/auth');
const { validateReservationCategory } = require('../middlewares/validation');

// 예약 카테고리 관련 라우트
router.get('/categories', isAuthenticated, reservationController.getCategories); // 예약 카테고리 목록 조회
router.post('/categories', isAuthenticated, validateReservationCategory, reservationController.createCategory); // 예약 카테고리 생성
router.delete('/categories/:categoryId', isAuthenticated, reservationController.deleteCategory); // 예약 카테고리 삭제

// 예약 일정 관련 라우트
router.get('/rooms/:roomId/schedules', isAuthenticated, reservationScheduleController.getCurrentWeekSchedules); // 현재 주 예약 일정 조회
router.get('/rooms/:roomId/schedules/weekly', isAuthenticated, reservationScheduleController.getWeeklySchedules); // 주간 예약 일정 조회
router.get('/rooms/:roomId/schedules/visitors', isAuthenticated, reservationScheduleController.getVisitorReservations); // 방문객 예약 조회
router.get('/rooms/:roomId/schedules/pending', isAuthenticated, reservationScheduleController.getPendingReservations); // 승인 대기 중인 예약 목록 조회

router.post('/schedules', isAuthenticated, reservationScheduleController.createSchedule); // 예약 일정 생성
router.patch('/schedules/:reservationId/approve', isAuthenticated, reservationScheduleController.approveReservation); // 예약 승인
router.delete('/schedules/:scheduleId', isAuthenticated, reservationScheduleController.deleteSchedule); // 예약 삭제

module.exports = router;
