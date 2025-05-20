const Room = require('../models/Room');
const RoomMember = require('../models/RoomMember');
const mongoose = require('mongoose');
const { body, validationResult } = require('express-validator');

// 입력값 검증 미들웨어
const validateRoomInput = [
  body('roomName').trim().escape().notEmpty(),
  body('address').optional().trim().escape(),
  // ... 다른 검증 규칙
];

// 유틸리티 함수들
const utils = {
  // 6자리 랜덤 초대 코드 생성 함수
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
    let code;
    let isUnique = false;
    while (!isUnique) {
      code = this.generateInviteCode();
      const existingRoom = await Room.findOne({ inviteCode: code });
      if (!existingRoom) {
        isUnique = true;
      }
    }
    return code;
  },

  // 초대 코드 만료 시간 설정 (3분)
  getInviteCodeExpiry() {
    return new Date(Date.now() + 3 * 60 * 1000);
  },

  // 응답 포맷 생성 함수
  createResponse(status, message, data = null) {
    const response = {
      resultCode: status.toString(),
      resultMessage: message
    };
    if (data) {
      Object.assign(response, data);
    }
    return response;
  }
};

// 에러 처리 미들웨어
const errorHandler = (err, req, res, next) => {
  if (err.name === 'ValidationError') {
    return res.status(400).json(utils.createResponse(400, '잘못된 입력입니다.'));
  }
  if (err.name === 'CastError') {
    return res.status(400).json(utils.createResponse(400, '잘못된 입력입니다.'));
  }
  // ... 다른 에러 타입 처리
  return res.status(500).json(utils.createResponse(500, '서버 오류로 요청을 처리하는 중 에러가 발생했습니다.'));
};

