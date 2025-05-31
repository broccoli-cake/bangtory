// backend/routes/reservation.js - 완전히 다른 구조로 변경

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

// 예약 일정 관련 라우트 - 충돌 방지를 위해 완전히 분리
router.get('/rooms/:roomId/all-schedules', simpleAuth, reservationScheduleController.getCurrentWeekSchedules);
router.get('/rooms/:roomId/weekly-schedules', simpleAuth, reservationScheduleController.getWeeklySchedules);
router.get('/rooms/:roomId/visitor-schedules', simpleAuth, reservationScheduleController.getVisitorReservations);
router.get('/rooms/:roomId/pending-schedules', simpleAuth, reservationScheduleController.getPendingReservations);

// ⭐ 카테고리별 예약 조회 - 완전히 새로운 경로 ⭐
router.get('/category-schedules/:roomId/:categoryId', simpleAuth, reservationScheduleController.getCategoryWeeklySchedules);

// 예약 생성, 승인, 삭제
router.post('/schedules', simpleAuth, reservationScheduleController.createSchedule);
router.patch('/schedules/:reservationId/approve', simpleAuth, reservationScheduleController.approveReservation);
router.delete('/schedules/:scheduleId', simpleAuth, reservationScheduleController.deleteSchedule);

module.exports = router;