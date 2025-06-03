// backend/models/Notification.js
const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  // 알림 받을 사용자
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  // 알림을 발생시킨 사용자 (선택적)
  fromUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  // 관련 방
  roomId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room',
    required: true
  },
  // 알림 유형
  type: {
    type: String,
    enum: [
      'member_joined',       // 새 멤버 참여
      'member_left',         // 멤버 나감
      'member_kicked',       // 멤버 추방
      'ownership_transferred', // 방장 위임
      'chore_assigned',      // 집안일 배정
      'chore_completed',     // 집안일 완료
      'reservation_created', // 예약 생성
      'reservation_approved', // 예약 승인
      'visitor_request',     // 방문객 예약 요청
      'category_created',    // 카테고리 생성
      'room_updated',        // 방 정보 수정
      'invite_code_generated' // 초대 코드 생성
    ],
    required: true
  },
  // 알림 제목
  title: {
    type: String,
    required: true
  },
  // 알림 내용
  message: {
    type: String,
    required: true
  },
  // 관련 데이터 (일정 ID, 예약 ID 등)
  relatedData: {
    type: mongoose.Schema.Types.Mixed
  },
  // 읽음 여부
  isRead: {
    type: Boolean,
    default: false
  },
  // 읽은 시간
  readAt: {
    type: Date
  }
}, {
  timestamps: true
});

// 인덱스 설정
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ roomId: 1, createdAt: -1 });
notificationSchema.index({ isRead: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);