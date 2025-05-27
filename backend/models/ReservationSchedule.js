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
  // 요일 (0: 일요일, 1: 월요일, ..., 6: 토요일)
  dayOfWeek: {
    type: Number,
    required: true,
    min: 0,
    max: 6
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
  // 해당 주의 시작 날짜 (월요일 기준)
  weekStartDate: {
    type: Date,
    required: true
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

// 시간 겹침 방지를 위한 인덱스
reservationScheduleSchema.index({ 
  room: 1, 
  category: 1, 
  dayOfWeek: 1,
  weekStartDate: 1,
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
  const today = new Date();
  const currentWeekStart = this.constructor.getWeekStartDate(today);
  return this.weekStartDate.getTime() === currentWeekStart.getTime();
};

const ReservationSchedule = mongoose.model('ReservationSchedule', reservationScheduleSchema);

module.exports = ReservationSchedule;