const passport = require('passport');
const KakaoStrategy = require('passport-kakao').Strategy;
const { kakaoConfig } = require('../oauthConfig');
const { findOrCreateUserByKakao } = require('../../services/userService'); // 나중에 작성할 서비스 함수

// 카카오 OAuth 전략 등록
passport.use(new KakaoStrategy(
  {
    clientID: kakaoConfig.clientID,        // 카카오 REST API 키
    clientSecret: kakaoConfig.clientSecret, // 카카오 Client Secret (사용 안 하면 무시 가능)
    callbackURL: kakaoConfig.callbackURL,  // 로그인 성공 후 돌아올 콜백 URL
  },
  async (accessToken, refreshToken, profile, done) => {
    try {
      // 프로필 정보를 이용해 사용자 찾거나 새로 생성
      const user = await findOrCreateUserByKakao(profile);
      return done(null, user);  // 인증 완료
    } catch (error) {
      return done(error, null); // 에러 발생
    }
  }
));
