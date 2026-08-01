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
