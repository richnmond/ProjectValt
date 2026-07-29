// backend/src/routes/auth.routes.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

router.post('/register', [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], authController.register);

router.post('/login', [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').notEmpty().withMessage('Password is required')
], authController.login);

router.post('/verify-email', authController.verifyEmail);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.post('/logout', protect, authController.logout);
router.get('/me', protect, authController.getCurrentUser);

module.exports = router;

// backend/src/routes/project.routes.js
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const projectController = require('../controllers/project.controller');

router.use(protect);

router.post('/', projectController.createProject);
router.get('/', projectController.getProjects);
router.get('/stats', projectController.getProjectStats);
router.get('/:id', projectController.getProjectById);
router.put('/:id', projectController.updateProject);
router.delete('/:id', projectController.deleteProject);
router.post('/:id/archive', projectController.archiveProject);

module.exports = router;

// backend/src/routes/file.routes.js
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware');
const fileController = require('../controllers/file.controller');

router.use(protect);

router.post('/:projectId/upload', fileController.upload.array('files', 10), fileController.uploadFiles);
router.get('/:projectId/files', fileController.getFiles);
router.delete('/:projectId/files/:fileId', fileController.deleteFile);
router.get('/:projectId/files/:fileId/download', fileController.downloadFile);

module.exports = router;