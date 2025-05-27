// backend/schedulers/reservationScheduler.js
const cron = require('node-cron');
const reservationScheduleService = require('../services/reservationScheduleService');

// 매주 일요일 자정에 지난 주 예약 정리
const scheduleReservationCleanup = () => {
  cron.schedule('0 0 * * 0', async () => {
    try {
      console.log('지난 주 예약 정리 작업 시작...');
      await reservationScheduleService.cleanupOldReservations();
      console.log('지난 주 예약 정리 작업 완료');
    } catch (error) {
      console.error('지난 주 예약 정리 작업 실패:', error);
    }
  });
};

module.exports = {
  scheduleReservationCleanup
};