const adjectives = [
  '말랑한', '수줍은', '반짝이는', '싱그러운', '귀여운', '달콤한', '상큼한', '포근한'
];

const nouns = [
  '방울토마토', '당근', '귤', '고구마', '감자', '토마토', '오이', '파프리카',
  '브로콜리', '양상추', '블루베리', '바나나'
];

/**
 * 랜덤 닉네임 생성
 * @returns {string} 생성된 닉네임
 */
const generateRandomNickname = () => {
  const randomAdj = adjectives[Math.floor(Math.random() * adjectives.length)];
  const randomNoun = nouns[Math.floor(Math.random() * nouns.length)];
  const randomNum = String(Math.floor(Math.random() * 1000)).padStart(3, '0');
  
  return `${randomAdj}${randomNoun}${randomNum}`;
};

/**
 * 방 내에서 중복되지 않는 닉네임 생성
 * @param {string} roomId - 방 ID
 * @returns {Promise<string>} 생성된 닉네임
 */
const generateUniqueNicknameInRoom = async (roomId) => {
  const RoomMember = require('../models/RoomMember');
  let nickname;
  let isUnique = false;

  while (!isUnique) {
    nickname = generateRandomNickname();
    const existingMember = await RoomMember.findOne({
      roomId,
      nickname
    });
    if (!existingMember) {
      isUnique = true;
    }
  }

  return nickname;
};

module.exports = {
  generateRandomNickname,
  generateUniqueNicknameInRoom
}; 