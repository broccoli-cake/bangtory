// backend/controllers/reservationController.js
const reservationService = require('../services/reservationService');
const { validationResult, body } = require('express-validator');

// 입력 검증 미들웨어
const validateCategoryInput = [
  body('name')
    .notEmpty()
    .withMessage('카테고리 이름은 필수입니다.')
    .isLength({ min: 1, max: 20 })
    .withMessage('카테고리 이름은 1-20자 사이여야 합니다.'),
  body('icon')
    .notEmpty()
    .withMessage('아이콘은 필수입니다.')
];

const reservationController = {
  /**
   * 예약 카테고리 목록 조회
   */
  async getCategories(req, res) {
    try {
      const categories = await reservationService.getCategories();
      
      res.json({
        resultCode: '200',
        resultMessage: '예약 카테고리 조회 성공',
        data: categories
      });
    } catch (error) {
      console.error('예약 카테고리 조회 에러:', error);
      res.status(500).json({
        resultCode: '500',
        resultMessage: '서버 에러가 발생했습니다.',
        error: error.message
      });
    }
  },

  /**
   * 예약 카테고리 생성
   */
  async createCategory(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          resultCode: '400',
          resultMessage: '입력값이 올바르지 않습니다.',
          errors: errors.array()
        });
      }

      const { name, icon } = req.body;
      const userId = req.user._id;

      const category = await reservationService.createCategory({ name, icon }, userId);

      res.status(201).json({
        resultCode: '201',
        resultMessage: '예약 카테고리 생성 성공',
        data: category
      });
    } catch (error) {
      console.error('예약 카테고리 생성 에러:', error);
      res.status(500).json({
        resultCode: '500',
        resultMessage: '서버 에러가 발생했습니다.',
        error: error.message
      });
    }
  },

  /**
   * 예약 카테고리 삭제
   */
  async deleteCategory(req, res) {
    try {
      const { categoryId } = req.params;
      const userId = req.user._id;

      await reservationService.deleteCategory(categoryId, userId);

      res.json({
        resultCode: '200',
        resultMessage: '예약 카테고리 삭제 성공'
      });
    } catch (error) {
      console.error('예약 카테고리 삭제 에러:', error);
      
      const statusCode = error.statusCode || 500;
      res.status(statusCode).json({
        resultCode: statusCode.toString(),
        resultMessage: error.message || '서버 에러가 발생했습니다.'
      });
    }
  }
};

module.exports = { reservationController, validateCategoryInput };