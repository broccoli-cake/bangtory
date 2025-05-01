const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  kakaoId: {
    type: String,
    unique: true,
    sparse: true
  },
  email: {
    type: String,
    unique: true,
    sparse: true
  },
  nickname: String,
  profileImage: String,
  provider: {
    type: String,
    required: true,
    default: 'kakao'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const User = mongoose.model('User', userSchema);

module.exports = User;
