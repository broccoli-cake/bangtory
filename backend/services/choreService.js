const ChoreCategory = require('../models/ChoreCategory');
const RoomMember = require('../models/RoomMember');
const { ChoreError } = require('../utils/errors');
const notificationService = require('./notificationService');

const choreService = {
  /**
   * 방별 카테고리 목록 조회 (생성 순서대로 정렬)
   */
  async getCategories(userId) {
    // 사용자가 속한 방 찾기
    const roomMember = await RoomMember.findOne({ userId });
    if (!roomMember) {
      throw new ChoreError('방에 참여한 후 이용할 수 있습니다.', 403);
    }

    return await ChoreCategory.find({ room: roomMember.roomId })
      .sort({
        type: 1,        // 기본 카테고리 먼저 (default < custom)
        createdAt: 1    // 생성시간 순 (오래된 것부터)
      });
  },

  /**
   * 카테고리 생성
   */
  async createCategory(categoryData, userId) {
    // 사용자가 속한 방 찾기
    const roomMember = await RoomMember.findOne({ userId });
    if (!roomMember) {
      throw new ChoreError('방에 참여한 후 카테고리를 생성할 수 있습니다.', 403);
    }

    // 방 내에서 중복 이름 확인
    const existingCategory = await ChoreCategory.findOne({
      room: roomMember.roomId,
      name: categoryData.name
    });

    if (existingCategory) {
      throw new ChoreError('이미 존재하는 카테고리 이름입니다.', 400);
    }

    const category = new ChoreCategory({
      ...categoryData,
      createdBy: userId,
      room: roomMember.roomId
    });
    return await category.save();

    // createCategory 메서드에 알림 추가
    try {
      // 방의 모든 멤버들에게 카테고리 생성 알림
      const createdBy = await RoomMember.findOne({
        userId,
        roomId: roomMember.roomId
      });

      await notificationService.notifyRoomMembers({
        roomId: roomMember.roomId,
        fromUserId: userId,
        type: 'category_created',
        title: '새로운 집안일 카테고리',
        message: `${createdBy?.nickname || '멤버'}님이 '${category.name}' 카테고리를 추가했습니다.`,
        relatedData: {
          categoryId: category._id,
          categoryName: category.name,
          categoryType: 'chore'
        }
      });
    } catch (notificationError) {
      console.error('집안일 카테고리 생성 알림 전송 실패:', notificationError);
    }

    return category;
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

    // 사용자가 속한 방인지 확인
    const roomMember = await RoomMember.findOne({
      userId,
      roomId: category.room
    });

    if (!roomMember) {
      throw new ChoreError('해당 방의 멤버만 카테고리를 삭제할 수 있습니다.', 403);
    }

    if (category.createdBy.toString() !== userId.toString()) {
      throw new ChoreError('카테고리 생성자만 삭제할 수 있습니다.', 403);
    }

    await category.deleteOne();
  },

  /**
   * 방별 기본 카테고리 초기화
   */
  async initializeDefaultCategories(userId, roomId) {
    await ChoreCategory.initializeDefaultCategories(userId, roomId);
  }
};

module.exports = choreService;