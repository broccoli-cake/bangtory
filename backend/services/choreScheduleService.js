const ChoreSchedule = require('../models/ChoreSchedule');
const Room = require('../models/Room');
const RoomMember = require('../models/RoomMember');
const notificationService = require('./notificationService');
const { ChoreError } = require('../utils/errors');

const choreScheduleService = {
  /**
   * 집안일 데이터에 RoomMember 정보 추가하는 헬퍼 함수
   */
  async addMemberInfoToSchedules(roomId, schedules) {
    return await Promise.all(
      schedules.map(async (schedule) => {
        const roomMember = await RoomMember.findOne({
          roomId: roomId,
          userId: schedule.assignedTo._id
        }).select('nickname profileImageUrl');

        return {
          ...schedule.toObject(),
          assignedTo: {
            _id: schedule.assignedTo._id,
            name: schedule.assignedTo.name,
            nickname: roomMember?.nickname || schedule.assignedTo.name,
            profileImageUrl: roomMember?.profileImageUrl || '/images/profile1.png'
          }
        };
      })
    );
  },

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

    console.log('집안일 일정 조회 쿼리:', query);

    const schedules = await ChoreSchedule.find(query)
      .populate('category', 'name icon type')
      .populate('assignedTo', 'name') // User 정보만 populate
      .sort({ date: 1 });

    console.log(`조회된 원본 일정 수: ${schedules.length}`);

    // RoomMember 정보를 추가하여 완전한 데이터 반환
    const schedulesWithMemberInfo = await this.addMemberInfoToSchedules(roomId, schedules);

    console.log('RoomMember 정보 추가 완료');
    schedulesWithMemberInfo.forEach((schedule, index) => {
      console.log(`일정 ${index + 1}:`, {
        id: schedule._id,
        category: schedule.category?.name,
        assignedTo: schedule.assignedTo?.nickname,
        date: schedule.date,
        isCompleted: schedule.isCompleted
      });
    });

    return schedulesWithMemberInfo;
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

    // 담당자가 방 멤버인지 확인
    const assignedMember = await RoomMember.findOne({
      roomId: room._id,
      userId: scheduleData.assignedTo // assignedTo는 이제 직접 userId
    });

    if (!assignedMember) {
      throw new ChoreError('담당자는 방 멤버여야 합니다.', 400);
    }

    console.log('담당자 확인 완료:', assignedMember.nickname);

    const schedule = new ChoreSchedule({
      room: scheduleData.room,
      category: scheduleData.category,
      assignedTo: scheduleData.assignedTo, // userId를 직접 저장
      date: scheduleData.date,
      createdBy: userId
    });

    const savedSchedule = await schedule.save();
    console.log('일정 저장 완료:', savedSchedule._id);

    // 저장된 일정을 populate하여 반환
    const populatedSchedule = await ChoreSchedule.findById(savedSchedule._id)
      .populate('category', 'name icon type')
      .populate('assignedTo', 'name');

    console.log('populate 완료:', populatedSchedule);

    // RoomMember 정보 추가
    const scheduleWithMemberInfo = await this.addMemberInfoToSchedules(room._id, [populatedSchedule]);
    const finalSchedule = scheduleWithMemberInfo[0];

    // 집안일 배정 알림 전송
    try {
      // 담당자에게 집안일 배정 알림 (본인이 등록한 경우가 아닐 때만)
      if (assignedMember.userId.toString() !== userId) {
        await notificationService.notifyUser({
          userId: scheduleData.assignedTo,
          fromUserId: userId,
          roomId: room._id,
          type: 'chore_assigned',
          title: '새로운 집안일 배정',
          message: `${finalSchedule.category.name} 담당으로 배정되었습니다.`,
          relatedData: {
            scheduleId: finalSchedule._id,
            categoryName: finalSchedule.category.name,
            date: finalSchedule.date
          }
        });
      }

      // 방의 다른 멤버들에게 일정 생성 알림
      const createdBy = await RoomMember.findOne({
        roomId: room._id,
        userId: userId
      });

      await notificationService.notifyRoomMembers({
        roomId: room._id,
        fromUserId: userId,
        type: 'chore_assigned',
        title: '집안일 일정 생성',
        message: `${createdBy?.nickname || '멤버'}님이 ${finalSchedule.category.name} 일정을 등록했습니다.`,
        relatedData: {
          scheduleId: finalSchedule._id,
          categoryName: finalSchedule.category.name,
          assignedToNickname: assignedMember?.nickname,
          assignedToUserId: scheduleData.assignedTo,
          date: finalSchedule.date
        },
        excludeUserIds: scheduleData.assignedTo !== userId ? [scheduleData.assignedTo] : [] // 담당자가 본인이 아니면 제외
      });
    } catch (notificationError) {
      console.error('집안일 배정 알림 전송 실패:', notificationError);
    }

    return finalSchedule;
  },

  /**
   * 일정 완료 처리
   */
  async completeSchedule(scheduleId, userId) {
    console.log('일정 완료 처리 요청:', scheduleId);

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

    const updatedSchedule = await schedule.save();
    console.log('완료 처리 저장 완료');

    // 완료된 일정을 populate하여 반환
    const populatedSchedule = await ChoreSchedule.findById(updatedSchedule._id)
      .populate('category', 'name icon type')
      .populate('assignedTo', 'name');

    // RoomMember 정보 추가
    const scheduleWithMemberInfo = await this.addMemberInfoToSchedules(schedule.room, [populatedSchedule]);
    const finalSchedule = scheduleWithMemberInfo[0];

    // 집안일 완료 알림 전송
    try {
      // 방의 모든 멤버들에게 완료 알림
      const completedBy = await RoomMember.findOne({
        roomId: schedule.room,
        userId: userId
      });

      await notificationService.notifyRoomMembers({
        roomId: schedule.room,
        fromUserId: userId,
        type: 'chore_completed',
        title: '집안일 완료',
        message: `${completedBy?.nickname || '멤버'}님이 ${finalSchedule.category.name}을(를) 완료했습니다.`,
        relatedData: {
          scheduleId: finalSchedule._id,
          categoryName: finalSchedule.category.name,
          completedAt: finalSchedule.completedAt,
          completedByNickname: completedBy?.nickname
        }
      });
    } catch (notificationError) {
      console.error('집안일 완료 알림 전송 실패:', notificationError);
    }

    return finalSchedule;
  },

  /**
   * 일정 완료 해제 (새로 추가)
   */
  async uncompleteSchedule(scheduleId, userId) {
    console.log('일정 완료 해제 요청:', scheduleId);

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
      throw new ChoreError('방 멤버만 완료 해제할 수 있습니다.', 403);
    }

    // 완료되지 않은 일정은 해제할 수 없음
    if (!schedule.isCompleted) {
      throw new ChoreError('완료되지 않은 일정은 해제할 수 없습니다.', 400);
    }

    schedule.isCompleted = false;
    schedule.completedAt = null;

    const updatedSchedule = await schedule.save();
    console.log('완료 해제 저장 완료');

    // 해제된 일정을 populate하여 반환
    const populatedSchedule = await ChoreSchedule.findById(updatedSchedule._id)
      .populate('category', 'name icon type')
      .populate('assignedTo', 'name');

    // RoomMember 정보 추가
    const scheduleWithMemberInfo = await this.addMemberInfoToSchedules(schedule.room, [populatedSchedule]);
    const finalSchedule = scheduleWithMemberInfo[0];

    // 집안일 완료 해제 알림 전송
    try {
      // 방의 모든 멤버들에게 완료 해제 알림
      const uncompletedBy = await RoomMember.findOne({
        roomId: schedule.room,
        userId: userId
      });

      await notificationService.notifyRoomMembers({
        roomId: schedule.room,
        fromUserId: userId,
        type: 'chore_assigned', // 다시 할 일이 되었으므로 assigned 타입 사용
        title: '집안일 완료 해제',
        message: `${uncompletedBy?.nickname || '멤버'}님이 ${finalSchedule.category.name} 완료를 해제했습니다.`,
        relatedData: {
          scheduleId: finalSchedule._id,
          categoryName: finalSchedule.category.name,
          uncompletedByNickname: uncompletedBy?.nickname,
          assignedToNickname: finalSchedule.assignedTo?.nickname
        }
      });
    } catch (notificationError) {
      console.error('집안일 완료 해제 알림 전송 실패:', notificationError);
    }

    return finalSchedule;
  },

  /**
   * 일정 삭제
   */
  async deleteSchedule(scheduleId, userId) {
    console.log('일정 삭제 요청:', scheduleId);

    const schedule = await ChoreSchedule.findById(scheduleId)
      .populate('category', 'name icon type')
      .populate('assignedTo', 'name');

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

    // 일정 삭제 알림 전송 (삭제 전에)
    try {
      const deletedBy = await RoomMember.findOne({
        roomId: schedule.room,
        userId: userId
      });

      const assignedMember = await RoomMember.findOne({
        roomId: schedule.room,
        userId: schedule.assignedTo._id
      });

      await notificationService.notifyRoomMembers({
        roomId: schedule.room,
        fromUserId: userId,
        type: 'chore_deleted',
        title: '집안일 일정 삭제',
        message: `${deletedBy?.nickname || '멤버'}님이 ${schedule.category.name} 일정을 삭제했습니다.`,
        relatedData: {
          categoryName: schedule.category.name,
          assignedToNickname: assignedMember?.nickname,
          date: schedule.date,
          deletedByNickname: deletedBy?.nickname
        }
      });
    } catch (notificationError) {
      console.error('일정 삭제 알림 전송 실패:', notificationError);
    }

    await schedule.deleteOne();
    console.log('일정 삭제 완료');
  }
};

module.exports = choreScheduleService;