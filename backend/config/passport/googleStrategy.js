// backend/config/passport/googleStrategy.js

const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const { googleConfig } = require('../oauthConfig');
const { findOrCreateUserByGoogle } = require('../../services/userService'); // 나중에 작성할 서비스 함수

// 구글 OAuth 전략 등록
passport.use(new GoogleStrategy(
  {
    clientID: googleConfig.clientID,
    clientSecret: googleConfig.clientSecret,
    callbackURL: googleConfig.callbackURL,
  },
  async (accessToken, refreshToken, profile, done) => {
    try {
      // 프로필 정보를 이용해 사용자 찾거나 새로 생성
      const user = await findOrCreateUserByGoogle(profile);
      return done(null, user);  // 인증 완료
    } catch (error) {
      console.error('Google 인증 에러:', error); // 에러 로깅 추가
      return done(error, null); // 에러 발생
    }
  }
));
