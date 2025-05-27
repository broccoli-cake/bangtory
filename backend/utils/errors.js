// backend/utils/errors.js

class ChoreError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.name = 'ChoreError';
    this.statusCode = statusCode;
  }
}

module.exports = {
  ChoreError
}; 


class ReservationError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.name = 'ReservationError';
    this.statusCode = statusCode;
  }
}

class ValidationError extends Error {
  constructor(message, details = []) {
    super(message);
    this.name = 'ValidationError';
    this.statusCode = 400;
    this.details = details;
  }
}

module.exports = {
  ReservationError,
  ValidationError
};