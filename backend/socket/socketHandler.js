// backend/socket/socketHandler.js
const socketIo = require('socket.io');

function initializeSocket(server) {
  const io = socketIo(server, {
    cors: {
      origin: "*", // 프로덕션에서는 특정 도메인으로 제한
      methods: ["GET", "POST"]
    }
  });

  // 방별 소켓 관리
  const roomSockets = new Map();

  io.on('connection', (socket) => {
    console.log('새로운 소켓 연결:', socket.id);

    // 방 참여
    socket.on('join-room', (roomId) => {
      try {
        socket.join(roomId);

        // 방별 소켓 목록 관리
        if (!roomSockets.has(roomId)) {
          roomSockets.set(roomId, new Set());
        }
        roomSockets.get(roomId).add(socket.id);

        console.log(`소켓 ${socket.id}이 방 ${roomId}에 참여`);

        // 방의 다른 사용자들에게 알림
        socket.to(roomId).emit('user-joined', {
          message: '새로운 사용자가 입장했습니다.',
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        console.error('방 참여 오류:', error);
        socket.emit('error', { message: '방 참여에 실패했습니다.' });
      }
    });

    // 메시지 전송
    socket.on('message', (data) => {
      try {
        const { roomId, text, userId, userNickname } = data;

        if (!roomId || !text || !userId) {
          socket.emit('error', { message: '필수 정보가 누락되었습니다.' });
          return;
        }

        const messageData = {
          id: Date.now().toString(),
          text: text.trim(),
          userId,
          userNickname: userNickname || '익명',
          timestamp: new Date().toISOString(),
          roomId
        };

        // 방의 모든 사용자에게 메시지 전송 (본인 포함)
        io.to(roomId).emit('message', messageData);

        console.log(`방 ${roomId}에 메시지 전송:`, messageData);

        // TODO: 메시지를 데이터베이스에 저장
        // await saveMessageToDatabase(messageData);

      } catch (error) {
        console.error('메시지 전송 오류:', error);
        socket.emit('error', { message: '메시지 전송에 실패했습니다.' });
      }
    });

    // 타이핑 상태 전송
    socket.on('typing', (data) => {
      try {
        const { roomId, isTyping, userNickname } = data;
        socket.to(roomId).emit('typing', {
          isTyping,
          userNickname,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        console.error('타이핑 상태 전송 오류:', error);
      }
    });

    // 연결 해제
    socket.on('disconnect', () => {
      console.log('소켓 연결 해제:', socket.id);

      // 모든 방에서 해당 소켓 제거
      for (const [roomId, sockets] of roomSockets.entries()) {
        if (sockets.has(socket.id)) {
          sockets.delete(socket.id);

          // 방에 아무도 없으면 방 정보 삭제
          if (sockets.size === 0) {
            roomSockets.delete(roomId);
          } else {
            // 방의 다른 사용자들에게 알림
            socket.to(roomId).emit('user-left', {
              message: '사용자가 나갔습니다.',
              timestamp: new Date().toISOString()
            });
          }
          break;
        }
      }
    });

    // 오류 처리
    socket.on('error', (error) => {
      console.error('소켓 오류:', error);
    });
  });

  return io;
}

module.exports = { initializeSocket };
