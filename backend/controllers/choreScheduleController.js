const choreScheduleService = require('../services/choreScheduleService');
const { body, validationResult } = require('express-validator');
const { ChoreError } = require('../utils/errors');

// 입력값 검증 미들웨어
const validateScheduleInput = [
  body('room')
    .notEmpty()
    .withMessage('방 ID는 필수입니다.'),
  body('category')
    .notEmpty()
    .withMessage('카테고리는 필수입니다.'),
  body('assignedTo')
    .notEmpty()
    .withMessage('담당자는 필수입니다.'),
  body('date')
    .notEmpty()
    .withMessage('날짜는 필수입니다.')
    .isISO8601()
    .withMessage('올바른 날짜 형식이 아닙니다.')
];

// 응답 포맷 생성 함수
const createResponse = (status, message, data = null) => {
  const response = {
    resultCode: status.toString(),
    resultMessage: message
  };
  if (data) {
    Object.assign(response, data);
  }
  return response;
};

const choreScheduleController = {
  /**
   * 일정 목록 조회
   */
  async getSchedules(req, res) {
    try {
      const { roomId, startDate, endDate, categoryId } = req.query;

      console.log('일정 조회 요청:', { roomId, startDate, endDate, categoryId });

      // 필수 값 체크
      if (!roomId || !startDate || !endDate) {
        return res.status(400).json(
          createResponse(400, '방 ID, 시작일, 종료일은 필수입니다.')
        );
      }

      // 일정 조회
      const schedules = await choreScheduleService.getSchedules(
        roomId,
        new Date(startDate),
        new Date(endDate),
        categoryId
      );

      console.log(`최종 반환 일정 수: ${schedules.length}`);

      return res.status(200).json(
        createResponse(200, '일정 목록 조회 성공', { schedules })
      );
    } catch (error) {
      console.error('일정 목록 조회 중 에러:', error);
      const statusCode = error instanceof ChoreError ? error.statusCode : 400;
      return res.status(statusCode).json(
        createResponse(statusCode, error.message)
      );
    }
  },

  /**
   * 일정 생성
   */
  async createSchedule(req, res) {
    try {
      console.log('일정 생성 요청 받음:', req.body);
      console.log('사용자 ID:', req.user._id);

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('유효성 검사 오류:', errors.array());
        return res.status(400).json(
          createResponse(400, '잘못된 입력입니다.', { errors: errors.array() })
        );
      }

      const schedule = await choreScheduleService.createSchedule(req.body, req.user._id);

      console.log('생성된 일정 (최종):', {
        id: schedule._id,
        category: schedule.category?.name,
        assignedTo: schedule.assignedTo?.nickname,
        date: schedule.date
      });

      return res.status(201).json(
        createResponse(201, '일정 생성 완료', { schedule })
      );
    } catch (error) {
      console.error('일정 생성 중 에러:', error);
      const statusCode = error instanceof ChoreError ? error.statusCode : 400;
      return res.status(statusCode).json(
        createResponse(statusCode, error.message)
      );
    }
  },

  /**
   * 일정 완료 처리
   */
  async completeSchedule(req, res) {
    try {
      console.log('일정 완료 처리 요청:', req.params.scheduleId);

      const schedule = await choreScheduleService.completeSchedule(
        req.params.scheduleId,
        req.user._id
      );

      console.log('완료 처리된 일정 (최종):', {
        id: schedule._id,
        isCompleted: schedule.isCompleted,
        completedAt: schedule.completedAt
      });

      return res.status(200).json(
        createResponse(200, '일정 완료 처리 완료', { schedule })
      );
    } catch (error) {
      console.error('일정 완료 처리 중 에러:', error);
      const statusCode = error instanceof ChoreError ? error.statusCode : 400;
      return res.status(statusCode).json(
        createResponse(statusCode, error.message)
      );
    }
  },

  /**
   * 일정 삭제
   */
  async deleteSchedule(req, res) {
    try {
      console.log('일정 삭제 요청:', req.params.scheduleId);

      await choreScheduleService.deleteSchedule(
        req.params.scheduleId,
        req.user._id
      );

      console.log('일정 삭제 완료');

      return res.status(200).json(
        createResponse(200, '일정 삭제 완료')
      );
    } catch (error) {
      console.error('일정 삭제 중 에러:', error);
      const statusCode = error instanceof ChoreError ? error.statusCode : 400;
      return res.status(statusCode).json(
        createResponse(statusCode, error.message)
      );
    }
  }
};

module.exports = {
  choreScheduleController,
  validateScheduleInput
};