// services/userService.js

const User = require('../models/User');
const { generateRandomNickname } = require('../utils/generateNickname');

async function findOrCreateUser(profile, provider) {
  try {
    const providerId = profile.id.toString();
    console.log('카카오 프로필 정보:', profile);  // 프로필 정보 로깅
    
    // 카카오 프로필에서 닉네임 가져오기
    let nickname;
    if (provider === 'kakao') {
      nickname = profile._json?.properties?.nickname || profile.displayName || generateRandomNickname();
    } else {
      nickname = profile.displayName || generateRandomNickname();
    }
    
    // 통합된 쿼리로 사용자 찾기
    let user = await User.findOne({ provider, providerId });

    if (!user) {
      // 새 사용자 생성
      user = await User.create({
        provider,
        providerId,
        nickname,
        profileImageUrl: profile._json?.properties?.profile_image || '/images/default-profile.png'
      });
      console.log('새 사용자 생성됨:', user);  // 생성된 사용자 정보 로깅
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

async function findOrCreateUserByNaver(profile) {
  return findOrCreateUser(profile, 'naver');
}

module.exports = {
  findOrCreateUserByKakao,
  findOrCreateUserByGoogle,
  findOrCreateUserByNaver,
};
