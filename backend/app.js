// app.js

require('dotenv').config();
const passport = require('./config/passport'); // OAuth 전략 등록된 파일 불러오기
const express = require('express'); // express 모듈 불러오기
const session = require('express-session'); // 세션 관리용 모듈
const mongoose = require('mongoose');
const cors = require('cors'); // CORS 추가
const path = require('path');

// 디버깅을 위한 로깅 미들웨어
const app = express(); // Express 애플리케이션 인스턴스 생성
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// 미들웨어 순서 중요!
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

// 세션 설정
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: true,
  cookie: { secure: false }
}));

// Passport 설정
app.use(passport.initialize());
app.use(passport.session());


// 구글 로그인 뷰
app.set('view engine', 'ejs');
const userRoutes = require('./routes/userRoutes');
app.use('/',userRoutes);

// views 디렉토리를 정적 파일로 제공
app.use('/views', express.static(path.join(__dirname, 'views')));


// 라우트 설정
app.get('/test', (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'test.html'));
});

// Auth 라우트를 먼저 설정
const authRoutes = require('./routes/authRoutes');
app.use('/auth', authRoutes);

// 기본 라우트
app.get('/', (req, res) => {
  console.log('루트 경로 요청 받음');
  if (req.isAuthenticated()) {
    res.json({
      message: '로그인 성공!',
      user: {
        id: req.user._id,
        username: req.user.username,
        displayName: req.user.displayName
      }
    });
  } else {
    res.send('서버가 정상적으로 실행중입니다. 로그인이 필요합니다.');
  }
});

// 404 처리
app.use((req, res) => {
  res.status(404).send('페이지를 찾을 수 없습니다.');
});

// 에러 핸들링 미들웨어
app.use((err, req, res, next) => {
  console.error('에러 발생:', err);
  res.status(500).json({
    error: err.message || '서버 에러가 발생했습니다.',
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// 서버 포트 설정
const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`서버가 시작되었습니다: http://localhost:${PORT}`);
  console.log('현재 환경:', process.env.NODE_ENV);
  console.log('서버 리스닝 중...');
});

server.on('error', (error) => {
  console.error('서버 에러 발생:', error);
});

// MongoDB 연결
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bangtory')
  .then(() => console.log('MongoDB 연결 성공'))
  .catch(err => console.error('MongoDB 연결 실패:', err));

