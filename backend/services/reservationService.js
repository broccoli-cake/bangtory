// backend/services/reservationService.js
const ReservationCategory = require('../models/ReservationCategory');
const { ReservationError } = require('../utils/errors');

const reservationService = {
  /**
   * 예약 카테고리 목록 조회 (생성 순서대로 정렬)
   */
  async getCategories() {
    return await ReservationCategory.find()
      .sort({
        type: 1,        // 기본 카테고리 먼저 (default < custom)
        createdAt: 1    // 생성시간 순 (오래된 것부터)
      });
  },

  /**
   * 예약 카테고리 생성
   */
  async createCategory(categoryData, userId) {
    const category = new ReservationCategory({
      ...categoryData,
      createdBy: userId
    });
    return await category.save();
  },

  /**
   * 예약 카테고리 삭제
   */
  async deleteCategory(categoryId, userId) {
    const category = await ReservationCategory.findById(categoryId);
    
    if (!category) {
      throw new ReservationError('카테고리를 찾을 수 없습니다.', 404);
    }

    if (category.type === 'default') {
      throw new ReservationError('기본 카테고리는 삭제할 수 없습니다.', 400);
    }

    if (category.createdBy.toString() !== userId.toString()) {
      throw new ReservationError('카테고리 생성자만 삭제할 수 있습니다.', 403);
    }

    await category.deleteOne();
  },

  /**
   * 기본 예약 카테고리 초기화
   */
  async initializeDefaultCategories(userId) {
    await ReservationCategory.initializeDefaultCategories(userId);
  }
};

module.exports = reservationService;