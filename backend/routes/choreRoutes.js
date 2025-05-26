const express = require('express');
const router = express.Router();
const { isAuthenticated } = require('../middlewares/auth');
const choreController = require('../controllers/choreController');
const { validateCategoryInput } = require('../controllers/choreController');

// [GET] /chores - 카테고리 목록 조회
router.get('/', isAuthenticated, choreController.getCategories);

// [POST] /chores - 카테고리 생성
router.post('/', isAuthenticated, validateCategoryInput, choreController.createCategory);

// [DELETE] /chores/:categoryId - 카테고리 삭제
router.delete('/:categoryId', isAuthenticated, choreController.deleteCategory);

module.exports = router; 