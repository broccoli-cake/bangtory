// backend/routes/reservationRoutes.js
const express = require('express');
const router = express.Router();
const { isAuthenticated } = require('../middlewares/auth');
const reservationController = require('../controllers/reservationController');
const { validateCategoryInput } = require('../controllers/reservationController');

// [GET] /reservations - 예약 카테고리 목록 조회
router.get('/', isAuthenticated, reservationController.getCategories);

// [POST] /reservations - 예약 카테고리 생성
router.post('/', isAuthenticated, validateCategoryInput, reservationController.createCategory);

// [DELETE] /reservations/:categoryId - 예약 카테고리 삭제
router.delete('/:categoryId', isAuthenticated, reservationController.deleteCategory);

module.exports = router;