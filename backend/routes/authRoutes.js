// backend/routes/authRoutes.js

const express = require('express');
const passport = require('passport');
const router = express.Router();

// 카카오 로그인 시작
router.get('/kakao', 
  passport.authenticate('kakao', {
    session: true,  // 세션 사용
    failureMessage: true  // 실패 메시지 전달
  })
);

// 카카오 콜백
router.get('/kakao/callback',
  passport.authenticate('kakao', {
    successRedirect: '/',
    failureRedirect: '/auth/kakao/fail',
    failureMessage: true
  })
);

// 실패 처리 라우트
router.get('/kakao/fail', (req, res) => {
  console.error('카카오 로그인 실패:', req.session.messages);  // 실패 메시지 로깅
  res.status(401).json({
    error: '카카오 로그인 실패',
    message: req.session.messages
  });
});

module.exports = router;
