// backend/app.js

require('dotenv').config();
require('./schedulers/reservationScheduler'); // 스케줄러 초기화
const passport = require('./config/passport'); // OAuth 전략 등록된 파일 불러오기
const express = require('express'); // express 모듈 불러오기
const session = require('express-session'); // 세션 관리용 모듈
const mongoose = require('mongoose');
const cors = require('cors'); // CORS 추가
const path = require('path');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const roomRoutes = require('./routes/roomRoutes');
const profileRoutes = require('./routes/profileRoutes');
const choreRoutes = require('./routes/choreRoutes');
const choreScheduleRoutes = require('./routes/choreScheduleRoutes');
const choreService = require('./services/choreService');
const reservationRoutes = require('./routes/reservation'); // 예약 라우트 추가

// 디버깅을 위한 로깅 미들웨어
const app = express(); // Express 애플리케이션 인스턴스 생성
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// 미들웨어 순서 중요!
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));

// 세션 설정
app.use(session({
  secret: process.env.SESSION_SECRET || 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    maxAge: 24 * 60 * 60 * 1000 // 24시간
  }
}));

// Passport 설정 - 세션 설정 후에 초기화
app.use(passport.initialize());
app.use(passport.session());

// views 디렉토리를 정적 파일로 제공
app.use('/views', express.static(path.join(__dirname, 'views')));

// 라우트 설정
app.get('/test', (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'test.html'));
});

// API 라우트 설정
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/rooms', roomRoutes);
app.use('/profiles', profileRoutes);
app.use('/chores', choreRoutes);
app.use('/chores/schedules', choreScheduleRoutes);
app.use('/reservations', reservationRoutes); // 예약 라우트 추가

// 기본 카테고리 초기화
choreService.initializeDefaultCategories()
  .then(() => console.log('기본 카테고리 초기화 완료'))
  .catch(err => console.error('기본 카테고리 초기화 실패:', err));

// 기본 라우트
app.get('/', (req, res) => {
  console.log('루트 경로 요청 받음');
  if (req.isAuthenticated()) {
    res.json({
      message: '로그인 성공!',
      user: {
        id: req.user._id,
        nickname: req.user.nickname,
        profileImageUrl: req.user.profileImageUrl
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
  console.error(err.stack);

  if (error.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: error.message,
      details: error.details
    });
  }
  
  if (error.name === 'ReservationError') {
    return res.status(error.statusCode || 400).json({
      success: false,
      message: error.message
    });
  }

  res.status(500).json({
    resultCode: '500',
    resultMessage: '서버 오류가 발생했습니다.'
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
if (process.env.NODE_ENV !== 'test') {
  mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bangtory')
    .then(() => console.log('MongoDB 연결 성공'))
    .catch(err => console.error('MongoDB 연결 실패:', err));
}

module.exports = app;

