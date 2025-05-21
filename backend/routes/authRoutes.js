// backend/routes/authRoutes.js

const express = require('express');
const passport = require('passport');
const router = express.Router();
const axios = require('axios');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// 카카오 로그인 시작
router.get('/kakao', passport.authenticate('kakao'));

// 카카오 로그인 콜백
router.get('/kakao/callback',
  passport.authenticate('kakao', {
    failureRedirect: '/',
    successRedirect: '/',
  }),
  (req, res) => {
    console.log('카카오 로그인 성공:', req.user);
    res.redirect('/');
  }
);

// 구글 로그인 시작
router.get('/google',
  passport.authenticate('google', {
    scope: ['profile'] // 이름(프로필)만 가져옴
  })
);

// 구글 로그인 콜백
router.get('/google/callback',
  passport.authenticate('google', {
    failureRedirect: '/',
    successRedirect: '/',
  }),
  (req, res) => {
    console.log('구글 로그인 성공:', req.user);
    res.redirect('/');
  }
);

// 네이버 로그인 시작
router.get('/naver', passport.authenticate('naver'));

// 네이버 로그인 콜백
router.get('/naver/callback',
  passport.authenticate('naver', {
    failureRedirect: '/',
    successRedirect: '/',
  }),
  (req, res) => {
    console.log('네이버 로그인 성공:', req.user);
    res.redirect('/');
  }
);

// 로그아웃
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

// 소셜 통합 로그인 (Flutter 등 모바일용)
router.post('/social', async (req, res) => {
  const { provider, accessToken } = req.body;
  let userInfo = null;

  try {
    if (provider === 'kakao') {
      const kakaoRes = await axios.get('https://kapi.kakao.com/v2/user/me', {
        headers: { Authorization: `Bearer ${accessToken}` }
      });
      const kakaoUser = kakaoRes.data;
      userInfo = {
        provider: 'kakao',
        providerId: kakaoUser.id,
        displayName: kakaoUser.kakao_account.profile.nickname,
        email: kakaoUser.kakao_account.email,
      };
    } else if (provider === 'naver') {
      const naverRes = await axios.get('https://openapi.naver.com/v1/nid/me', {
        headers: { Authorization: `Bearer ${accessToken}` }
      });
      const naverUser = naverRes.data.response;
      userInfo = {
        provider: 'naver',
        providerId: naverUser.id,
        displayName: naverUser.nickname || naverUser.name,
        email: naverUser.email,
      };
    } else if (provider === 'google') {
      const googleRes = await axios.get(`https://oauth2.googleapis.com/tokeninfo?id_token=${accessToken}`);
      const googleUser = googleRes.data;
      userInfo = {
        provider: 'google',
        providerId: googleUser.sub,
        displayName: googleUser.name,
        email: googleUser.email,
      };
    } else {
      return res.status(400).json({ message: '지원하지 않는 provider' });
    }

    // DB에 유저 저장/업데이트
    let user = await User.findOne({ provider: userInfo.provider, providerId: userInfo.providerId });
    if (!user) {
      user = await User.create(userInfo);
    } else {
      user.displayName = userInfo.displayName;
      user.email = userInfo.email;
      await user.save();
    }

    // JWT 발급
    const token = jwt.sign(
      { userId: user._id, nickname: user.displayName },
      process.env.JWT_SECRET,
      { expiresIn: '7d', issuer: 'bangtory' }
    );
    res.json({ jwt: token });
  } catch (err) {
    res.status(401).json({ message: `${provider} 인증 실패`, error: err.toString() });
  }
});

module.exports = router;
