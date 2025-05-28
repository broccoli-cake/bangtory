// backend/controllers/reservationController.js
const reservationService = require('../services/reservationService');
const { successResponse } = require('../utils/responses');

const reservationController = {
  /**
   * 예약 카테고리 목록 조회
   */
  async getCategories(req, res, next) {
    try {
      const categories = await reservationService.getCategories();
      res.json(successResponse(categories, '카테고리 목록을 조회했습니다.'));
    } catch (error) {
      next(error);
    }
  },

  /**
   * 예약 카테고리 생성
   */
  async createCategory(req, res, next) {
    try {
      const { name, icon, requiresApproval, isVisitor } = req.body;
      const userId = req.user.id;

      // 카테고리 데이터 구성 - isVisitor는 명시적으로 true일 때만 포함
      const categoryData = {
        name,
        icon,
        requiresApproval: requiresApproval || false
      };

      // isVisitor가 명시적으로 true인 경우에만 추가 (방문객 카테고리인 경우)
      if (isVisitor === true) {
        categoryData.isVisitor = true;
      }
      // isVisitor가 false이거나 undefined인 경우 필드 자체를 포함하지 않음

      const category = await reservationService.createCategory(categoryData, userId);

      res.status(201).json(successResponse(category, '카테고리가 생성되었습니다.'));
    } catch (error) {
      next(error);
    }
  },


  /**
   * 예약 카테고리 삭제
   */
  async deleteCategory(req, res, next) {
    try {
      const { categoryId } = req.params;
      const userId = req.user.id;

      await reservationService.deleteCategory(categoryId, userId);
      res.json(successResponse(null, '카테고리가 삭제되었습니다.'));
    } catch (error) {
      next(error);
    }
  }
};

module.exports = reservationController;