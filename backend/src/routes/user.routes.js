// backend/src/routes/user.routes.js
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const userController = require('../controllers/user.controller');

router.use(protect);

router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);
router.put('/change-password', userController.changePassword);
router.get('/activity', userController.getActivity);

module.exports = router;
