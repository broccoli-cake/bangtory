const Room = require('../models/Room');

/**
 * 방장 권한 확인 미들웨어
 * @param {Object} req - Express request 객체
 * @param {Object} res - Express response 객체
 * @param {Function} next - Express next 함수
 */
const isRoomOwner = async (req, res, next) => {
  try {
    const roomId = req.params.roomId;
    const userId = req.user._id;

    const room = await Room.findOne({ _id: roomId, ownerId: userId });

    if (!room) {
      return res.status(403).json({
        resultCode: '403',
        resultMessage: '방장만 접근할 수 있습니다.'
      });
    }

    // 방 정보를 req에 추가하여 다음 미들웨어에서 사용할 수 있게 함
    req.room = room;
    next();
  } catch (error) {
    console.error('방장 권한 확인 중 에러:', error);
    return res.status(500).json({
      resultCode: '500',
      resultMessage: '서버 오류가 발생했습니다.'
    });
  }
};

module.exports = isRoomOwner;
