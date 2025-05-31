// backend/controllers/reservationScheduleController.js
const reservationScheduleService = require('../services/reservationScheduleService');
const { successResponse } = require('../utils/responses');

const reservationScheduleController = {
  /**
   * 주간 예약 일정 조회
   */
  async getWeeklySchedules(req, res, next) {
    try {
      const { roomId } = req.params;
      const { weekStartDate, categoryId } = req.query;

      const schedules = await reservationScheduleService.getWeeklySchedules(
        roomId,
        weekStartDate,
        categoryId
      );

      res.json(successResponse(schedules, '주간 예약 일정을 조회했습니다.'));
    } catch (error) {
      next(error);
    }
  },

  /**
   * 현재 주 예약 일정 조회
   */
  async getCurrentWeekSchedules(req, res, next) {
    try {
      const { roomId } = req.params;
      const { categoryId } = req.query;

      const schedules = await reservationScheduleService.getCurrentWeekSchedules(
        roomId,
        categoryId
      );

      res.json(successResponse(schedules, '현재 주 예약 일정을 조회했습니다.'));
    } catch (error) {
      next(error);
    }
  },

  async getCategoryWeeklySchedules(req, res, next) {
      try {
        const { roomId, categoryId } = req.params;

        const schedules = await reservationScheduleService.getCategoryWeeklySchedules(
          roomId,
          categoryId
        );

        res.json(successResponse(schedules, '카테고리별 주간 예약 일정을 조회했습니다.'));
      } catch (error) {
        next(error);
      }
  },

  /**
   * 방문객 예약 조회
   */
  async getVisitorReservations(req, res, next) {
    try {
      const { roomId } = req.params;

      const reservations = await reservationScheduleService.getVisitorReservations(
        roomId
      );

      res.json(successResponse(reservations, '방문객 예약을 조회했습니다.'));
    } catch (error) {
      next(error);
    }
  },

  /**
   * 승인 대기 중인 예약 목록 조회
   */
  async getPendingReservations(req, res, next) {
    try {
      const { roomId } = req.params;
      const userId = req.user.id;

      const reservations = await reservationScheduleService.getPendingReservations(
        roomId,
        userId
      );

      res.json(successResponse(reservations, '승인 대기 중인 예약을 조회했습니다.'));
    } catch (error) {
      next(error);
    }
  },

  /**
   * 예약 일정 생성 - 함수명 수정
   */
  async createSchedule(req, res, next) {
    try {
      const scheduleData = req.body;
      const userId = req.user.id;

      // createSchedule 대신 올바른 함수명 사용
      const schedule = await reservationScheduleService.createSchedule(scheduleData, userId);

      res.status(201).json(successResponse(schedule, '예약이 생성되었습니다.'));
    } catch (error) {
      next(error);
    }
  },

  /**
   * 예약 승인
   */
  async approveReservation(req, res, next) {
    try {
      const { reservationId } = req.params;
      const userId = req.user.id;

      const result = await reservationScheduleService.approveReservation(reservationId, userId);

      const message = result.isFullyApproved
        ? '예약이 완전히 승인되었습니다.'
        : '예약 승인이 추가되었습니다.';

      res.json(successResponse(result, message));
    } catch (error) {
      next(error);
    }
  },

  /**
   * 예약 삭제
   */
  async deleteSchedule(req, res, next) {
    try {
      const { scheduleId } = req.params;
      const userId = req.user.id;

      await reservationScheduleService.deleteSchedule(scheduleId, userId);

      res.json(successResponse(null, '예약이 삭제되었습니다.'));
    } catch (error) {
      next(error);
    }
  }
};

module.exports = reservationScheduleController;