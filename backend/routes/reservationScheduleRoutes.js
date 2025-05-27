// backend/routes/reservationScheduleRoutes.js
const express = require('express');
const router = express.Router();
const { reservationScheduleController, validateScheduleInput } = require('../controllers/reservationScheduleController');
const { isAuthenticated } = require('../middlewares/auth');

// [GET] /reservations/schedules - 현재 주 예약 일정 조회 (승인된 예약만)
router.get('/', isAuthenticated, reservationScheduleController.getCurrentWeekSchedules);

// [GET] /reservations/schedules/week - 특정 주 예약 일정 조회 (승인된 예약만)
router.get('/week', isAuthenticated, reservationScheduleController.getWeeklySchedules);

// [GET] /reservations/schedules/pending - 승인 대기 중인 예약 목록 조회
router.get('/pending', isAuthenticated, reservationScheduleController.getPendingReservations);

// [POST] /reservations/schedules - 예약 일정 생성
router.post('/', 
  isAuthenticated,
  validateScheduleInput,
  reservationScheduleController.createSchedule
);

// [POST] /reservations/schedules/:scheduleId/approve - 예약 승인
router.post('/:scheduleId/approve',
  isAuthenticated,
  reservationScheduleController.approveReservation
);

// [DELETE] /reservations/schedules/:scheduleId - 예약 삭제
router.delete('/:scheduleId',
  isAuthenticated,
  reservationScheduleController.deleteSchedule
);

module.exports = router;