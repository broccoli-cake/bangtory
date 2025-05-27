// backend/services/reservationScheduleService.js
const ReservationSchedule = require('../models/ReservationSchedule');
const ReservationCategory = require('../models/ReservationCategory');
const ReservationApproval = require('../models/ReservationApproval');
const Room = require('../models/Room');
const RoomMember = require('../models/RoomMember');
const { ReservationError } = require('../utils/errors');

const reservationScheduleService = {
  /**
   * 특정 방의 주간 예약 일정 조회 (승인된 예약만)
   */
  async getWeeklySchedules(roomId, weekStartDate, categoryId) {
    const query = {
      room: roomId,
      weekStartDate: new Date(weekStartDate),
      status: 'approved' // 승인된 예약만 조회
    };
    
    if (categoryId) {
      query.category = categoryId;
    }

    const schedules = await ReservationSchedule.find(query)
      .populate('category', 'name icon')
      .populate('reservedBy', 'nickname profileImageUrl')
      .sort({ dayOfWeek: 1, startHour: 1 });

    return schedules;
  },

  /**
   * 현재 주의 예약 일정 조회 (승인된 예약만)
   */
  async getCurrentWeekSchedules(roomId, categoryId) {
    const today = new Date();
    const weekStartDate = ReservationSchedule.getWeekStartDate(today);
    
    return await this.getWeeklySchedules(roomId, weekStartDate, categoryId);
  },

  /**
   * 승인 대기 중인 예약 목록 조회
   */
  async getPendingReservations(roomId, userId) {
    const pendingReservations = await ReservationSchedule.find({
      room: roomId,
      status: 'pending'
    })
    .populate('category', 'name icon')
    .populate('reservedBy', 'nickname profileImageUrl')
    .populate({
      path: 'room',
      select: 'name'
    })
    .sort({ createdAt: -1 });

    // 각 예약의 승인 정보도 함께 조회
    const reservationsWithApproval = await Promise.all(
      pendingReservations.map(async (reservation) => {
        const approval = await ReservationApproval.findOne({ 
          reservation: reservation._id 
        }).populate('approvedBy.user', 'nickname');
        
        const hasUserApproved = approval?.approvedBy.some(
          app => app.user._id.toString() === userId.toString()
        ) || false;

        return {
          ...reservation.toObject(),
          approval: approval || null,
          hasUserApproved
        };
      })
    );

    return reservationsWithApproval;
  },

  /**
   * 예약 일정 생성
   */
  async createSchedule(scheduleData, userId) {
    console.log('예약 생성 요청 데이터:', scheduleData);
    console.log('사용자 ID:', userId);

    // 방 멤버인지 확인
    const room = await Room.findById(scheduleData.room);
    if (!room) {
      throw new ReservationError('방을 찾을 수 없습니다.', 404);
    }

    const roomMember = await RoomMember.findOne({
      roomId: room._id,
      userId: userId
    });

    if (!roomMember) {
      throw new ReservationError('방 멤버만 예약을 생성할 수 있습니다.', 403);
    }

    // 카테고리 정보 조회
    const category = await ReservationCategory.findById(scheduleData.category);
    if (!category) {
      throw new ReservationError('카테고리를 찾을 수 없습니다.', 404);
    }

    // 주의 시작 날짜 계산
    const weekStartDate = ReservationSchedule.getWeekStartDate(new Date());

    // 시간 겹침 확인 (승인된 예약만 체크)
    const conflictingReservation = await ReservationSchedule.findOne({
      room: scheduleData.room,
      category: scheduleData.category,
      dayOfWeek: scheduleData.dayOfWeek,
      weekStartDate: weekStartDate,
      status: 'approved',
      $or: [
        {
          startHour: { $lt: scheduleData.endHour },
          endHour: { $gt: scheduleData.startHour }
        }
      ]
    });

    if (conflictingReservation) {
      throw new ReservationError('해당 시간에 이미 승인된 예약이 있습니다.', 409);
    }

    // 예약 상태 결정
    const status = category.requiresApproval ? 'pending' : 'approved';

    const schedule = new ReservationSchedule({
      room: scheduleData.room,
      category: scheduleData.category,
      reservedBy: userId,
      dayOfWeek: scheduleData.dayOfWeek,
      startHour: scheduleData.startHour,
      endHour: scheduleData.endHour,
      weekStartDate: weekStartDate,
      status: status
    });
    
    const savedSchedule = await schedule.save();

    // 승인이 필요한 경우 승인 정보 생성
    if (category.requiresApproval) {
      const totalMembers = await RoomMember.countDocuments({ roomId: room._id });
      
      await ReservationApproval.create({
        reservation: savedSchedule._id,
        totalMembersCount: totalMembers,
        approvedBy: []
      });
    }
    
    return savedSchedule;
  },

  /**
   * 예약 승인
   */
  async approveReservation(reservationId, userId) {
    const reservation = await ReservationSchedule.findById(reservationId)
      .populate('category');
    
    if (!reservation) {
      throw new ReservationError('예약을 찾을 수 없습니다.', 404);
    }

    // 방 멤버인지 확인
    const roomMember = await RoomMember.findOne({
      roomId: reservation.room,
      userId: userId
    });

    if (!roomMember) {
      throw new ReservationError('방 멤버만 승인할 수 있습니다.', 403);
    }

    // 예약자 본인은 승인할 수 없음
    if (reservation.reservedBy.toString() === userId.toString()) {
      throw new ReservationError('본인의 예약은 승인할 수 없습니다.', 400);
    }

    // 이미 승인된 예약인지 확인
    if (reservation.status === 'approved') {
      throw new ReservationError('이미 승인된 예약입니다.', 400);
    }

    let approval = await ReservationApproval.findOne({ 
      reservation: reservationId 
    });

    if (!approval) {
      throw new ReservationError('승인 정보를 찾을 수 없습니다.', 404);
    }

    // 이미 승인했는지 확인
    const hasApproved = approval.approvedBy.some(
      app => app.user.toString() === userId.toString()
    );

    if (hasApproved) {
      throw new ReservationError('이미 승인한 예약입니다.', 400);
    }

    // 승인 추가
    approval.approvedBy.push({ user: userId });
    
    // 모든 멤버가 승인했는지 확인
    if (approval.checkFullApproval()) {
      // 시간 겹침 재확인 (승인 시점에서)
      const conflictingReservation = await ReservationSchedule.findOne({
        _id: { $ne: reservationId },
        room: reservation.room,
        category: reservation.category,
        dayOfWeek: reservation.dayOfWeek,
        weekStartDate: reservation.weekStartDate,
        status: 'approved',
        $or: [
          {
            startHour: { $lt: reservation.endHour },
            endHour: { $gt: reservation.startHour }
          }
        ]
      });

      if (conflictingReservation) {
        throw new ReservationError('승인 시점에 해당 시간에 이미 다른 예약이 있습니다.', 409);
      }

      // 예약 상태를 승인으로 변경
      reservation.status = 'approved';
      await reservation.save();
    }

    await approval.save();

    return {
      reservation,
      approval,
      isFullyApproved: approval.isFullyApproved
    };
  },

  /**
   * 예약 삭제
   */
  async deleteSchedule(scheduleId, userId) {
    const schedule = await ReservationSchedule.findById(scheduleId);
    
    if (!schedule) {
      throw new ReservationError('예약을 찾을 수 없습니다.', 404);
    }

    // 예약자만 삭제 가능
    if (schedule.reservedBy.toString() !== userId.toString()) {
      throw new ReservationError('예약자만 삭제할 수 있습니다.', 403);
    }

    // 현재 주의 예약만 삭제 가능
    if (!schedule.isCurrentWeek()) {
      throw new ReservationError('현재 주의 예약만 삭제할 수 있습니다.', 400);
    }

    // 승인 정보도 함께 삭제
    await ReservationApproval.deleteOne({ reservation: scheduleId });
    await schedule.deleteOne();
  },

  /**
   * 지난 주 예약들 자동 정리 (스케줄러에서 호출)
   */
  async cleanupOldReservations() {
    const today = new Date();
    const currentWeekStart = ReservationSchedule.getWeekStartDate(today);
    
    // 지난 주 예약 ID들 조회
    const oldReservations = await ReservationSchedule.find({
      weekStartDate: { $lt: currentWeekStart }
    }, '_id');

    const oldReservationIds = oldReservations.map(r => r._id);

    // 승인 정보 먼저 삭제
    await ReservationApproval.deleteMany({
      reservation: { $in: oldReservationIds }
    });

    // 예약 삭제
    const result = await ReservationSchedule.deleteMany({
      weekStartDate: { $lt: currentWeekStart }
    });

    console.log(`${result.deletedCount}개의 지난 주 예약이 정리되었습니다.`);
    return result;
  }
};

module.exports = reservationScheduleService;