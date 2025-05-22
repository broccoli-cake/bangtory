const express = require('express');
const router = express.Router();
const { choreScheduleController, validateScheduleInput } = require('../controllers/choreScheduleController');
const { isAuthenticated } = require('../middlewares/auth');

// [GET] /chores/schedules - 일정 목록 조회
router.get('/', isAuthenticated, choreScheduleController.getSchedules);

// [POST] /chores/schedules - 일정 생성
router.post('/', 
  isAuthenticated,
  validateScheduleInput,
  choreScheduleController.createSchedule
);

// [PATCH] /chores/schedules/:scheduleId/complete - 일정 완료 처리
router.patch('/:scheduleId/complete',
  isAuthenticated,
  choreScheduleController.completeSchedule
);
// [DELETE] /chores/schedules/:scheduleId - 일정 삭제
router.delete('/:scheduleId',
  isAuthenticated,
  choreScheduleController.deleteSchedule
);

module.exports = router; 