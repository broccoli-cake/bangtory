// backend/app.js

require('dotenv').config();
require('./schedulers/reservationScheduler'); // 스케줄러 초기화
const express = require('express'); // express 모듈 불러오기
const mongoose = require('mongoose');
const cors = require('cors'); // CORS 추가
const path = require('path');
const userRoutes = require('./routes/userRoutes');
const roomRoutes = require('./routes/roomRoutes');
const profileRoutes = require('./routes/profileRoutes');
const choreRoutes = require('./routes/choreRoutes');
const choreScheduleRoutes = require('./routes/choreScheduleRoutes');
const choreService = require('./services/choreService');
const reservationRoutes = require('./routes/reservation'); // 예약 라우트 추가
const reservationService = require('./services/reservationService'); // 예약 서비스 추가

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

// views 디렉토리를 정적 파일로 제공
app.use('/views', express.static(path.join(__dirname, 'views')));

// 라우트 설정
app.get('/test', (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'test.html'));
});

// API 라우트 설정
app.use('/users', userRoutes);
app.use('/rooms', roomRoutes);
app.use('/profiles', profileRoutes);
app.use('/chores', choreRoutes);
app.use('/chores/schedules', choreScheduleRoutes);
app.use('/reservations', reservationRoutes); // 예약 라우트 추가

// 집안일 기본 카테고리 초기화 (기본 사용자 ID 사용)
const DEFAULT_USER_ID = '000000000000000000000000'; // 기본 사용자 ID
choreService.initializeDefaultCategories(DEFAULT_USER_ID)
  .then(() => console.log('집안일 기본 카테고리 초기화 완료'))
  .catch(err => console.error('집안일 기본 카테고리 초기화 실패:', err));

// 예약 기본 카테고리 초기화
reservationService.initializeDefaultCategories(DEFAULT_USER_ID)
  .then(() => console.log('예약 기본 카테고리 초기화 완료'))
  .catch(err => console.error('예약 기본 카테고리 초기화 실패:', err));

// 기본 라우트
app.get('/', (req, res) => {
  console.log('루트 경로 요청 받음');
  res.send('서버가 정상적으로 실행중입니다.');
});

// 404 처리
app.use((req, res) => {
  res.status(404).send('페이지를 찾을 수 없습니다.');
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

// 에러 핸들링 미들웨어
app.use((err, req, res, next) => {
  console.error('에러 발생:', err);
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || '서버 오류가 발생했습니다.'
  });
});

// 404 에러 핸들링
app.use('*', (req, res) => {
  console.log('404 - 요청된 URL:', req.originalUrl);
  res.status(404).json({
    success: false,
    message: '페이지를 찾을 수 없습니다.'
  });
});

module.exports = app;