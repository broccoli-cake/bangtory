const ChoreCategory = require('../models/ChoreCategory');
const { ChoreError } = require('../utils/errors');

const choreService = {
  /**
   * 카테고리 목록 조회 (생성 순서대로 정렬)
   */
  async getCategories() {
    return await ChoreCategory.find()
      .sort({
        type: 1,        // 기본 카테고리 먼저 (default < custom)
        createdAt: 1    // 생성시간 순 (오래된 것부터)
      });
  },

  /**
   * 카테고리 생성
   */
  async createCategory(categoryData, userId) {
    const category = new ChoreCategory({
      ...categoryData,
      createdBy: userId
    });
    return await category.save();
  },

  /**
   * 카테고리 삭제
   */
  async deleteCategory(categoryId, userId) {
    const category = await ChoreCategory.findById(categoryId);
    
    if (!category) {
      throw new ChoreError('카테고리를 찾을 수 없습니다.', 404);
    }

    if (category.type === 'default') {
      throw new ChoreError('기본 카테고리는 삭제할 수 없습니다.', 400);
    }

    if (category.createdBy.toString() !== userId.toString()) {
      throw new ChoreError('카테고리 생성자만 삭제할 수 있습니다.', 403);
    }

    await category.deleteOne();
  },

  /**
   * 기본 카테고리 초기화
   */
  async initializeDefaultCategories(userId) {
    await ChoreCategory.initializeDefaultCategories(userId);
  }
};

module.exports = choreService; 