// backend/models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  provider: {
    type: String,
    required: true,
    enum: ['kakao', 'google', 'naver', 'manual']
  },
  providerId: {
    type: String,
    required: true
  }
}, {
  timestamps: true
});

// provider와 providerId의 조합이 유일해야 함
userSchema.index({ provider: 1, providerId: 1 }, { unique: true });

module.exports = mongoose.model('User', userSchema);