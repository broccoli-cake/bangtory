// backend/routes/reservation.js
const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const reservationScheduleController = require('../controllers/reservationScheduleController');
const { isAuthenticated } = require('../middlewares/auth');
const { validateReservationCategory } = require('../middlewares/validation');

// 예약 카테고리 관련 라우트
router.get('/categories', isAuthenticated, reservationController.getCategories);
router.post('/categories', isAuthenticated, validateReservationCategory, reservationController.createCategory);
router.delete('/categories/:categoryId', isAuthenticated, reservationController.deleteCategory);

// 예약 일정 관련 라우트
router.get('/rooms/:roomId/schedules', isAuthenticated, reservationScheduleController.getCurrentWeekSchedules);
router.get('/rooms/:roomId/schedules/weekly', isAuthenticated, reservationScheduleController.getWeeklySchedules);
router.get('/rooms/:roomId/schedules/visitors', isAuthenticated, reservationScheduleController.getVisitorReservations);
router.get('/rooms/:roomId/schedules/pending', isAuthenticated, reservationScheduleController.getPendingReservations);

router.post('/schedules', isAuthenticated, reservationScheduleController.createSchedule);
router.patch('/schedules/:reservationId/approve', isAuthenticated, reservationScheduleController.approveReservation);
router.delete('/schedules/:scheduleId', isAuthenticated, reservationScheduleController.deleteSchedule);

module.exports = router;
