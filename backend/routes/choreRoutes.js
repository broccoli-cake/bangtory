// backend/routes/choreRoutes.js
const express = require('express');
const router = express.Router();
const { simpleAuth } = require('../middlewares/simpleAuth');
const choreController = require('../controllers/choreController');
const { validateCategoryInput } = require('../controllers/choreController');

// [GET] /chores - 카테고리 목록 조회
router.get('/', simpleAuth, choreController.getCategories);

// [POST] /chores - 카테고리 생성
router.post('/', simpleAuth, validateCategoryInput, choreController.createCategory);

// [DELETE] /chores/:categoryId - 카테고리 삭제
router.delete('/:categoryId', simpleAuth, choreController.deleteCategory);

module.exports = router;