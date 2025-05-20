// backend/models/User.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  nickname: {
    type: String,
    required: true
  },
  profileImageUrl: {
    type: String,
    default: '/images/default-profile.png'  // 기본 프로필 이미지 경로
  },
  provider: {
    type: String,
    required: true,
    enum: ['kakao', 'google', 'naver']
  },
  providerId: {
    type: String,
    required: true
  },
  isProfileSet: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// provider와 providerId의 조합이 유일해야 함
userSchema.index({ provider: 1, providerId: 1 }, { unique: true });

module.exports = mongoose.model('User', userSchema);
