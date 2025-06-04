// backend/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const { simpleAuth } = require('../middlewares/simpleAuth');
const User = require('../models/User');
const RoomMember = require('../models/RoomMember');
const roomService = require('../services/roomService');

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

// 사용자 기본 정보 조회 (이름만)
router.get('/me', simpleAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json(
        createResponse(404, '사용자를 찾을 수 없습니다.')
      );
    }

    res.json(createResponse(200, '사용자 정보 조회 성공', {
      data: {
        id: user._id,
        name: user.name
      }
    }));
  } catch (error) {
    console.error('사용자 조회 중 에러:', error);
    res.status(500).json(
      createResponse(500, '서버 오류가 발생했습니다.')
    );
  }
});

// 사용자 프로필 정보 조회 (방 멤버 정보 포함)
router.get('/me/profile', simpleAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json(
        createResponse(404, '사용자를 찾을 수 없습니다.')
      );
    }

    // 방 멤버 정보 조회
    const roomMember = await RoomMember.findOne({ userId: req.user._id });

    res.json(createResponse(200, '프로필 정보 조회 성공', {
      data: {
        id: user._id,
        name: user.name,
        nickname: roomMember?.nickname || null,
        profileImageUrl: roomMember?.profileImageUrl || null,
        hasRoom: !!roomMember
      }
    }));
  } catch (error) {
    console.error('프로필 조회 중 에러:', error);
    res.status(500).json(
      createResponse(500, '서버 오류가 발생했습니다.')
    );
  }
});

// 프로필 수정 (닉네임, 프로필 이미지)
router.patch('/me/profile', simpleAuth, async (req, res) => {
  try {
    const { nickname, profileImageUrl } = req.body;

    if (!nickname && !profileImageUrl) {
      return res.status(400).json(
        createResponse(400, '수정할 정보를 입력해주세요.')
      );
    }

    const updatedProfile = await roomService.updateMemberProfile(req.user._id, {
      nickname,
      profileImageUrl
    });

    res.json(createResponse(200, '프로필 수정 완료', {
      data: {
        nickname: updatedProfile.nickname,
        profileImageUrl: updatedProfile.profileImageUrl
      }
    }));
  } catch (error) {
    console.error('프로필 수정 중 에러:', error);
    res.status(400).json(
      createResponse(400, error.message)
    );
  }
});

// 사용자 생성 (이름만 입력) - 수정된 부분
router.post('/', async (req, res) => {
  try {
    console.log('사용자 생성 요청 받음:', req.body); // 디버깅용

    const { name } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json(
        createResponse(400, '이름을 입력해주세요.')
      );
    }

    const user = await User.create({
      name: name.trim(),
      provider: 'manual',
      providerId: Date.now().toString()
    });

    console.log('사용자 생성 완료:', user); // 디버깅용

    res.status(201).json(createResponse(201, '사용자 생성 성공', {
      data: {
        id: user._id,
        name: user.name
      }
    }));
  } catch (error) {
    console.error('사용자 생성 중 에러:', error);
    res.status(500).json(
      createResponse(500, '서버 오류가 발생했습니다.')
    );
  }
});

module.exports = router;