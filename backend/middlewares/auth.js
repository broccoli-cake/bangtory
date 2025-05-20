/**
 * 인증된 사용자인지 확인하는 미들웨어
 */
const isAuthenticated = (req, res, next) => {
  console.log('인증 체크:', {
    isAuthenticated: req.isAuthenticated(),
    session: req.session,
    user: req.user,
    cookies: req.cookies
  });
  
  if (req.isAuthenticated()) {
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