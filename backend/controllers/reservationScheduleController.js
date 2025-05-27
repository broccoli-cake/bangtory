// backend/controllers/reservationScheduleController.js
const reservationScheduleService = require('../services/reservationScheduleService');
const { validationResult, body } = require('express-validator');

// 예약 입력 검증 미들웨어
const validateScheduleInput = [
  body('room')
    .notEmpty()
    .withMessage('방 ID는 필수입니다.')
    .isMongoId()
    .withMessage('올바른 방 ID가 아닙니다.'),
  body('category')
    .notEmpty()
    .withMessage('카테고리 ID는 필수입니다.')
    .isMongoId()
    .withMessage('올바른 카테고리 ID가 아닙니다.'),
  body('dayOfWeek')
    .notEmpty()
    .withMessage('요일은 필수입니다.')
    .isInt({ min: 0, max: 6 })
    .withMessage('요일은 0-6 사이의 숫자여야 합니다.'),
  body('startHour')
    .notEmpty()
    .withMessage('시작 시간은 필수입니다.')
    .isInt({ min: 0, max: 23 })
    .withMessage('시작 시간은 0-23 사이의 숫자여야 합니다.'),
  body('endHour')
    .notEmpty()
    .withMessage('종료 시간은 필수입니다.')
    .isInt({ min: 1, max: 24 })
    .withMessage('종료 시간은 1-24 사이의 숫자여야 합니다.')
];

const reservationScheduleController = {
  /**
   * 현재 주 예약 일정 조회 (승인된 예약만)
   */
  async getCurrentWeekSchedules(req, res) {
    try {
      const { roomId, categoryId } = req.query;

      if (!roomId) {
        return res.status(400).json({
          resultCode: '400',
          resultMessage: '방 ID는 필수입니다.'
        });
      }

      const schedules = await reservationScheduleService.getCurrentWeekSchedules(
        roomId,
        categoryId
      );

      res.json({
        resultCode: '200',
        resultMessage: '현재 주 예약 일정 조회 성공',
        data: schedules
      });
    } catch (error) {
      console.error('현재 주 예약 일정 조회 에러:', error);
      res.status(500).json({
        resultCode: '500',
        resultMessage: '서버 에러가 발생했습니다.',
        error: error.message
      });
    }
  },

  /**
   * 특정 주 예약 일정 조회 (승인된 예약만)
   */
  async getWeeklySchedules(req, res) {
    try {
      const { roomId, weekStartDate, categoryId } = req.query;

      if (!roomId || !weekStartDate) {
        return res.status(400).json({
          resultCode: '400',
          resultMessage: '방 ID와 주 시작 날짜는 필수입니다.'
        });
      }

      const schedules = await reservationScheduleService.getWeeklySchedules(
        roomId,
        weekStartDate,
        categoryId
      );

      res.json({
        resultCode: '200',
        resultMessage: '주간 예약 일정 조회 성공',
        data: schedules
      });
    } catch (error) {
      console.error('주간 예약 일정 조회 에러:', error);
      res.status(500).json({
        resultCode: '500',
        resultMessage: '서버 에러가 발생했습니다.',
        error: error.message
      });
    }
  },

  /**
   * 승인 대기 중인 예약 목록 조회
   */
  async getPendingReservations(req, res) {
    try {
      const { roomId } = req.query;
      const userId = req.user._id;

      if (!roomId) {
        return res.status(400).json({
          resultCode: '400',
          resultMessage: '방 ID는 필수입니다.'
        });
      }

      const pendingReservations = await reservationScheduleService.getPendingReservations(
        roomId,
        userId
      );

      res.json({
        resultCode: '200',
        resultMessage: '승인 대기 중인 예약 목록 조회 성공',
        data: pendingReservations
      });
    } catch (error) {
      console.error('승인 대기 중인 예약 목록 조회 에러:', error);
      res.status(500).json({
        resultCode: '500',
        resultMessage: '서버 에러가 발생했습니다.',
        error: error.message
      });
    }
  },

  /**
   * 예약 일정 생성
   */
  async createSchedule(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          resultCode: '400',
          resultMessage: '입력값이 올바르지 않습니다.',
          errors: errors.array()
        });
      }

      const userId = req.user._id;
      const scheduleData = req.body;

      const schedule = await reservationScheduleService.createSchedule(scheduleData, userId);

      res.status(201).json({
        resultCode: '201',
        resultMessage: '예약 일정 생성 성공',
        data: schedule
      });
    } catch (error) {
      console.error('예약 일정 생성 에러:', error);
      
      const statusCode = error.statusCode || 500;
      res.status(statusCode).json({
        resultCode: statusCode.toString(),
        resultMessage: error.message || '서버 에러가 발생했습니다.'
      });
    }
  },

  /**
   * 예약 승인
   */
  async approveReservation(req, res) {
    try {
      const { scheduleId } = req.params;
      const userId = req.user._id;

      const result = await reservationScheduleService.approveReservation(scheduleId, userId);

      res.json({
        resultCode: '200',
        resultMessage: '예약 승인 성공',
        data: result
      });
    } catch (error) {
      console.error('예약 승인 에러:', error);
      
      const statusCode = error.statusCode || 500;
      res.status(statusCode).json({
        resultCode: statusCode.toString(),
        resultMessage: error.message || '서버 에러가 발생했습니다.'
      });
    }
  },

  /**
   * 예약 삭제
   */
  async deleteSchedule(req, res) {
    try {
      const { scheduleId } = req.params;
      const userId = req.user._id;

      await reservationScheduleService.deleteSchedule(scheduleId, userId);

      res.json({
        resultCode: '200',
        resultMessage: '예약 삭제 성공'
      });
    } catch (error) {
      console.error('예약 삭제 에러:', error);
      
      const statusCode = error.statusCode || 500;
      res.status(statusCode).json({
        resultCode: statusCode.toString(),
        resultMessage: error.message || '서버 에러가 발생했습니다.'
      });
    }
  }
};

module.exports = { reservationScheduleController, validateScheduleInput };