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
  constructor(message, statusCode = 500) {
    super(message);
    this.name = 'ReservationError';
    this.statusCode = statusCode;
  }
}

module.exports = {
  ReservationError
};