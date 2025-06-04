/**
 * 간단한 사용자 ID 확인 미들웨어
 * X-User-ID 헤더에서 사용자 ID를 가져옴
 */
const simpleAuth = (req, res, next) => {
  const userId = req.headers['x-user-id'];

  if (!userId) {
    return res.status(401).json({
      resultCode: '401',
      resultMessage: '사용자 ID가 필요합니다. X-User-ID 헤더를 설정해주세요.'
    });
  }

  // req.user 객체 설정 (기존 코드와 호환성 유지)
  req.user = {
    _id: userId,
    id: userId
  };

  next();
};

module.exports = {
  simpleAuth
};