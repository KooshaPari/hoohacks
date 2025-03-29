const express = require('express');
const userController = require('../controllers/userController');

const router = express.Router();

// Public routes
router.post('/signup', userController.signup);
router.post('/login', userController.login);

// Protected routes
router.use(userController.protect);
router.patch('/updateProfile', userController.updateProfile);
router.patch('/updatePassword', userController.updatePassword);

module.exports = router;
