const ReservationCategory = require('../models/ReservationCategory');
const RoomMember = require('../models/RoomMember');
const { ReservationError } = require('../utils/errors');
const notificationService = require('./notificationService');

const reservationService = {
  /**
   * 방별 예약 카테고리 목록 조회 (생성 순서대로 정렬)
   */
  async getCategories(userId) {
    // 사용자가 속한 방 찾기
    const roomMember = await RoomMember.findOne({ userId });
    if (!roomMember) {
      throw new ReservationError('방에 참여한 후 이용할 수 있습니다.', 403);
    }

    return await ReservationCategory.find({ room: roomMember.roomId })
      .sort({
        type: 1,        // 기본 카테고리 먼저 (default < custom)
        createdAt: 1    // 생성시간 순 (오래된 것부터)
      });
  },

  /**
   * 예약 카테고리 생성
   */
  async createCategory(categoryData, userId) {
    // 사용자가 속한 방 찾기
    const roomMember = await RoomMember.findOne({ userId });
    if (!roomMember) {
      throw new ReservationError('방에 참여한 후 카테고리를 생성할 수 있습니다.', 403);
    }

    // 방 내에서 중복 이름 확인
    const existingCategory = await ReservationCategory.findOne({
      room: roomMember.roomId,
      name: categoryData.name
    });

    if (existingCategory) {
      throw new ReservationError('이미 존재하는 카테고리 이름입니다.', 400);
    }

    const category = new ReservationCategory({
      ...categoryData,
      createdBy: userId,
      room: roomMember.roomId
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

    // 사용자가 속한 방인지 확인
    const roomMember = await RoomMember.findOne({
      userId,
      roomId: category.room
    });

    if (!roomMember) {
      throw new ReservationError('해당 방의 멤버만 카테고리를 삭제할 수 있습니다.', 403);
    }

    if (category.createdBy.toString() !== userId.toString()) {
      throw new ReservationError('카테고리 생성자만 삭제할 수 있습니다.', 403);
    }

    await category.deleteOne();
  },

  /**
   * 방별 기본 예약 카테고리 초기화
   */
  async initializeDefaultCategories(userId, roomId) {
    await ReservationCategory.initializeDefaultCategories(userId, roomId);
  }
};

module.exports = reservationService;