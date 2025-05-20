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