// backend/jobs/reservationScheduler.js
const cron = require('node-cron');
const reservationScheduleService = require('../services/reservationScheduleService');

// 매일 새벽 1시에 지난 예약들 정리
cron.schedule('0 1 * * *', async () => {
  try {
    console.log('지난 예약 정리 작업 시작...');
    const deletedCount = await reservationScheduleService.cleanupOldReservations();
    console.log(`지난 예약 정리 완료: ${deletedCount}개 삭제`);
  } catch (error) {
    console.error('지난 예약 정리 중 오류:', error);
  }
});

// 매주 일요일 밤 11시에 다음 주 반복 예약 생성
cron.schedule('0 23 * * 0', async () => {
  try {
    console.log('다음 주 반복 예약 생성 작업 시작...');
    const createdCount = await reservationScheduleService.createNextWeekRecurringReservations();
    console.log(`다음 주 반복 예약 생성 완료: ${createdCount}개 생성`);
  } catch (error) {
    console.error('다음 주 반복 예약 생성 중 오류:', error);
  }
});

console.log('예약 스케줄러가 시작되었습니다.');

module.exports = {};