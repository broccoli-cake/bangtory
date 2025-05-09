// services/userService.js

const User = require('../models/User');

async function findOrCreateUser(profile, provider) {
  try {
    const providerId = profile.id.toString();
    const username = `${provider}_${providerId}`;
    const displayName = profile.displayName || `New ${provider} User`;
    
    // 통합된 쿼리로 사용자 찾기
    let user = await User.findOne({ provider, providerId });

    if (!user) {
      // 새 사용자 생성
      user = await User.create({
        provider,
        providerId,
        username,
        displayName,
      });
    }

    return user;
  } catch (error) {
    console.error(`${provider} 사용자 생성/조회 에러:`, error);
    throw error;
  }
}

// 각 provider별 함수는 단순히 findOrCreateUser를 호출
async function findOrCreateUserByKakao(profile) {
  return findOrCreateUser(profile, 'kakao');
}

async function findOrCreateUserByGoogle(profile) {
  return findOrCreateUser(profile, 'google');
}

module.exports = {
  findOrCreateUserByKakao,
  findOrCreateUserByGoogle,
};
