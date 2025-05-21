const User = require('../models/User');
const RoomMember = require('../models/RoomMember');
const { generateRandomNickname, generateUniqueNicknameInRoom } = require('../utils/generateNickname');
const fs = require('fs').promises;
const path = require('path');

const profileService = {
  /**
   * 프로필 최초 설정
   */
  async setInitialProfile(userId, profileData) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('사용자를 찾을 수 없습니다.');
    }

    if (user.isProfileSet) {
      throw new Error('이미 프로필이 설정되어 있습니다.');
    }

    // 닉네임 설정 (공백만 있는 경우도 랜덤 닉네임 생성)
    if (profileData.nickname && profileData.nickname.trim()) {
      user.nickname = profileData.nickname;
    } else {
      user.nickname = generateRandomNickname();
    }

    // profileImageUrl이 없거나 빈 값이면 기본 이미지 경로로 설정
    if (profileData.profileImageUrl && profileData.profileImageUrl.trim()) {
      user.profileImageUrl = profileData.profileImageUrl;
    } else {
      user.profileImageUrl = '/images/default-profile.png';
    }

    user.isProfileSet = true;
    await user.save();

    return user;
  },

  /**
   * 프로필 수정
   */
  async updateProfile(userId, updateData) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('사용자를 찾을 수 없습니다.');
    }

    if (updateData.nickname) {
      user.nickname = updateData.nickname;
    }

    if (updateData.profileImageUrl) {
      user.profileImageUrl = updateData.profileImageUrl;
    }

    await user.save();
    return user;
  },

  /**
   * 프로필 이미지 삭제
   */
  async deleteProfileImage(userId) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('사용자를 찾을 수 없습니다.');
    }

    // 기본 이미지로 변경
    user.profileImageUrl = '/images/default-profile.png';
    await user.save();

    return user;
  },

  /**
   * 방 내 닉네임 설정
   */
  async setRoomNickname(userId, roomId, nickname) {
    const roomMember = await RoomMember.findOne({ userId, roomId });
    if (!roomMember) {
      throw new Error('해당 방의 멤버가 아닙니다.');
    }

    // 방 내 닉네임 중복 체크
    if (nickname) {
      const existingMember = await RoomMember.findOne({
        roomId,
        nickname,
        _id: { $ne: roomMember._id }
      });
      if (existingMember) {
        throw new Error('이미 사용 중인 닉네임입니다.');
      }
      roomMember.nickname = nickname;
    } else {
      // 랜덤 닉네임 생성
      roomMember.nickname = await generateUniqueNicknameInRoom(roomId);
    }

    await roomMember.save();
    return roomMember;
  }
};

module.exports = profileService; 