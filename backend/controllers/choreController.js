const choreService = require('../services/choreService');
const { body, validationResult } = require('express-validator');

// 입력값 검증 미들웨어
const validateCategoryInput = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('카테고리 이름은 필수입니다.')
    .isLength({ min: 2, max: 20 })
    .withMessage('카테고리 이름은 2~20자 사이여야 합니다.'),
  body('icon')
    .notEmpty()
    .withMessage('아이콘은 필수입니다.'),
  body('color')
    .notEmpty()
    .withMessage('색상은 필수입니다.')
    .matches(/^#[0-9A-Fa-f]{6}$/)
    .withMessage('올바른 색상 코드가 아닙니다.')
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

const choreController = {
  /**
   * 카테고리 목록 조회
   */
  async getCategories(req, res) {
    try {
      const categories = await choreService.getCategories();
      
      return res.status(200).json(
        createResponse(200, '카테고리 목록 조회 성공', { categories })
      );
    } catch (error) {
      console.error('카테고리 목록 조회 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
    }
  },

  /**
   * 카테고리 생성
   */
  async createCategory(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json(
          createResponse(400, '잘못된 입력입니다.', { errors: errors.array() })
        );
      }

      const category = await choreService.createCategory(req.body, req.user._id);
      
      return res.status(201).json(
        createResponse(201, '카테고리 생성 완료', { category })
      );
    } catch (error) {
      console.error('카테고리 생성 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
    }
  },

  /**
   * 카테고리 삭제
   */
  async deleteCategory(req, res) {
    try {
      await choreService.deleteCategory(req.params.categoryId, req.user._id);
      
      return res.status(200).json(
        createResponse(200, '카테고리 삭제 완료')
      );
    } catch (error) {
      console.error('카테고리 삭제 중 에러:', error);
      return res.status(400).json(
        createResponse(400, error.message)
      );
    }
  }
};

module.exports = {
  choreController,
  validateCategoryInput
}; 