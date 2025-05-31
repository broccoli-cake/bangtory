// backend/routes/profileRoutes.js
const express = require('express');
const router = express.Router();
const { profileController, validateProfileInput } = require('../controllers/profileController');
const { simpleAuth } = require('../middlewares/simpleAuth');

// [POST] /profiles/me - 프로필 최초 설정
router.post('/me',
  simpleAuth,
  validateProfileInput,
  profileController.setInitialProfile
);

// [PATCH] /profiles/me - 프로필 수정
router.patch('/me',
  simpleAuth,
  validateProfileInput,
  profileController.updateProfile
);

// [DELETE] /profiles/me/image - 프로필 이미지 삭제
router.delete('/me/image',
  simpleAuth,
  profileController.deleteProfileImage
);

module.exports = router;