// 방 관련 컨트롤러
const roomController = {
  /**
   * 방 생성 컨트롤러
   * @route POST /rooms
   * @description 새로운 방을 생성하고 초대 코드를 발급합니다.
   * @param {string} roomName - 방 이름 (필수)
   * @param {string} address - 방 주소 (선택)
   * @returns {Object} 생성된 방 정보와 초대 코드
   */
  async createRoom(req, res) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const { roomName, address } = req.body;
      const ownerId = req.user._id;

      if (!roomName) {
        return res.status(400).json(
          utils.createResponse(400, '방 이름은 필수입니다.')
        );
      }

      const newRoom = new Room({
        roomName,
        address,
        ownerId,
        inviteCode: await utils.generateUniqueInviteCode(),
        inviteCodeExpiresAt: utils.getInviteCodeExpiry()
      });
      
      const savedRoom = await newRoom.save({ session });

      await session.commitTransaction();

      return res.status(201).json(
        utils.createResponse(201, '방 생성 완료', {
          room: {
            roomId: savedRoom._id,
            roomName: savedRoom.roomName,
            address: savedRoom.address
          },
          inviteCode: savedRoom.inviteCode,
          expiresIn: 180
        })
      );
    } catch (error) {
      await session.abortTransaction();
      console.error('방 생성 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 방 생성에 실패했습니다.')
      );
    } finally {
      session.endSession();
    }
  },

  /**
   * 초대코드 생성 컨트롤러
   * @route POST /rooms/invite
   * @description 방장이 새로운 초대 코드를 생성합니다.
   * @param {string} roomId - 방 ID
   * @returns {Object} 새로 생성된 초대 코드와 만료 시간
   */
  async generateInviteCode(req, res) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const { roomId } = req.body;
      const userId = req.user._id;

      const room = await Room.findOne({ _id: roomId, ownerId: userId });
      if (!room) {
        return res.status(403).json(
          utils.createResponse(403, '방장만 초대코드를 생성할 수 있습니다.')
        );
      }

      room.inviteCode = await utils.generateUniqueInviteCode();
      room.inviteCodeExpiresAt = utils.getInviteCodeExpiry();
      await room.save({ session });

      await session.commitTransaction();

      return res.status(200).json(
        utils.createResponse(200, '초대 코드 생성 완료', {
          inviteCode: room.inviteCode,
          expiresIn: 180
        })
      );
    } catch (error) {
      await session.abortTransaction();
      console.error('초대코드 생성 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 초대코드 생성에 실패했습니다.')
      );
    } finally {
      session.endSession();
    }
  },

  /**
   * 방 참여 컨트롤러
   * @route POST /rooms/join
   * @description 초대 코드를 사용하여 방에 참여합니다.
   * @param {string} inviteCode - 초대 코드
   * @returns {Object} 참여한 방 정보
   */
  async joinRoom(req, res) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const { inviteCode } = req.body;
      const userId = req.user._id;

      const existingMember = await RoomMember.findOne({ userId });
      if (existingMember) {
        return res.status(400).json(
          utils.createResponse(400, '이미 참여 중인 방이 있습니다.')
        );
      }

      const room = await Room.findOne({
        inviteCode,
        inviteCodeExpiresAt: { $gt: new Date() }
      });

      if (!room) {
        return res.status(400).json(
          utils.createResponse(400, '유효하지 않거나 만료된 초대코드입니다.')
        );
      }

      const roomMember = new RoomMember({
        userId,
        roomId: room._id,
        isOwner: false
      });

      await roomMember.save({ session });

      room.members.push(roomMember._id);
      await room.save({ session });

      await session.commitTransaction();

      return res.status(200).json(
        utils.createResponse(200, '방 참여 완료', {
          room: {
            roomId: room._id,
            roomName: room.roomName
          }
        })
      );
    } catch (error) {
      await session.abortTransaction();
      console.error('방 참여 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 방 참여에 실패했습니다.')
      );
    } finally {
      session.endSession();
    }
  },

  /**
   * 현재 참여 중인 방 조회 컨트롤러
   * @route GET /rooms/me
   * @description 현재 로그인한 사용자가 참여 중인 방 정보를 조회합니다.
   * @returns {Object} 참여 중인 방 정보
   */
  async getMyRoom(req, res) {
    try {
      const userId = req.user._id;

      // 사용자의 방 멤버 정보 조회
      const roomMember = await RoomMember.findOne({ userId })
        .populate('roomId');

      if (!roomMember) {
        return res.status(404).json(
          utils.createResponse(404, '참여 중인 방이 없습니다.')
        );
      }

      return res.status(200).json(
        utils.createResponse(200, '방 정보 조회 완료', {
          room: {
            roomId: roomMember.roomId._id,
            roomName: roomMember.roomId.roomName,
            address: roomMember.roomId.address,
            isOwner: roomMember.isOwner
          }
        })
      );
    } catch (error) {
      console.error('방 조회 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 방 조회에 실패했습니다.')
      );
    }
  },

  /**
   * 방 상세 정보 조회 컨트롤러
   * @route GET /rooms/:roomId
   * @description 특정 방의 상세 정보를 조회합니다.
   * @param {string} roomId - 방 ID
   * @returns {Object} 방 상세 정보와 멤버 목록
   */
  async getRoomDetail(req, res) {
    try {
      const { roomId } = req.params;
      const userId = req.user._id;

      // 방 멤버인지 확인
      const roomMember = await RoomMember.findOne({ userId, roomId });
      if (!roomMember) {
        return res.status(403).json(
          utils.createResponse(403, '방 멤버만 접근할 수 있습니다.')
        );
      }

      // 방 정보와 멤버 정보 조회
      const room = await Room.findById(roomId)
        .populate('members', 'userId isOwner');

      if (!room) {
        return res.status(404).json(
          utils.createResponse(404, '방을 찾을 수 없습니다.')
        );
      }

      return res.status(200).json(
        utils.createResponse(200, '방 상세 정보 조회 완료', {
          room: {
            roomId: room._id,
            roomName: room.roomName,
            address: room.address,
            members: room.members.map(member => ({
              userId: member.userId,
              isOwner: member.isOwner
            }))
          }
        })
      );
    } catch (error) {
      console.error('방 상세 정보 조회 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 방 상세 정보 조회에 실패했습니다.')
      );
    }
  },

  /**
   * 방 삭제 컨트롤러
   * @route DELETE /rooms/:roomId
   * @description 방장이 방을 삭제합니다.
   * @param {string} roomId - 방 ID
   * @returns {Object} 삭제 결과
   */
  async deleteRoom(req, res) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const { roomId } = req.params;
      const userId = req.user._id;

      const room = await Room.findOne({ _id: roomId, ownerId: userId });
      if (!room) {
        return res.status(403).json(
          utils.createResponse(403, '방장만 방을 삭제할 수 있습니다.')
        );
      }

      await RoomMember.deleteMany({ roomId }, { session });
      await room.deleteOne({ session });

      await session.commitTransaction();

      return res.status(200).json(
        utils.createResponse(200, '방 삭제 완료')
      );
    } catch (error) {
      await session.abortTransaction();
      console.error('방 삭제 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 방 삭제에 실패했습니다.')
      );
    } finally {
      session.endSession();
    }
  },

  /**
   * 방 나가기 컨트롤러
   * @route DELETE /rooms/me
   * @description 방을 나갑니다. 방장인 경우 새로운 방장을 지정해야 합니다.
   * @param {string} roomId - 방 ID
   * @param {string} newOwnerId - 새로운 방장 ID (방장인 경우 필수)
   * @returns {Object} 나가기 결과
   */
  async leaveRoom(req, res) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const { roomId, newOwnerId } = req.body;
      const userId = req.user._id;

      const roomMember = await RoomMember.findOne({ userId, roomId });
      if (!roomMember) {
        return res.status(404).json(
          utils.createResponse(404, '참여 중인 방이 아닙니다.')
        );
      }

      if (roomMember.isOwner) {
        if (!newOwnerId) {
          return res.status(400).json(
            utils.createResponse(400, '방장은 방을 나가기 전에 새로운 방장을 지정해야 합니다.')
          );
        }

        const newOwner = await RoomMember.findOne({ userId: newOwnerId, roomId });
        if (!newOwner) {
          return res.status(404).json(
            utils.createResponse(404, '새로운 방장으로 지정할 멤버를 찾을 수 없습니다.')
          );
        }

        newOwner.isOwner = true;
        await newOwner.save({ session });

        const room = await Room.findById(roomId);
        room.ownerId = newOwnerId;
        await room.save({ session });
      }

      await roomMember.deleteOne({ session });

      const room = await Room.findById(roomId);
      room.members = room.members.filter(memberId => memberId.toString() !== roomMember._id.toString());
      await room.save({ session });

      await session.commitTransaction();

      return res.status(200).json(
        utils.createResponse(200, '방 나가기 완료')
      );
    } catch (error) {
      await session.abortTransaction();
      console.error('방 나가기 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 방 나가기에 실패했습니다.')
      );
    } finally {
      session.endSession();
    }
  },

  /**
   * 방 정보 수정 컨트롤러
   * @route PATCH /rooms/:roomId
   * @description 방장이 방 정보를 수정합니다.
   * @param {string} roomId - 방 ID
   * @param {string} roomName - 새로운 방 이름 (선택)
   * @param {string} address - 새로운 방 주소 (선택)
   * @returns {Object} 수정된 방 정보
   */
  async updateRoom(req, res) {
    try {
      const { roomId } = req.params;
      const { roomName, address } = req.body;
      const userId = req.user._id;

      // 방장인지 확인
      const room = await Room.findOne({ _id: roomId, ownerId: userId });
      if (!room) {
        return res.status(403).json(
          utils.createResponse(403, '방장만 방 정보를 수정할 수 있습니다.')
        );
      }

      // 방 정보 업데이트
      if (roomName) room.roomName = roomName;
      if (address) room.address = address;

      await room.save();

      return res.status(200).json(
        utils.createResponse(200, '방 정보 수정 완료', {
          room: {
            roomId: room._id,
            roomName: room.roomName,
            address: room.address
          }
        })
      );
    } catch (error) {
      console.error('방 정보 수정 중 에러:', error);
      return res.status(500).json(
        utils.createResponse(500, '서버 오류로 방 정보 수정에 실패했습니다.')
      );
    }
  }
};

module.exports = roomController;
