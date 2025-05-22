const express = require('express');
const router = express.Router();
const { profileController, validateProfileInput } = require('../controllers/profileController');
const { isAuthenticated } = require('../middlewares/auth');

// [POST] /profiles/me - 프로필 최초 설정
router.post('/me', 
  isAuthenticated,
  validateProfileInput,
  profileController.setInitialProfile
);

// [PATCH] /profiles/me - 프로필 수정
router.patch('/me',
  isAuthenticated,
  validateProfileInput,
  profileController.updateProfile
);

// [DELETE] /profiles/me/image - 프로필 이미지 삭제
router.delete('/me/image',
  isAuthenticated,
  profileController.deleteProfileImage
);

module.exports = router; 