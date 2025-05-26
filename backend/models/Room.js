const mongoose = require('mongoose');
const RoomMember = require('./RoomMember');
const { generateUniqueNicknameInRoom } = require('../utils/generateNickname');
const User = require('./User');

const roomSchema = new mongoose.Schema({
  roomName: { // 방 이름
    type: String,
    required: true
  },
  address: { // 방 주소
    type: String
  },
  ownerId: { // 방장 ID
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  members: [{ // 방 멤버 목록
    type: mongoose.Schema.Types.ObjectId,
    ref: 'RoomMember'
  }],
  inviteCode: { // 초대코드
    type: String
  },
  inviteCodeExpiresAt: { // 초대 코드 만료 at..
    type: Date
  },
  createdAt: { // 생성일 (자동)
    type: Date,
    default: Date.now
  },
  updatedAt: { // 마지막 수정일 (자동)
    type: Date,
    default: Date.now
  }
});

// updatedAt 자동 업데이트를 위한 미들웨어
roomSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// 방 생성 시 자동으로 방장을 RoomMember로 등록
roomSchema.post('save', async function(doc) {
  try {
    const existingMember = await RoomMember.findOne({
      userId: doc.ownerId,
      roomId: doc._id
    });

    if (!existingMember) {
      // User 닉네임 가져오기
      const user = await User.findById(doc.ownerId);
      const nickname = user.nickname; // User 닉네임 사용

      // RoomMember 생성
      const roomMember = await RoomMember.create({
        userId: doc.ownerId,
        roomId: doc._id,
        isOwner: true,
        nickname
      });

      doc.members.push(roomMember._id);
      await doc.save();
    }
  } catch (error) {
    console.error('방장 RoomMember 생성 에러:', error);
  }
});

module.exports = mongoose.model('Room', roomSchema);