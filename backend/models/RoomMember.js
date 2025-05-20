const mongoose = require('mongoose');

const roomMemberSchema = new mongoose.Schema({
  userId: { // 사용자 ID
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  roomId: { // 방 ID
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room',
    required: true
  },
  isOwner: { // 방장 여부
    type: Boolean,
    default: false
  },
  joinedAt: { // 참여 시간
    type: Date,
    default: Date.now
  }
});

// userId와 roomId의 조합이 유일해야 함
roomMemberSchema.index({ userId: 1, roomId: 1 }, { unique: true });

// 사용자당 하나의 방만 참여할 수 있도록 userId에 유니크 인덱스 추가
roomMemberSchema.index({ userId: 1 }, { unique: true });

module.exports = mongoose.model('RoomMember', roomMemberSchema);
