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
  type: {
    type: String,
    enum: ['default', 'custom'],
    default: 'custom'
  }
}, {
  timestamps: true
});

// 기본 카테고리 초기화 메서드
choreCategorySchema.statics.initializeDefaultCategories = async function(userId) {
  const defaultCategories = [
    { name: '청소', icon: '🧹', type: 'default' },
    { name: '분리수거', icon: '♻️', type: 'default' },
    { name: '설거지', icon: '🍽️', type: 'default' }
  ];

  for (const category of defaultCategories) {
    await this.findOneAndUpdate(
      { name: category.name, type: 'default' },
      { ...category, createdBy: userId },
      { upsert: true }
    );
  }
};

module.exports = mongoose.model('ChoreCategory', choreCategorySchema); 