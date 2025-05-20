const express = require('express');
const router = express.Router();
const { profileController, validateProfileInput } = require('../controllers/profileController');
const { isAuthenticated } = require('../middlewares/auth');

// 프로필 최초 설정
router.post('/me', 
  isAuthenticated,
  validateProfileInput,
  profileController.setInitialProfile
);

// 프로필 수정
router.patch('/me',
  isAuthenticated,
  validateProfileInput,
  profileController.updateProfile
);

// 프로필 이미지 삭제
router.delete('/me/image',
  isAuthenticated,
  profileController.deleteProfileImage
);

module.exports = router; 