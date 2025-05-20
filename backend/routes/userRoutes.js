const express = require('express');
const router = express.Router();
const { isAuthenticated } = require('../middlewares/auth');

// 사용자 정보 조회
router.get('/me', isAuthenticated, (req, res) => {
  res.json({
    resultCode: '200',
    resultMessage: '사용자 정보 조회 성공',
    data: {
      id: req.user._id,
      nickname: req.user.nickname,
      profileImageUrl: req.user.profileImageUrl
    }
  });
});

module.exports = router;
