// backend/models/ReservationCategory.js
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
  type: {
    type: String,
    enum: ['default', 'custom'],
    default: 'custom'
  },
  requiresApproval: {
    type: Boolean,
    default: false
  },
  // 방문객 카테고리 여부 추가
  isVisitor: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// 기본 예약 카테고리 초기화 메서드
reservationCategorySchema.statics.initializeDefaultCategories = async function(userId) {
  const defaultCategories = [
    { name: '세탁기', icon: 'local_laundry_service', type: 'default', requiresApproval: false, isVisitor: false },
    { name: '욕실', icon: 'bathtub', type: 'default', requiresApproval: false, isVisitor: false },
    { name: '방문객', icon: 'emoji_people', type: 'default', requiresApproval: true, isVisitor: true }
  ];

  for (const category of defaultCategories) {
    await this.findOneAndUpdate(
      { name: category.name, type: 'default' },
      { ...category, createdBy: userId },
      { upsert: true }
    );
  }
};

module.exports = mongoose.model('ReservationCategory', reservationCategorySchema);