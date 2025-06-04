// backend/routes/chatRoutes.js
const express = require('express');
const router = express.Router();
const { simpleAuth } = require('../middlewares/simpleAuth');
const ChatMessage = require('../models/ChatMessage');
const RoomMember = require('../models/RoomMember');

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

// 채팅 메시지 목록 조회 (페이지네이션)
router.get('/messages/:roomId', simpleAuth, async (req, res) => {
  try {
    const { roomId } = req.params;
    const { page = 1, limit = 50, before } = req.query;
    const userId = req.user._id;

    // 사용자가 해당 방의 멤버인지 확인
    const roomMember = await RoomMember.findOne({
      roomId: roomId,
      userId: userId
    });

    if (!roomMember) {
      return res.status(403).json(
        createResponse(403, '해당 방에 대한 접근 권한이 없습니다.')
      );
    }

    // 쿼리 조건 설정
    const query = {
      roomId: roomId,
      isDeleted: false
    };

    // before 파라미터가 있으면 해당 시간 이전의 메시지만 조회
    if (before) {
      query.timestamp = { $lt: new Date(before) };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const messages = await ChatMessage.find(query)
      .populate('userId', 'name')
      .sort({ timestamp: -1 }) // 최신 순으로 정렬
      .skip(skip)
      .limit(parseInt(limit));

    // 메시지에 RoomMember 정보 추가
    const messagesWithMemberInfo = await Promise.all(
      messages.map(async (message) => {
        const roomMember = await RoomMember.findOne({
          roomId: roomId,
          userId: message.userId._id
        }).select('nickname profileImageUrl');

        return {
          id: message._id,
          message: message.message,
          messageType: message.messageType,
          timestamp: message.timestamp,
          userId: message.userId._id,
          username: roomMember?.nickname || message.userId.name,
          profileImageUrl: roomMember?.profileImageUrl || '/images/profile1.png',
          isMe: message.userId._id.toString() === userId.toString()
        };
      })
    );

    // 시간 순으로 다시 정렬 (오래된 것부터)
    messagesWithMemberInfo.reverse();

    return res.status(200).json(
      createResponse(200, '채팅 메시지 조회 성공', {
        messages: messagesWithMemberInfo,
        hasMore: messages.length === parseInt(limit)
      })
    );

  } catch (error) {
    console.error('채팅 메시지 조회 중 에러:', error);
    return res.status(500).json(
      createResponse(500, '서버 오류가 발생했습니다.')
    );
  }
});

// 메시지 저장 (Socket.IO에서 호출)
router.post('/messages', simpleAuth, async (req, res) => {
  try {
    const { roomId, message, messageType = 'text' } = req.body;
    const userId = req.user._id;

    // 사용자가 해당 방의 멤버인지 확인
    const roomMember = await RoomMember.findOne({
      roomId: roomId,
      userId: userId
    });

    if (!roomMember) {
      return res.status(403).json(
        createResponse(403, '해당 방에 대한 접근 권한이 없습니다.')
      );
    }

    // 메시지 내용 검증
    if (!message || message.trim().length === 0) {
      return res.status(400).json(
        createResponse(400, '메시지 내용은 비워둘 수 없습니다.')
      );
    }

    if (message.length > 1000) {
      return res.status(400).json(
        createResponse(400, '메시지는 1000자를 초과할 수 없습니다.')
      );
    }

    // 메시지 저장
    const chatMessage = new ChatMessage({
      roomId,
      userId,
      message: message.trim(),
      messageType
    });

    const savedMessage = await chatMessage.save();

    // 저장된 메시지를 populate하여 반환
    const populatedMessage = await ChatMessage.findById(savedMessage._id)
      .populate('userId', 'name');

    const messageWithMemberInfo = {
      id: populatedMessage._id,
      message: populatedMessage.message,
      messageType: populatedMessage.messageType,
      timestamp: populatedMessage.timestamp,
      userId: populatedMessage.userId._id,
      username: roomMember.nickname,
      profileImageUrl: roomMember.profileImageUrl
    };

    return res.status(201).json(
      createResponse(201, '메시지 저장 성공', { message: messageWithMemberInfo })
    );

  } catch (error) {
    console.error('메시지 저장 중 에러:', error);
    return res.status(500).json(
      createResponse(500, '서버 오류가 발생했습니다.')
    );
  }
});

// 메시지 삭제 (본인만 가능)
router.delete('/messages/:messageId', simpleAuth, async (req, res) => {
  try {
    const { messageId } = req.params;
    const userId = req.user._id;

    const message = await ChatMessage.findById(messageId);

    if (!message) {
      return res.status(404).json(
        createResponse(404, '메시지를 찾을 수 없습니다.')
      );
    }

    // 본인의 메시지인지 확인
    if (message.userId.toString() !== userId.toString()) {
      return res.status(403).json(
        createResponse(403, '본인의 메시지만 삭제할 수 있습니다.')
      );
    }

    // Soft delete
    message.isDeleted = true;
    await message.save();

    // Socket.IO를 통해 실시간으로 삭제 알림
    const io = req.app.get('io');
    io.to(message.roomId.toString()).emit('message_deleted', {
      messageId: messageId,
      timestamp: new Date()
    });

    return res.status(200).json(
      createResponse(200, '메시지가 삭제되었습니다.')
    );

  } catch (error) {
    console.error('메시지 삭제 중 에러:', error);
    return res.status(500).json(
      createResponse(500, '서버 오류가 발생했습니다.')
    );
  }
});

module.exports = router;