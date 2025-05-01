// services/userService.js

async function findOrCreateUserByKakao(profile) {
  console.log('[userService] 카카오 프로필 받음:', profile);
  // 임시로 그냥 프로필 그대로 반환
  return {
    id: profile.id,
    username: profile.username || profile.displayName || '카카오유저',
    provider: 'kakao',
  };
}

module.exports = {
  findOrCreateUserByKakao,
};
