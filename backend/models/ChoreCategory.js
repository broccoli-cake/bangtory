const mongoose = require('mongoose');

const choreCategorySchema = new mongoose.Schema({
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
  }
}, {
  timestamps: true
});

// 방별 카테고리 인덱스 추가
choreCategorySchema.index({ room: 1, name: 1 });

// 기본 카테고리 초기화 메서드 - 방별로 생성
choreCategorySchema.statics.initializeDefaultCategories = async function(userId, roomId) {
  const defaultCategories = [
    { name: '청소', icon: 'cleaning_services', type: 'default' },
    { name: '분리수거', icon: 'delete_outline', type: 'default' },
    { name: '설거지', icon: 'local_dining', type: 'default' }
  ];

  for (const category of defaultCategories) {
    await this.findOneAndUpdate(
      { name: category.name, type: 'default', room: roomId },
      { ...category, createdBy: userId, room: roomId },
      { upsert: true }
    );
  }
};

module.exports = mongoose.model('ChoreCategory', choreCategorySchema);