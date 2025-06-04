// backend/routes/choreScheduleRoutes.js
const express = require('express');
const router = express.Router();
const { choreScheduleController, validateScheduleInput } = require('../controllers/choreScheduleController');
const { simpleAuth } = require('../middlewares/simpleAuth');

// [GET] /chores/schedules - 일정 목록 조회
router.get('/', simpleAuth, choreScheduleController.getSchedules);

// [POST] /chores/schedules - 일정 생성
router.post('/',
  simpleAuth,
  validateScheduleInput,
  choreScheduleController.createSchedule
);

// [PATCH] /chores/schedules/:scheduleId/complete - 일정 완료 처리
router.patch('/:scheduleId/complete',
  simpleAuth,
  choreScheduleController.completeSchedule
);

// [PATCH] /chores/schedules/:scheduleId/uncomplete - 일정 완료 해제 (새로 추가)
router.patch('/:scheduleId/uncomplete',
  simpleAuth,
  choreScheduleController.uncompleteSchedule
);

// [DELETE] /chores/schedules/:scheduleId - 일정 삭제
router.delete('/:scheduleId',
  simpleAuth,
  choreScheduleController.deleteSchedule
);

module.exports = router;