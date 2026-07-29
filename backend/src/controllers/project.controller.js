// backend/src/controllers/project.controller.js
const Project = require('../models/Project.model');
const User = require('../models/User.model');
const crypto = require('crypto');

exports.createProject = async (req, res) => {
  try {
    const projectData = {
      ...req.body,
      user: req.user.id
    };

    const project = await Project.create(projectData);
    
    // Log activity
    await User.findByIdAndUpdate(req.user.id, {
      $push: {
        activityLogs: {
          action: 'Project Created',
          details: { projectId: project._id, projectName: project.name }
        }
      }
    });

    res.status(201).json({
      success: true,
      data: project
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.getProjects = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search,
      category,
      status,
      technology,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const query = { user: req.user.id };
    
    if (search) {
      query.$text = { $search: search };
    }
    if (category) {
      query.category = category;
    }
    if (status) {
      query.status = status;
    }
    if (technology) {
      query.technologies = technology;
    }

    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    const projects = await Project.find(query)
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Project.countDocuments(query);

    res.json({
      success: true,
      data: projects,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.getProjectById = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.id,
      $or: [
        { user: req.user.id },
        { visibility: 'Public' },
        { 'collaborators.user': req.user.id }
      ]
    });

    if (!project) {
      return res.status(404).json({
        success: false,
        message: 'Project not found'
      });
    }

    // Increment views
    project.views += 1;
    await project.save();

    res.json({
      success: true,
      data: project
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.updateProject = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.id,
      user: req.user.id
    });

    if (!project) {
      return res.status(404).json({
        success: false,
        message: 'Project not found'
      });
    }

    // Version tracking
    if (req.body.name || req.body.description) {
      project.version += 1;
      project.versions.push({
        versionNumber: project.version,
        changes: 'Project details updated',
        files: project.files.map(f => f.fileName)
      });
    }

    Object.assign(project, req.body);

    if (req.body.status === 'Completed' && !project.dateCompleted) {
      project.dateCompleted = new Date();
    }

    await project.save();

    res.json({
      success: true,
      data: project
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.deleteProject = async (req, res) => {
  try {
    const project = await Project.findOneAndDelete({
      _id: req.params.id,
      user: req.user.id
    });

    if (!project) {
      return res.status(404).json({
        success: false,
        message: 'Project not found'
      });
    }

    res.json({
      success: true,
      message: 'Project deleted successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.archiveProject = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.id,
      user: req.user.id
    });

    if (!project) {
      return res.status(404).json({
        success: false,
        message: 'Project not found'
      });
    }

    project.isArchived = true;
    project.archivedAt = new Date();
    project.status = 'Archived';
    await project.save();

    res.json({
      success: true,
      data: project
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.getProjectStats = async (req, res) => {
  try {
    const stats = await Project.aggregate([
      { $match: { user: req.user._id } },
      {
        $group: {
          _id: null,
          totalProjects: { $sum: 1 },
          totalFiles: { $sum: { $size: '$files' } },
          totalStorage: { $sum: { $sum: '$files.fileSize' } },
          completedProjects: {
            $sum: { $cond: [{ $eq: ['$status', 'Completed'] }, 1, 0] }
          },
          archivedProjects: {
            $sum: { $cond: [{ $eq: ['$status', 'Archived'] }, 1, 0] }
          }
        }
      }
    ]);

    res.json({
      success: true,
      data: stats[0] || {
        totalProjects: 0,
        totalFiles: 0,
        totalStorage: 0,
        completedProjects: 0,
        archivedProjects: 0
      }
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};