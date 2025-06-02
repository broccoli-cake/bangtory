// backend/middlewares/validation.js
const { body, validationResult } = require('express-validator');
const { ValidationError } = require('../utils/errors');

const validateReservationCategory = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('카테고리 이름은 필수입니다.')
    .isLength({ min: 1, max: 20 })
    .withMessage('카테고리 이름은 1-20자 사이여야 합니다.'),

  body('icon')
    .trim()
    .notEmpty()
    .withMessage('아이콘은 필수입니다.'),
    // 글자 수 제한 제거 - .isLength({ min: 1, max: 10 }) 삭제
  
  body('requiresApproval')
    .optional()
    .isBoolean()
    .withMessage('승인 필요 여부는 불린 값이어야 합니다.'),
  
  body('isVisitor')
    .optional()
    .isBoolean()
    .withMessage('방문객 여부는 불린 값이어야 합니다.'),

  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw new ValidationError('입력 데이터가 유효하지 않습니다.', errors.array());
    }
    next();
  }
];

const validateReservationSchedule = [
  body('room')
    .notEmpty()
    .withMessage('방 ID는 필수입니다.')
    .isMongoId()
    .withMessage('유효한 방 ID가 아닙니다.'),
  
  body('category')
    .notEmpty()
    .withMessage('카테고리 ID는 필수입니다.')
    .isMongoId()
    .withMessage('유효한 카테고리 ID가 아닙니다.'),
  
  body('startHour')
    .isInt({ min: 0, max: 23 })
    .withMessage('시작 시간은 0-23 사이의 정수여야 합니다.'),
  
  body('endHour')
    .isInt({ min: 1, max: 24 })
    .withMessage('종료 시간은 1-24 사이의 정수여야 합니다.'),
  
  body('dayOfWeek')
    .optional()
    .isInt({ min: 0, max: 6 })
    .withMessage('요일은 0-6 사이의 정수여야 합니다.'),
  
  body('specificDate')
    .optional()
    .isISO8601()
    .withMessage('유효한 날짜 형식이 아닙니다.'),
  
  body('isRecurring')
    .optional()
    .isBoolean()
    .withMessage('반복 여부는 불린 값이어야 합니다.'),

  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw new ValidationError('입력 데이터가 유효하지 않습니다.', errors.array());
    }
    
    // 시작 시간과 종료 시간 검증
    if (req.body.startHour >= req.body.endHour) {
      throw new ValidationError('시작 시간은 종료 시간보다 빨라야 합니다.');
    }
    
    next();
  }
];

module.exports = {
  // 기존 검증 함수들...
  validateReservationCategory,
  validateReservationSchedule
};