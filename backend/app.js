// app.js

const express = require('express'); // express 모듈 불러오기
const session = require('express-session'); // 세션 관리용 모듈
const passport = require('./config/passport'); // OAuth 전략 등록된 파일 불러오기

const app = express(); // Express 애플리케이션 인스턴스 생성

// 세션 설정
app.use(session({ 
  secret: process.env.SESSION_SECRET, // 세션 암호화에 사용할 비밀 키
  resave: false, // 세션에 수정사항 없으면 저장하지 않음
  saveUninitialized: true, // 초기화되지 않은 세션을 저장 (로그인 전 세션도 저장)
}));

// passport 초기화
app.use(passport.initialize());
app.use(passport.session()); // 로그인 상태를 세션으로 관리

// 라우터 연결 (나중에 authRoutes 연결)
const authRoutes = require('./routes/authRoutes');
app.use('/auth', authRoutes); // /auth로 시작하는 경로는 authRoutes가 처리

// 서버 포트 설정
const PORT = process.env.PORT || 3000;

// 서버 시작 및 포트 리스닝
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});