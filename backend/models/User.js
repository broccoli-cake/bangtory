// backend/models/User.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  provider: {
    type: String,
    enum: ['kakao', 'google', 'naver'],
    required: true
  },
  providerId: {
    type: String,
    required: true
  },
  username: { type: String, required: true },
  displayName: { type: String },
  createdAt: { type: Date, default: Date.now }
});

// provider와 providerId의 조합이 유일해야 함
userSchema.index({ provider: 1, providerId: 1 }, { unique: true });

module.exports = mongoose.model('User', userSchema);
