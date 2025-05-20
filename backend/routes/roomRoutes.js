const express = require('express');
const router = express.Router();
const roomController = require('../controllers/roomController');
const isRoomOwner = require('../middlewares/isRoomOwner');

// 로그인된 사용자만 방 생성 가능
// 미들웨어 예: req.user 확인 (세션 or JWT 기반일 경우 필요)
const isAuthenticated = (req, res, next) => {
  if (req.isAuthenticated?.() && req.user) {
    return next();
  }
  return res.status(401).json({
    resultCode: '401',
    resultMessage: '로그인이 필요합니다.'
  });
};

// [POST] /rooms - 방 생성
router.post('/', isAuthenticated, roomController.createRoom);

// [POST] /rooms/invite - 방 초대코드 생성
router.post('/invite', isAuthenticated, roomController.generateInviteCode);

// [POST] /rooms/join - 초대 코드로 방 참여
router.post('/join', isAuthenticated, roomController.joinRoom);

// [GET] /rooms/me - 현재 참여 중인 방 조회
router.get('/me', isAuthenticated, roomController.getMyRoom);

// [GET] /rooms/:roomId - 방 상세 정보 조회
router.get('/:roomId', isAuthenticated, roomController.getRoomDetail);

// [DELETE] /rooms/:roomId - 방 삭제 (방장만)
router.delete('/:roomId', isAuthenticated, isRoomOwner, roomController.deleteRoom);

// [DELETE] /rooms/me - 방 나가기
router.delete('/me', isAuthenticated, roomController.leaveRoom);

// [PATCH] /rooms/:roomId - 방 정보 수정 (방장만)
router.patch('/:roomId', isAuthenticated, isRoomOwner, roomController.updateRoom);

module.exports = router;
