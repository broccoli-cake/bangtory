// backend/routes/reservation.js - 완전히 새로 작성
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

// 예약 일정 생성, 승인, 삭제
router.post('/schedules', simpleAuth, reservationScheduleController.createSchedule);
router.patch('/schedules/:reservationId/approve', simpleAuth, reservationScheduleController.approveReservation);
router.delete('/schedules/:scheduleId', simpleAuth, reservationScheduleController.deleteSchedule);

// 예약 조회 라우트들 - 간단하고 명확한 구조
router.get('/all-schedules/:roomId', simpleAuth, reservationScheduleController.getCurrentWeekSchedules);
router.get('/weekly-schedules/:roomId', simpleAuth, reservationScheduleController.getWeeklySchedules);
router.get('/visitor-schedules/:roomId', simpleAuth, reservationScheduleController.getVisitorReservations);
router.get('/pending-schedules/:roomId', simpleAuth, reservationScheduleController.getPendingReservations);
router.get('/category-schedules/:roomId/:categoryId', simpleAuth, reservationScheduleController.getCategoryWeeklySchedules);

module.exports = router;