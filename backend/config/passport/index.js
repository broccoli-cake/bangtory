// backend/config/passport/index.js

const passport = require('passport');
const User = require('../../models/User');

// 세션에 사용자 정보 저장
passport.serializeUser((user, done) => {
  console.log('사용자 직렬화:', user);
  done(null, user.id);
});

// 세션에서 사용자 정보 복원
passport.deserializeUser(async (id, done) => {
  try {
    console.log('사용자 역직렬화:', id);
    const user = await User.findById(id);
    done(null, user);
  } catch (error) {
    console.error('사용자 역직렬화 에러:', error);
    done(error, null);
  }
});

// 카카오 전략 설정 파일 불러오기
require('./kakaoStrategy');

// 구글 전략 설정 파일 불러오기
require('./googleStrategy');

// 네이버 전략 설정 파일 불러오기
require('./naverStrategy');

// 설정된 passport 객체를 외부에 내보내기
module.exports = passport;
