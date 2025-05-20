const mongoose = require('mongoose');

const roomMemberSchema = new mongoose.Schema({
  roomId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room',
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  nickname: {
    type: String,
    required: true
  },
  isOwner: {
    type: Boolean,
    default: false
  },
  joinedAt: { // 참여 시간
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// userId와 roomId의 조합이 유일해야 함
roomMemberSchema.index({ userId: 1, roomId: 1 }, { unique: true });

// 사용자당 하나의 방만 참여할 수 있도록 userId에 유니크 인덱스 추가
roomMemberSchema.index({ userId: 1 }, { unique: true });

// 방 내에서 닉네임 중복 방지
roomMemberSchema.index({ roomId: 1, nickname: 1 }, { unique: true });

module.exports = mongoose.model('RoomMember', roomMemberSchema);
