// backend/models/User.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  kakaoId: { type: String, unique: true },
  username: String,
  displayName: String,
  provider: String,
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', userSchema);
