// backend/models/ReservationSchedule.js
const mongoose = require('mongoose');

const reservationScheduleSchema = new mongoose.Schema({
  room: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room',
    required: true
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ReservationCategory',
    required: true
  },
  reservedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  // 요일 (0: 일요일, 1: 월요일, ..., 6: 토요일) - 방문객이 아닌 경우만 사용
  dayOfWeek: {
    type: Number,
    min: 0,
    max: 6
  },
  // 특정 날짜 - 방문객인 경우만 사용
  specificDate: {
    type: Date
  },
  // 시작 시간 (24시간 형식, 예: 14 = 오후 2시)
  startHour: {
    type: Number,
    required: true,
    min: 0,
    max: 23
  },
  // 종료 시간 (24시간 형식, 예: 16 = 오후 4시)
  endHour: {
    type: Number,
    required: true,
    min: 1,
    max: 24
  },
  // 해당 주의 시작 날짜 (월요일 기준) - 방문객이 아닌 경우만 사용
  weekStartDate: {
    type: Date
  },
  // 매주 반복 여부 - 방문객이 아닌 경우만 사용
  isRecurring: {
    type: Boolean,
    default: false
  },
  // 예약 상태 (pending: 승인대기, approved: 승인완료)
  status: {
    type: String,
    enum: ['pending', 'approved'],
    default: 'approved'
  }
}, {
  timestamps: true
});

// 인덱스 설정
reservationScheduleSchema.index({ 
  room: 1, 
  category: 1, 
  dayOfWeek: 1,
  weekStartDate: 1,
  startHour: 1, 
  endHour: 1 
});

reservationScheduleSchema.index({ 
  room: 1, 
  category: 1, 
  specificDate: 1,
  startHour: 1, 
  endHour: 1 
});

// 예약 시간 유효성 검사
reservationScheduleSchema.pre('save', function(next) {
  if (this.startHour >= this.endHour) {
    return next(new Error('시작 시간은 종료 시간보다 빨라야 합니다.'));
  }
  
  next();
});

// 주의 시작 날짜(월요일) 계산 헬퍼 메서드
reservationScheduleSchema.statics.getWeekStartDate = function(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1); // 월요일을 주의 시작으로
  const monday = new Date(d.setDate(diff));
  monday.setHours(0, 0, 0, 0);
  return monday;
};

// 현재 주인지 확인하는 메서드
reservationScheduleSchema.methods.isCurrentWeek = function() {
  if (this.specificDate) {
    // 방문객 예약은 특정 날짜 기준으로 확인
    const today = new Date();
    const reservationDate = new Date(this.specificDate);
    const todayStr = today.toDateString();
    const reservationStr = reservationDate.toDateString();
    return todayStr === reservationStr || reservationDate >= today;
  } else {
    // 일반 예약은 주 단위로 확인
    const today = new Date();
    const currentWeekStart = this.constructor.getWeekStartDate(today);
    return this.weekStartDate.getTime() === currentWeekStart.getTime();
  }
};

// 다음 주 예약 생성 메서드 (매주 반복용)
reservationScheduleSchema.methods.createNextWeekReservation = async function() {
  if (!this.isRecurring || this.specificDate) {
    return null;
  }

  const nextWeekStart = new Date(this.weekStartDate);
  nextWeekStart.setDate(nextWeekStart.getDate() + 7);

  // 이미 다음 주 예약이 있는지 확인
  const existingReservation = await this.constructor.findOne({
    room: this.room,
    category: this.category,
    reservedBy: this.reservedBy,
    dayOfWeek: this.dayOfWeek,
    weekStartDate: nextWeekStart,
    startHour: this.startHour,
    endHour: this.endHour
  });

  if (existingReservation) {
    return existingReservation;
  }

  // 새로운 다음 주 예약 생성
  const nextWeekReservation = new this.constructor({
    room: this.room,
    category: this.category,
    reservedBy: this.reservedBy,
    dayOfWeek: this.dayOfWeek,
    startHour: this.startHour,
    endHour: this.endHour,
    weekStartDate: nextWeekStart,
    isRecurring: true,
    status: 'approved' // 반복 예약은 자동으로 승인
  });

  return await nextWeekReservation.save();
};

const ReservationSchedule = mongoose.model('ReservationSchedule', reservationScheduleSchema);

module.exports = ReservationSchedule;