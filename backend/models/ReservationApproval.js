// backend/models/ReservationApproval.js
const mongoose = require('mongoose');

const reservationApprovalSchema = new mongoose.Schema({
  reservation: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ReservationSchedule',
    required: true
  },
  approvedBy: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    approvedAt: {
      type: Date,
      default: Date.now
    }
  }],
  totalMembersCount: {
    type: Number,
    required: true
  },
  isFullyApproved: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// 승인 완료 확인 메서드
reservationApprovalSchema.methods.checkFullApproval = function() {
  // 예약자를 제외한 모든 멤버가 승인했는지 확인
  this.isFullyApproved = this.approvedBy.length >= this.totalMembersCount - 1;
  return this.isFullyApproved;
};

module.exports = mongoose.model('ReservationApproval', reservationApprovalSchema);