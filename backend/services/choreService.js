const Chore = require('../models/Chore');

const choreService = {
  /**
   * 카테고리 목록 조회
   */
  async getCategories() {
    const categories = await Chore.find()
      .sort({ type: 1, createdAt: 1 });
    return categories;
  },

  /**
   * 카테고리 생성
   */
  async createCategory(categoryData, userId) {
    const category = new Chore({
      ...categoryData,
      createdBy: userId
    });
    return await category.save();
  },

  /**
   * 카테고리 삭제
   */
  async deleteCategory(categoryId, userId) {
    const category = await Chore.findById(categoryId);
    
    if (!category) {
      throw new Error('카테고리를 찾을 수 없습니다.');
    }

    if (category.type === 'default') {
      throw new Error('기본 카테고리는 삭제할 수 없습니다.');
    }

    if (category.createdBy.toString() !== userId.toString()) {
      throw new Error('카테고리 생성자만 삭제할 수 있습니다.');
    }

    await category.deleteOne();
  },

  /**
   * 기본 카테고리 초기화
   */
  async initializeDefaultCategories() {
    await Chore.initializeDefaultCategories();
  }
};

module.exports = choreService; 