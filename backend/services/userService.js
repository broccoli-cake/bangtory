// services/userService.js

const User = require('../models/User');

async function findOrCreateUserByKakao(profile) {
  try {
    // 카카오 ID로 사용자 찾기
    let user = await User.findOne({ kakaoId: profile.id.toString() });
    
    if (!user) {
      // 사용자가 없으면 새로 생성
      user = await User.create({
        kakaoId: profile.id.toString(),
        username: profile.username || `user_${profile.id}`,
        displayName: profile.displayName || profile.username || `user_${profile.id}`,
        provider: 'kakao'
      });
    }
    
    return user;
  } catch (error) {
    console.error('사용자 생성/조회 에러:', error);
    throw error;
  }
}

module.exports = {
  findOrCreateUserByKakao
};
