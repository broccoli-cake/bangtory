// backend/config/passport/naverStrategy.js

const passport = require('passport');
const NaverStrategy = require('passport-naver').Strategy;
const { naverConfig } = require('../oauthConfig');
const { findOrCreateUserByNaver } = require('../../services/userService'); // 서비스 함수

// 네이버 OAuth 전략 등록
passport.use(new NaverStrategy(
  {
    clientID: naverConfig.clientID,
    clientSecret: naverConfig.clientSecret,
    callbackURL: naverConfig.callbackURL
  },
  async (accessToken, refreshToken, profile, done) => {
    try {
      // 프로필 정보를 이용해 사용자 찾거나 새로 생성
      const user = await findOrCreateUserByNaver(profile);
      return done(null, user);  // 인증 완료
    } catch (error) {
      console.error('Naver 인증 에러:', error);
      return done(error, null); // 에러 발생
    }
  }
));