const mongoose = require('mongoose');

const reservationCategorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  icon: {
    type: String,
    required: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  room: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room',
    required: true  // 방 ID 필수로 변경
  },
  type: {
    type: String,
    enum: ['default', 'custom'],
    default: 'custom'
  },
  requiresApproval: {
    type: Boolean,
    default: false
  },
  isVisitor: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// 방별 카테고리 인덱스 추가
reservationCategorySchema.index({ room: 1, name: 1 });

// 기본 예약 카테고리 초기화 메서드 - 방별로 생성
reservationCategorySchema.statics.initializeDefaultCategories = async function(userId, roomId) {
  const defaultCategories = [
    { name: '세탁기', icon: 'local_laundry_service', type: 'default', requiresApproval: false, isVisitor: false },
    { name: '욕실', icon: 'bathtub', type: 'default', requiresApproval: false, isVisitor: false },
    { name: '방문객', icon: 'emoji_people', type: 'default', requiresApproval: true, isVisitor: true }
  ];

  for (const category of defaultCategories) {
    await this.findOneAndUpdate(
      { name: category.name, type: 'default', room: roomId },
      { ...category, createdBy: userId, room: roomId },
      { upsert: true }
    );
  }
};

module.exports = mongoose.model('ReservationCategory', reservationCategorySchema);