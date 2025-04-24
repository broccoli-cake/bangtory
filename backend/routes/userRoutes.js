const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");
const { auth } = require("../middlewares/authMiddleware");

router.get("/users", auth, userController.getUsers);

module.exports = router;