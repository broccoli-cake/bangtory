// backend/routes/authRoutes.js

const express = require('express');
const passport = require('passport');
const router = express.Router();

// 카카오 로그인 시작
router.get('/kakao', passport.authenticate('kakao'));

// 카카오 로그인 콜백
router.get('/kakao/callback', 
  passport.authenticate('kakao', { 
    failureRedirect: '/',
    successRedirect: '/'
  }),
  (req, res) => {
    console.log('카카오 로그인 성공:', req.user);
    res.redirect('/');
  }
);

// 로그아웃 라우트 추가
router.get('/logout', (req, res) => {
  req.logout((err) => {
    if (err) {
      console.error('로그아웃 에러:', err);
      return res.status(500).json({ error: '로그아웃 중 에러가 발생했습니다.' });
    }
    res.redirect('/');
  });
});

// 로그인 상태 확인
router.get('/status', (req, res) => {
  res.json({ 
    isAuthenticated: req.isAuthenticated(),
    user: req.user 
  });
});

module.exports = router;
