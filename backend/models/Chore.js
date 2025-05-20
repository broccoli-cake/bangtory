const mongoose = require('mongoose');

const choreSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  icon: {
    type: String,
    required: true
  },
  color: {
    type: String,
    required: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  type: {
    type: String,
    enum: ['default', 'custom'],
    default: 'custom'
  }
}, {
  timestamps: true
});

// 기본 카테고리 초기화 함수
choreSchema.statics.initializeDefaultCategories = async function() {
  const defaultCategories = [
    {
      name: '청소',
      icon: '🧹',
      color: '#FF6B6B',
      type: 'default'
    },
    {
      name: '분리수거',
      icon: '♻️',
      color: '#4ECDC4',
      type: 'default'
    },
    {
      name: '설거지',
      icon: '🍽️',
      color: '#45B7D1',
      type: 'default'
    }
  ];

  for (const category of defaultCategories) {
    await this.findOneAndUpdate(
      { name: category.name, type: 'default' },
      category,
      { upsert: true, new: true }
    );
  }
};

const Chore = mongoose.model('Chore', choreSchema);

module.exports = Chore; 