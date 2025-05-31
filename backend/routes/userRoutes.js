// backend/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const { simpleAuth } = require('../middlewares/simpleAuth');
const User = require('../models/User');

// 사용자 정보 조회
router.get('/me', simpleAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({
        resultCode: '404',
        resultMessage: '사용자를 찾을 수 없습니다.'
      });
    }

    res.json({
      resultCode: '200',
      resultMessage: '사용자 정보 조회 성공',
      data: {
        id: user._id,
        nickname: user.nickname,
        profileImageUrl: user.profileImageUrl,
        isProfileSet: user.isProfileSet
      }
    });
  } catch (error) {
    console.error('사용자 조회 중 에러:', error);
    res.status(500).json({
      resultCode: '500',
      resultMessage: '서버 오류가 발생했습니다.'
    });
  }
});

// 사용자 생성 (Flutter에서 호출)
router.post('/', async (req, res) => {
  try {
    const { nickname } = req.body;

    const user = await User.create({
      nickname: nickname || `사용자${Date.now()}`,
      provider: 'manual',
      providerId: Date.now().toString(),
      isProfileSet: false
    });

    res.status(201).json({
      resultCode: '201',
      resultMessage: '사용자 생성 성공',
      data: {
        id: user._id,
        nickname: user.nickname,
        profileImageUrl: user.profileImageUrl,
        isProfileSet: user.isProfileSet
      }
    });
  } catch (error) {
    console.error('사용자 생성 중 에러:', error);
    res.status(500).json({
      resultCode: '500',
      resultMessage: '서버 오류가 발생했습니다.'
    });
  }
});

module.exports = router;