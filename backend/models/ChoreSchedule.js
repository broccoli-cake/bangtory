const mongoose = require('mongoose');

const choreScheduleSchema = new mongoose.Schema({
  room: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room',
    required: true
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chore',
    required: true
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  isCompleted: {
    type: Boolean,
    default: false
  },
  completedAt: {
    type: Date
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

// 날짜와 방으로 인덱스 생성
choreScheduleSchema.index({ date: 1, room: 1 });

const ChoreSchedule = mongoose.model('ChoreSchedule', choreScheduleSchema);

module.exports = ChoreSchedule; 