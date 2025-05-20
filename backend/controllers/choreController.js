const choreService = require('../services/choreService');
const { body, validationResult } = require('express-validator');
const { ChoreError } = require('../utils/errors');

// 입력값 검증 미들웨어
const validateCategoryInput = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('카테고리 이름은 비워둘 수 없습니다.')
    .isLength({ min: 2, max: 20 })
    .withMessage('카테고리 이름은 2~20자 사이여야 합니다.'),
  body('icon')
    .trim()
    .notEmpty()
    .withMessage('아이콘은 비워둘 수 없습니다.')
];

// 응답 생성 함수
const createResponse = (resultCode, resultMessage, data = null) => {
  return {
    resultCode,
    resultMessage,
    data
  };
};

const choreController = {
  /**
   * 카테고리 목록 조회
   */
  async getCategories(req, res) {
    try {
      const categories = await choreService.getCategories();
      res.json(createResponse('200', '카테고리 목록 조회 성공', categories));
    } catch (error) {
      console.error('카테고리 목록 조회 중 에러:', error);
      res.status(500).json(createResponse('500', '서버 에러가 발생했습니다.'));
    }
  },

  /**
   * 카테고리 생성
   */
  async createCategory(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json(createResponse('400', '잘못된 입력입니다.', errors.array()));
      }

      const category = await choreService.createCategory(req.body, req.user._id);
      res.status(201).json(createResponse('201', '카테고리 생성 성공', category));
    } catch (error) {
      console.error('카테고리 생성 중 에러:', error);
      res.status(500).json(createResponse('500', '서버 에러가 발생했습니다.'));
    }
  },

  /**
   * 카테고리 삭제
   */
  async deleteCategory(req, res) {
    try {
      await choreService.deleteCategory(req.params.categoryId, req.user._id);
      res.json(createResponse('200', '카테고리 삭제 성공'));
    } catch (error) {
      console.error('카테고리 삭제 중 에러:', error);
      if (error instanceof ChoreError) {
        res.status(error.statusCode).json(createResponse(error.statusCode.toString(), error.message));
      } else {
        res.status(500).json(createResponse('500', '서버 에러가 발생했습니다.'));
      }
    }
  }
};

module.exports = {
  ...choreController,
  validateCategoryInput
}; 