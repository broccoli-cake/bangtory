const express = require('express');
const router = express.Router();
const { choreController, validateCategoryInput } = require('../controllers/choreController');
const { isAuthenticated } = require('../middlewares/auth');

// 카테고리 목록 조회
router.get('/', isAuthenticated, choreController.getCategories);

// 카테고리 생성
router.post('/', 
  isAuthenticated,
  validateCategoryInput,
  choreController.createCategory
);

// 카테고리 삭제
router.delete('/:categoryId',
  isAuthenticated,
  choreController.deleteCategory
);

module.exports = router; 