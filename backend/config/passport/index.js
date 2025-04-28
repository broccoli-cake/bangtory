const passport = require('passport');

// 구글 전략 설정 파일 불러오기
require('./googleStrategy');

// 카카오 전략 설정 파일 불러오기
require('./kakaoStrategy');

// 설정된 passport 객체를 외부에 내보내기
module.exports = passport;
