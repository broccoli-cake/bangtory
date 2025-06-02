const ChoreSchedule = require('../models/ChoreSchedule');
const Room = require('../models/Room');
const RoomMember = require('../models/RoomMember');
const { ChoreError } = require('../utils/errors');

const choreScheduleService = {
  /**
   * 특정 방의 일정 목록 조회
   */
  async getSchedules(roomId, startDate, endDate, categoryId) {
    const query = {
      room: roomId,
      date: {
        $gte: startDate,
        $lte: endDate
      }
    };

    if (categoryId) {
      query.category = categoryId;
    }

    const schedules = await ChoreSchedule.find(query)
      .populate('category', 'name icon type')
      .populate({
        path: 'assignedTo',
        select: 'nickname profileImageUrl userId',
        populate: {
          path: 'userId',
          select: 'name'
        }
      })
      .sort({ date: 1 });

    return schedules;
  },

  /**
   * 일정 생성
   */
  async createSchedule(scheduleData, userId) {
    console.log('일정 생성 요청 데이터:', scheduleData);
    console.log('사용자 ID:', userId);

    // 방 멤버인지 확인
    const room = await Room.findById(scheduleData.room);
    if (!room) {
      throw new ChoreError('방을 찾을 수 없습니다.', 404);
    }

    const roomMember = await RoomMember.findOne({
      roomId: room._id,
      userId: userId
    });

    if (!roomMember) {
      throw new ChoreError('방 멤버만 일정을 생성할 수 있습니다.', 403);
    }

    // 담당자 RoomMember 찾기 - 수정된 부분
    let assignedMember;

    // assignedTo가 RoomMember의 _id인지 userId인지 확인
    assignedMember = await RoomMember.findOne({
      $and: [
        { roomId: room._id },
        {
          $or: [
            { _id: scheduleData.assignedTo },
            { userId: scheduleData.assignedTo }
          ]
        }
      ]
    });

    if (!assignedMember) {
      throw new ChoreError('담당자는 방 멤버여야 합니다.', 400);
    }

    const schedule = new ChoreSchedule({
      room: scheduleData.room,
      category: scheduleData.category,
      assignedTo: assignedMember._id, // RoomMember의 _id 사용
      date: scheduleData.date,
      createdBy: userId
    });

    return await schedule.save();
  },

  /**
   * 일정 완료 처리
   */
  async completeSchedule(scheduleId, userId) {
    const schedule = await ChoreSchedule.findById(scheduleId);

    if (!schedule) {
      throw new ChoreError('일정을 찾을 수 없습니다.', 404);
    }

    // 방 멤버인지 확인
    const roomMember = await RoomMember.findOne({
      roomId: schedule.room,
      userId: userId
    });

    if (!roomMember) {
      throw new ChoreError('방 멤버만 완료 처리할 수 있습니다.', 403);
    }

    schedule.isCompleted = true;
    schedule.completedAt = new Date();
    return await schedule.save();
  },

  /**
   * 일정 삭제
   */
  async deleteSchedule(scheduleId, userId) {
    const schedule = await ChoreSchedule.findById(scheduleId);

    if (!schedule) {
      throw new ChoreError('일정을 찾을 수 없습니다.', 404);
    }

    // 방 멤버인지 확인
    const roomMember = await RoomMember.findOne({
      roomId: schedule.room,
      userId: userId
    });

    if (!roomMember) {
      throw new ChoreError('방 멤버만 삭제할 수 있습니다.', 403);
    }

    await schedule.deleteOne();
  }
};

module.exports = choreScheduleService;