// backend/utils/responses.js
const successResponse = (data, message = 'Success') => {
  return {
    success: true,
    message,
    data
  };
};

const errorResponse = (message, details = null) => {
  return {
    success: false,
    message,
    details
  };
};

module.exports = {
  successResponse,
  errorResponse
};