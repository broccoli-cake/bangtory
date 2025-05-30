// backend/config/oauthConfig.js

// .env 파일에서 환경변수 로드
require('dotenv').config();

// Google, Kakao, Naver OAuth 설정을 외부로 내보냄
module.exports = {
  googleConfig: {
    clientID: process.env.GOOGLE_CLIENT_ID,  // 구글 OAuth 클라이언트 ID
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,  // 구글 OAuth 클라이언트 시크릿
    callbackURL: process.env.GOOGLE_CALLBACK_URL,  // 구글 OAuth 콜백 URL
  },
  kakaoConfig: {
    clientID: process.env.KAKAO_CLIENT_ID,  // 카카오 OAuth 클라이언트 ID
    clientSecret: process.env.KAKAO_CLIENT_SECRET,  // 카카오 OAuth 클라이언트 시크릿
    callbackURL: process.env.KAKAO_CALLBACK_URL,  // 카카오 OAuth 콜백 URL
  },
  naverConfig: {
    clientID: process.env.NAVER_CLIENT_ID,  // 네이버 OAuth 클라이언트 ID
    clientSecret: process.env.NAVER_CLIENT_SECRET,  // 네이버 OAuth 클라이언트 시크릿
    callbackURL: process.env.NAVER_CALLBACK_URL,  // 네이버 OAuth 콜백 URL
  },
};
