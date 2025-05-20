/**
 * 인증된 사용자인지 확인하는 미들웨어
 */
const isAuthenticated = (req, res, next) => {
  if (req.session && req.session.passport && req.session.passport.user) {
    return next();
  }
  return res.status(401).json({
    resultCode: '401',
    resultMessage: '로그인이 필요합니다.'
  });
};

module.exports = {
  isAuthenticated
}; 