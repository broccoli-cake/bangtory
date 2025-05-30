const Room = require('../models/Room');
const RoomMember = require('../models/RoomMember');
const mongoose = require('mongoose');
const { generateRandomNickname, generateUniqueNicknameInRoom } = require('../utils/generateNickname');
const crypto = require('crypto');

// 유틸리티 함수들
const utils = {
  // 6자리 랜덤 초대 코드 생성
  generateInviteCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return code;
  },

  // 중복되지 않는 초대 코드 생성
  async generateUniqueInviteCode() {
    const code = Math.random().toString(36).substring(2, 8).toUpperCase();
    const existingRoom = await Room.findOne({ inviteCode: code });
    if (existingRoom) {
      return utils.generateUniqueInviteCode();
    }
    return code;
  },

  // 초대 코드 만료 시간 설정 (3시간)
  getInviteCodeExpiry() {
    const expiry = new Date();
    expiry.setHours(expiry.getHours() + 3);
    return expiry;
  }
};

const roomService = {
  /**
   * 새로운 방 생성
   * @param {Object} roomData - 방 생성 데이터
   * @param {string} ownerId - 방장 ID
   * @returns {Promise<Object>} 생성된 방 정보
   */
  async createRoom(roomData, ownerId) {
    let savedRoom = null;
    try {
      console.log('1. 기존 방 참여 여부 확인 시작');
      // 기존 방 참여 여부 확인
      const existingMember = await RoomMember.findOne({ userId: ownerId });
      if (existingMember) {
        throw new Error('이미 참여 중인 방이 있습니다.');
      }
      console.log('1. 기존 방 참여 여부 확인 완료');

      const { roomName, address } = roomData;

      console.log('2. Room 생성 시작');
      // Room 생성 (RoomMember는 post save 미들웨어에서 자동 생성)
      const newRoom = new Room({
        roomName,
        address,
        ownerId,
        inviteCode: await utils.generateUniqueInviteCode(),
        inviteCodeExpiresAt: utils.getInviteCodeExpiry()
      });
      
      savedRoom = await newRoom.save();
      console.log('2. Room 생성 완료:', savedRoom._id);

      return savedRoom;
    } catch (error) {
      console.error('방 생성 중 에러 발생:', error);
      // Room이 생성되었는데 다른 작업이 실패한 경우 Room 삭제
      if (savedRoom) {
        console.log('실패한 Room 삭제 시도:', savedRoom._id);
        await Room.findByIdAndDelete(savedRoom._id);
      }
      throw error;
    }
  },

  /**
   * 초대 코드로 방 참여
   * @param {string} inviteCode - 초대 코드
   * @param {string} userId - 참여할 사용자 ID
   * @returns {Promise<Object>} 참여한 방 정보
   */
  async joinRoom(inviteCode, userId) {
    try {
      const existingMember = await RoomMember.findOne({ userId });
      if (existingMember) {
        throw new Error('이미 참여 중인 방이 있습니다.');
      }

      const room = await Room.findOne({
        inviteCode,
        inviteCodeExpiresAt: { $gt: new Date() }
      });

      if (!room) {
        throw new Error('유효하지 않거나 만료된 초대코드입니다.');
      }

      // 방 내에서 중복되지 않는 닉네임 생성
      const nickname = await generateUniqueNicknameInRoom(room._id);

      const roomMember = new RoomMember({
        userId,
        roomId: room._id,
        isOwner: false,
        nickname
      });

      await roomMember.save();
      room.members.push(roomMember._id);
      await room.save();

      return room;
    } catch (error) {
      throw error;
    }
  },

  /**
   * 현재 참여 중인 방 조회
   * @param {string} userId - 사용자 ID
   * @returns {Promise<Object>} 참여 중인 방 정보
   */
  async getMyRoom(userId) {
    const roomMember = await RoomMember.findOne({ userId })
      .populate('roomId');
    
    if (!roomMember) {
      throw new Error('참여 중인 방이 없습니다.');
    }

    return roomMember;
  },

  /**
   * 방 상세 정보 조회
   * @param {string} roomId - 방 ID
   * @param {string} userId - 사용자 ID
   * @returns {Promise<Object>} 방 상세 정보
   */
  async getRoomDetail(roomId, userId) {
    const roomMember = await RoomMember.findOne({
      roomId,
      userId
    });
    if (!roomMember) {
      throw new Error('해당 방에 대한 접근 권한이 없습니다.');
    }

    const room = await Room.findById(roomId)
      .populate({
        path: 'members',
        select: 'userId isOwner'
      });

    if (!room) {
      throw new Error('방을 찾을 수 없습니다.');
    }

    return room;
  },

  /**
   * 방 삭제
   * @param {string} roomId - 방 ID
   * @param {string} userId - 사용자 ID
   * @returns {Promise<void>}
   */
  async deleteRoom(roomId, userId) {
    try {
      const room = await Room.findOne({ _id: roomId, ownerId: userId });
      if (!room) {
        throw new Error('방장만 방을 삭제할 수 있습니다.');
      }

      await RoomMember.deleteMany({ roomId });
      await room.deleteOne();
    } catch (error) {
      throw error;
    }
  },

  /**
   * 방 나가기
   * @param {string} roomId - 방 ID
   * @param {string} userId - 사용자 ID
   * @param {string} newOwnerId - 새로운 방장 ID (방장인 경우 필수)
   * @returns {Promise<void>}
   */
  async leaveRoom(roomId, userId, newOwnerId) {
    try {
      const roomMember = await RoomMember.findOne({
        roomId,
        userId
      });
      if (!roomMember) {
        throw new Error('해당 방의 멤버가 아닙니다.');
      }

      if (roomMember.isOwner) {
        if (!newOwnerId) {
          throw new Error('방장은 새로운 방장을 지정해야 합니다.');
        }

        const newOwner = await RoomMember.findOne({
          roomId,
          userId: newOwnerId
        });
        if (!newOwner) {
          throw new Error('새로운 방장이 해당 방의 멤버가 아닙니다.');
        }

        newOwner.isOwner = true;
        await newOwner.save();

        const room = await Room.findById(roomId);
        room.ownerId = newOwnerId;
        await room.save();
      }

      await roomMember.deleteOne();

      const room = await Room.findById(roomId);
      room.members = room.members.filter(memberId => memberId.toString() !== roomMember._id.toString());
      await room.save();
    } catch (error) {
      throw error;
    }
  },

  /**
   * 방 정보 수정
   * @param {string} roomId - 방 ID
   * @param {string} userId - 사용자 ID
   * @param {Object} updateData - 수정할 데이터
   * @returns {Promise<Object>} 수정된 방 정보
   */
  async updateRoom(roomId, userId, updateData) {
    const room = await Room.findOne({ _id: roomId, ownerId: userId });
    if (!room) {
      throw new Error('방장만 방 정보를 수정할 수 있습니다.');
    }

    Object.assign(room, updateData);
    return await room.save();
  },

  /**
   * 초대 코드 생성
   */
  async generateInviteCode(roomId, userId) {
    const room = await Room.findOne({ _id: roomId, ownerId: userId });
    if (!room) {
      throw new Error('방장만 초대코드를 생성할 수 있습니다.');
    }

    room.inviteCode = await utils.generateUniqueInviteCode();
    room.inviteCodeExpiresAt = utils.getInviteCodeExpiry();
    await room.save();

    return room;
  },

  /**
   * 방 멤버 목록 조회
   */
  async getRoomMembers(roomId) {
    const room = await Room.findById(roomId);
    if (!room) {
      throw new Error('방을 찾을 수 없습니다.');
    }

    const members = await RoomMember.find({ roomId })
      .select('userId nickname isOwner joinedAt')
      .sort({ joinedAt: 1 });

    return members;
  },

  async kickMember(roomId, userId, ownerId) {
    // 1. 방장 본인은 내보낼 수 없음
    const room = await Room.findById(roomId);
    if (!room) throw new Error('방이 존재하지 않습니다.');
    if (String(room.ownerId) !== String(ownerId)) throw new Error('방장만 멤버를 내보낼 수 있습니다.');
    if (String(ownerId) === String(userId)) throw new Error('방장은 자신을 내보낼 수 없습니다.');

    // 2. 해당 멤버가 방에 속해있는지 확인
    const member = await RoomMember.findOne({ roomId, userId });
    if (!member) throw new Error('해당 멤버가 방에 없습니다.');

    // 3. RoomMember 삭제
    await RoomMember.deleteOne({ roomId, userId });

    // 4. Room의 members 배열에서도 제거
    await Room.findByIdAndUpdate(roomId, { $pull: { members: member._id } });
  }
};

module.exports = roomService;
