const passport = require('passport');
const User = require('../../models/User');

// 세션에 사용자 정보 저장
passport.serializeUser((user, done) => {
  done(null, user.id);
});

// 세션에서 사용자 정보 복원
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (error) {
    done(error, null);
  }
});

// 구글 전략 설정 파일 불러오기
require('./googleStrategy');

// 카카오 전략 설정 파일 불러오기
require('./kakaoStrategy');

// 설정된 passport 객체를 외부에 내보내기
module.exports = passport;
