// backend/routes/reservation.js
const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const reservationScheduleController = require('../controllers/reservationScheduleController');
const { authenticateToken } = require('../middleware/auth');
const { validateReservationCategory } = require('../middleware/validation');

// 예약 카테고리 관련 라우트
router.get('/categories', authenticateToken, reservationController.getCategories);
router.post('/categories', authenticateToken, validateReservationCategory, reservationController.createCategory);
router.delete('/categories/:categoryId', authenticateToken, reservationController.deleteCategory);

// 예약 일정 관련 라우트
router.get('/rooms/:roomId/schedules', authenticateToken, reservationScheduleController.getCurrentWeekSchedules);
router.get('/rooms/:roomId/schedules/weekly', authenticateToken, reservationScheduleController.getWeeklySchedules);
router.get('/rooms/:roomId/schedules/visitors', authenticateToken, reservationScheduleController.getVisitorReservations);
router.get('/rooms/:roomId/schedules/pending', authenticateToken, reservationScheduleController.getPendingReservations);

router.post('/schedules', authenticateToken, reservationScheduleController.createSchedule);
router.patch('/schedules/:reservationId/approve', authenticateToken, reservationScheduleController.approveReservation);
router.delete('/schedules/:scheduleId', authenticateToken, reservationScheduleController.deleteSchedule);

module.exports = router;
