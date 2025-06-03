// backend/app.js

require('dotenv').config();
require('./schedulers/reservationScheduler'); // 스케줄러 초기화
const express = require('express'); // express 모듈 불러오기
const http = require('http'); // HTTP 서버를 위한 모듈
const socketIo = require('socket.io'); // Socket.IO 추가
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
const chatRoutes = require('./routes/chatRoutes'); // 채팅 라우트 추가
const ChatMessage = require('./models/ChatMessage'); // 채팅 메시지 모델 추가
const RoomMember = require('./models/RoomMember'); // 룸 멤버 모델 추가

// Express 애플리케이션 인스턴스 생성
const app = express();

// HTTP 서버 생성 (Socket.IO를 위해 필요)
const server = http.createServer(app);

// Socket.IO 설정
const io = socketIo(server, {
  cors: {
    origin: process.env.FRONTEND_URL || ['http://localhost:3000', 'http://10.0.2.2:3000'],
    methods: ["GET", "POST"],
    credentials: true
  },
  transports: ['websocket', 'polling']
});

// 디버깅을 위한 로깅 미들웨어
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// 미들웨어 순서 중요!
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors({
  origin: process.env.FRONTEND_URL || ['http://localhost:3000', 'http://10.0.2.2:3000'],
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
app.use('/chat', chatRoutes); // 채팅 라우트 추가

// Socket.IO 연결 처리
const roomSockets = new Map(); // 방별 소켓 관리
const userSockets = new Map(); // 사용자별 소켓 관리

// 메시지 저장 함수
async function saveMessageToDatabase(messageData) {
  try {
    const chatMessage = new ChatMessage({
      roomId: messageData.roomId,
      userId: messageData.userId,
      message: messageData.text,
      messageType: 'text',
      timestamp: new Date(messageData.timestamp)
    });

    await chatMessage.save();
    console.log('메시지 데이터베이스 저장 완료:', messageData.id);
  } catch (error) {
    console.error('메시지 저장 오류:', error);
  }
}

io.on('connection', (socket) => {
  console.log('새로운 소켓 연결:', socket.id);

  // 사용자 인증 및 방 참여
  socket.on('join-room', async (data) => {
    try {
      const { roomId, userId, userNickname } = data;

      if (!roomId || !userId) {
        socket.emit('error', { message: '방 ID와 사용자 ID가 필요합니다.' });
        return;
      }

      // 사용자가 해당 방의 멤버인지 확인
      const roomMember = await RoomMember.findOne({
        roomId: roomId,
        userId: userId
      });

      if (!roomMember) {
        socket.emit('error', { message: '해당 방의 멤버가 아닙니다.' });
        return;
      }

      // 소켓을 방에 참여시키기
      socket.join(roomId);

      // 소켓 정보 저장
      socket.roomId = roomId;
      socket.userId = userId;
      socket.userNickname = userNickname || roomMember.nickname || '익명';

      // 방별 소켓 목록 관리
      if (!roomSockets.has(roomId)) {
        roomSockets.set(roomId, new Set());
      }
      roomSockets.get(roomId).add(socket.id);

      // 사용자별 소켓 관리
      userSockets.set(userId, socket.id);

      console.log(`사용자 ${socket.userNickname}(${userId})이 방 ${roomId}에 참여`);

      // 연결 성공 알림
      socket.emit('connected', {
        message: '채팅방에 연결되었습니다.',
        roomId,
        userId,
        timestamp: new Date().toISOString()
      });

      // 방의 다른 사용자들에게 입장 알림
      socket.to(roomId).emit('user-joined', {
        message: `${socket.userNickname}님이 입장했습니다.`,
        userId,
        userNickname: socket.userNickname,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('방 참여 오류:', error);
      socket.emit('error', { message: '방 참여에 실패했습니다.' });
    }
  });

  // 메시지 전송
  socket.on('message', async (data) => {
    try {
      const { text, roomId, userId } = data;
      const userNickname = socket.userNickname;

      // 기본 유효성 검사
      if (!text || !text.trim()) {
        socket.emit('error', { message: '메시지 내용이 비어있습니다.' });
        return;
      }

      if (!roomId || !userId) {
        socket.emit('error', { message: '방 ID와 사용자 ID가 필요합니다.' });
        return;
      }

      // 메시지 데이터 구성
      const messageData = {
        id: `msg_${Date.now()}_${socket.id}`,
        text: text.trim(),
        userId,
        userNickname: userNickname || '익명',
        timestamp: new Date().toISOString(),
        roomId
      };

      console.log(`방 ${roomId}에 메시지 전송:`, messageData);

      // 메시지를 데이터베이스에 저장
      await saveMessageToDatabase(messageData);

      // 방의 모든 사용자에게 메시지 전송 (본인 포함)
      io.to(roomId).emit('message', messageData);

    } catch (error) {
      console.error('메시지 전송 오류:', error);
      socket.emit('error', { message: '메시지 전송에 실패했습니다.' });
    }
  });

  // 타이핑 상태 전송
  socket.on('typing', (data) => {
    try {
      const { isTyping, roomId } = data;
      const userNickname = socket.userNickname;

      if (!roomId) {
        return;
      }

      // 타이핑 상태를 방의 다른 사용자들에게만 전송 (본인 제외)
      socket.to(roomId).emit('typing', {
        isTyping,
        userId: socket.userId,
        userNickname,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('타이핑 상태 전송 오류:', error);
    }
  });

  // 메시지 읽음 상태 처리
  socket.on('message-read', (data) => {
    try {
      const { messageId, roomId } = data;
      const userId = socket.userId;

      if (!messageId || !roomId) {
        return;
      }

      // 방의 다른 사용자들에게 읽음 상태 전송
      socket.to(roomId).emit('message-read', {
        messageId,
        userId,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('메시지 읽음 상태 처리 오류:', error);
    }
  });

  // 연결 해제 처리
  socket.on('disconnect', (reason) => {
    console.log(`소켓 연결 해제: ${socket.id}, 이유: ${reason}`);

    try {
      const roomId = socket.roomId;
      const userId = socket.userId;
      const userNickname = socket.userNickname;

      // 방별 소켓 목록에서 제거
      if (roomId && roomSockets.has(roomId)) {
        roomSockets.get(roomId).delete(socket.id);

        // 방에 아무도 없으면 방 정보 삭제
        if (roomSockets.get(roomId).size === 0) {
          roomSockets.delete(roomId);
          console.log(`방 ${roomId}이 비어있어 정보를 삭제했습니다.`);
        } else {
          // 방의 다른 사용자들에게 퇴장 알림
          socket.to(roomId).emit('user-left', {
            message: `${userNickname || '사용자'}님이 나갔습니다.`,
            userId,
            userNickname,
            timestamp: new Date().toISOString()
          });
        }
      }

      // 사용자별 소켓 목록에서 제거
      if (userId) {
        userSockets.delete(userId);
      }

    } catch (error) {
      console.error('연결 해제 처리 오류:', error);
    }
  });

  // 일반적인 오류 처리
  socket.on('error', (error) => {
    console.error('소켓 오류:', error);
    socket.emit('error', { message: '알 수 없는 오류가 발생했습니다.' });
  });
});

// Socket.IO 인스턴스를 app에 저장 (다른 라우트에서 사용할 수 있도록)
app.set('socketio', io);

// ❌ 기존 전역 카테고리 초기화 코드 제거
// const DEFAULT_USER_ID = '000000000000000000000000'; // 기본 사용자 ID
// choreService.initializeDefaultCategories(DEFAULT_USER_ID)
//   .then(() => console.log('집안일 기본 카테고리 초기화 완료'))
//   .catch(err => console.error('집안일 기본 카테고리 초기화 실패:', err));

// reservationService.initializeDefaultCategories(DEFAULT_USER_ID)
//   .then(() => console.log('예약 기본 카테고리 초기화 완료'))
//   .catch(err => console.error('예약 기본 카테고리 초기화 실패:', err));

// ✅ 방별 카테고리는 방 생성 시 자동으로 생성됨
console.log('방별 카테고리는 방 생성/참여 시 자동으로 관리됩니다.');

// 기본 라우트
app.get('/', (req, res) => {
  console.log('루트 경로 요청 받음');
  res.send('서버가 정상적으로 실행중입니다. Socket.IO도 활성화되어 있습니다.');
});

// Socket.IO 상태 확인 라우트
app.get('/socket-status', (req, res) => {
  const connectedSockets = io.engine.clientsCount;
  const activeRooms = roomSockets.size;
  const activeUsers = userSockets.size;

  res.json({
    success: true,
    data: {
      connectedSockets,
      activeRooms,
      activeUsers,
      roomDetails: Array.from(roomSockets.entries()).map(([roomId, sockets]) => ({
        roomId,
        socketCount: sockets.size
      }))
    }
  });
});

// 404 처리
app.use((req, res) => {
  res.status(404).send('페이지를 찾을 수 없습니다.');
});

// 에러 핸들링 미들웨어
app.use((err, req, res, next) => {
  console.error(err.stack);

  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: err.message,
      details: err.details
    });
  }

  if (err.name === 'ReservationError') {
    return res.status(err.statusCode || 400).json({
      success: false,
      message: err.message
    });
  }

  res.status(500).json({
    resultCode: '500',
    resultMessage: '서버 오류가 발생했습니다.'
  });
});

// 서버 포트 설정
const PORT = process.env.PORT || 3000;

// app.listen 대신 server.listen 사용 (Socket.IO 때문)
server.listen(PORT, '0.0.0.0', () => {
  console.log(`서버가 시작되었습니다: http://localhost:${PORT}`);
  console.log('Socket.IO 서버도 함께 실행 중...');
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

// Graceful shutdown 처리
process.on('SIGTERM', () => {
  console.log('SIGTERM 신호 받음. 서버를 안전하게 종료합니다...');
  server.close(() => {
    console.log('서버가 안전하게 종료되었습니다.');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT 신호 받음. 서버를 안전하게 종료합니다...');
  server.close(() => {
    console.log('서버가 안전하게 종료되었습니다.');
    process.exit(0);
  });
});

module.exports = { app, server, io };