// backend/routes/reservation.js
const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const reservationScheduleController = require('../controllers/reservationScheduleController');
const { simpleAuth } = require('../middlewares/simpleAuth');
const { validateReservationCategory } = require('../middlewares/validation');

// 예약 카테고리 관련 라우트
router.get('/categories', simpleAuth, reservationController.getCategories);
router.post('/categories', simpleAuth, validateReservationCategory, reservationController.createCategory);
router.delete('/categories/:categoryId', simpleAuth, reservationController.deleteCategory);

// 예약 일정 관련 라우트
router.get('/rooms/:roomId/schedules', simpleAuth, reservationScheduleController.getCurrentWeekSchedules);
router.get('/rooms/:roomId/schedules/weekly', simpleAuth, reservationScheduleController.getWeeklySchedules);

// 방문객 예약 조회 라우트
router.get('/rooms/:roomId/schedules/visitors', simpleAuth, reservationScheduleController.getVisitorReservations);

// 승인 대기 중인 예약만 조회하는 별도 라우트
router.get('/rooms/:roomId/schedules/pending', simpleAuth, reservationScheduleController.getPendingReservations);

// ⭐ 특정 카테고리의 주간 일정 조회 라우트 (새로 추가) ⭐
router.get('/rooms/:roomId/categories/:categoryId/schedules', simpleAuth, reservationScheduleController.getCategoryWeeklySchedules);

// 예약 생성, 승인, 삭제
router.post('/schedules', simpleAuth, reservationScheduleController.createSchedule);
router.patch('/schedules/:reservationId/approve', simpleAuth, reservationScheduleController.approveReservation);
router.delete('/schedules/:scheduleId', simpleAuth, reservationScheduleController.deleteSchedule);

module.exports = router;