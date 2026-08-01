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
