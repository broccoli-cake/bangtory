// backend/schedulers/notificationScheduler.js
const cron = require('node-cron');
const notificationService = require('../services/notificationService');

// 매일 새벽 2시에 오래된 알림들 정리
cron.schedule('0 2 * * *', async () => {
  try {
    console.log('오래된 알림 정리 작업 시작...');
    const deletedCount = await notificationService.cleanupOldNotifications();
    console.log(`오래된 알림 정리 완료: ${deletedCount}개 삭제`);
  } catch (error) {
    console.error('오래된 알림 정리 중 오류:', error);
  }
});

console.log('알림 스케줄러가 시작되었습니다.');

module.exports = {};