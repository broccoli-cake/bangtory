const roomService = require('../services/roomService');
const { body, validationResult } = require('express-validator');
const mongoose = require('mongoose');

// 입력값 검증 미들웨어
const validateRoomInput = [
  body('roomName').trim().escape().notEmpty().withMessage('방 이름은 필수입니다.'),
  body('address').optional().trim().escape()
];

// 응답 포맷 생성 함수
const createResponse = (status, message, data = null) => {
  const response = {
    resultCode: status.toString(),
    resultMessage: message
  };
  if (data) {
    Object.assign(response, data);
  }
  return response;
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
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json(
          createResponse(400, '잘못된 입력입니다.')
        );
      }

      const room = await roomService.createRoom(req.body, req.user._id);
      
      return res.status(201).json(
        createResponse(201, '방 생성 완료', {
          room: {
            roomId: room._id,
            roomName: room.roomName,
            address: room.address
          },
          inviteCode: room.inviteCode,
          expiresIn: 180
        })
      );
    } catch (error) {
      console.error('방 생성 중 에러:', error);
      return res.status(500).json(
        createResponse(500, '서버 오류로 방 생성에 실패했습니다.')
      );
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
    try {
      const { roomId } = req.body;
      const room = await roomService.generateInviteCode(roomId, req.user._id);

      return res.status(200).json(
        createResponse(200, '초대 코드 생성 완료', {
          inviteCode: room.inviteCode,
          expiresIn: 180
        })
      );
    } catch (error) {
      console.error('초대코드 생성 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
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
    try {
      const { inviteCode } = req.body;
      const room = await roomService.joinRoom(inviteCode, req.user._id);

      return res.status(200).json(
        createResponse(200, '방 참여 완료', {
          room: {
            roomId: room._id,
            roomName: room.roomName
          }
        })
      );
    } catch (error) {
      console.error('방 참여 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
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
      const roomMember = await roomService.getMyRoom(req.user._id);

      return res.status(200).json(
        createResponse(200, '방 정보 조회 완료', {
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
      return res.status(404).json(
        createResponse(404, error.message)
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
      const room = await roomService.getRoomDetail(req.params.roomId, req.user._id);

      return res.status(200).json(
        createResponse(200, '방 상세 정보 조회 완료', {
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
      return res.status(403).json(
        createResponse(403, error.message)
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
    try {
      await roomService.deleteRoom(req.params.roomId, req.user._id);

      return res.status(200).json(
        createResponse(200, '방 삭제 완료')
      );
    } catch (error) {
      console.error('방 삭제 중 에러:', error);
      return res.status(403).json(
        createResponse(403, error.message)
      );
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
    try {
      const { roomId, newOwnerId } = req.body;
      await roomService.leaveRoom(roomId, req.user._id, newOwnerId);

      return res.status(200).json(
        createResponse(200, '방 나가기 완료')
      );
    } catch (error) {
      console.error('방 나가기 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
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
      const room = await roomService.updateRoom(
        req.params.roomId,
        req.user._id,
        req.body
      );

      return res.status(200).json(
        createResponse(200, '방 정보 수정 완료', {
          room: {
            roomId: room._id,
            roomName: room.roomName,
            address: room.address
          }
        })
      );
    } catch (error) {
      console.error('방 정보 수정 중 에러:', error);
      return res.status(403).json(
        createResponse(403, error.message)
      );
    }
  }
};

module.exports = {
  ...roomController,
  validateRoomInput
};
