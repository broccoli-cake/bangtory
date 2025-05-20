const profileService = require('../services/profileService');
const { body, validationResult } = require('express-validator');

// 입력값 검증 미들웨어
const validateProfileInput = [
  body('nickname')
    .optional()
    .custom((value) => {
      // nickname이 없거나 공백만 있는 경우는 통과
      if (!value || !value.trim()) {
        return true;
      }
      // nickname이 있는 경우에만 추가 검증
      if (value.length < 2 || value.length > 20) {
        throw new Error('닉네임은 2~20자 사이여야 합니다.');
      }
      if (!/^[가-힣a-zA-Z0-9]+$/.test(value)) {
        throw new Error('닉네임은 한글, 영문, 숫자만 사용 가능합니다.');
      }
      return true;
    }),
  body('profileImageUrl')
    .optional()
    .matches(/^(\/images\/[a-zA-Z0-9-_.]+\.(png|jpg|jpeg|gif))$/)
    .withMessage('올바른 이미지 경로가 아닙니다.')
];

// 응답 포맷 생성 함수
const createResponse = (status, message, data = null) => {
  const response = {
    resultCode: status.toString(),
    resultMessage: message
  };
  if (data) {
    Object.assign(response, data);
  }
  return response;
};

const profileController = {
  /**
   * 프로필 최초 설정
   */
  async setInitialProfile(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json(
          createResponse(400, '잘못된 입력입니다.', { errors: errors.array() })
        );
      }

      const user = await profileService.setInitialProfile(req.user._id, req.body);
      
      return res.status(201).json(
        createResponse(201, '프로필 설정 완료', {
          profile: {
            nickname: user.nickname,
            profileImageUrl: user.profileImageUrl
          }
        })
      );
    } catch (error) {
      console.error('프로필 설정 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
    }
  },

  /**
   * 프로필 수정
   */
  async updateProfile(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json(
          createResponse(400, '잘못된 입력입니다.', { errors: errors.array() })
        );
      }

      const user = await profileService.updateProfile(req.user._id, req.body);
      
      return res.status(200).json(
        createResponse(200, '프로필 수정 완료', {
          profile: {
            nickname: user.nickname,
            profileImageUrl: user.profileImageUrl
          }
        })
      );
    } catch (error) {
      console.error('프로필 수정 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
    }
  },

  /**
   * 프로필 이미지 삭제
   */
  async deleteProfileImage(req, res) {
    try {
      const user = await profileService.deleteProfileImage(req.user._id);
      
      return res.status(200).json(
        createResponse(200, '프로필 이미지 삭제 완료', {
          profile: {
            nickname: user.nickname,
            profileImageUrl: user.profileImageUrl
          }
        })
      );
    } catch (error) {
      console.error('프로필 이미지 삭제 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
    }
  }
};

module.exports = {
  profileController,
  validateProfileInput
}; 