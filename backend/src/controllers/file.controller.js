// backend/src/controllers/file.controller.js
const AWS = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
const crypto = require('crypto');
const Project = require('../models/Project.model');

// Configure AWS
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

const s3 = new AWS.S3();

// Encryption helper
const encryptFile = (buffer) => {
  const cipher = crypto.createCipher('aes-256-cbc', process.env.ENCRYPTION_KEY);
  return Buffer.concat([cipher.update(buffer), cipher.final()]);
};

// Configure multer for S3 upload
const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.AWS_S3_BUCKET,
    acl: 'private',
    key: function (req, file, cb) {
      const userId = req.user.id;
      const projectId = req.params.projectId;
      const timestamp = Date.now();
      const fileName = `${userId}/${projectId}/${timestamp}-${file.originalname}`;
      cb(null, fileName);
    }
  }),
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB limit
  },
  fileFilter: function (req, file, cb) {
    const allowedTypes = [
      'application/pdf',
      'application/zip',
      'image/jpeg',
      'image/png',
      'image/gif',
      'video/mp4',
      'video/webm',
      'text/plain',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ];
    
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('File type not allowed'), false);
    }
  }
});

exports.uploadFiles = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
      user: req.user.id
    });

    if (!project) {
      return res.status(404).json({
        success: false,
        message: 'Project not found'
      });
    }

    const files = req.files.map(file => ({
      fileName: file.key,
      originalName: file.originalname,
      fileType: file.mimetype,
      fileSize: file.size,
      fileUrl: file.location,
      s3Key: file.key,
      isEncrypted: true
    }));

    project.files.push(...files);
    await project.save();

    // Update user storage usage
    const totalSize = files.reduce((sum, f) => sum + f.fileSize, 0);
    await User.findByIdAndUpdate(req.user.id, {
      $inc: { storageUsed: totalSize }
    });

    res.json({
      success: true,
      data: files
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.getFiles = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
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

    res.json({
      success: true,
      data: project.files
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.deleteFile = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
      user: req.user.id
    });

    if (!project) {
      return res.status(404).json({
        success: false,
        message: 'Project not found'
      });
    }

    const fileIndex = project.files.findIndex(f => f._id.toString() === req.params.fileId);
    if (fileIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'File not found'
      });
    }

    const file = project.files[fileIndex];
    
    // Delete from S3
    await s3.deleteObject({
      Bucket: process.env.AWS_S3_BUCKET,
      Key: file.s3Key
    }).promise();

    project.files.splice(fileIndex, 1);
    await project.save();

    // Update user storage
    await User.findByIdAndUpdate(req.user.id, {
      $inc: { storageUsed: -file.fileSize }
    });

    res.json({
      success: true,
      message: 'File deleted successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

exports.downloadFile = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
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

    const file = project.files.find(f => f._id.toString() === req.params.fileId);
    if (!file) {
      return res.status(404).json({
        success: false,
        message: 'File not found'
      });
    }

    // Generate signed URL for download
    const url = s3.getSignedUrl('getObject', {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: file.s3Key,
      Expires: 60 // URL expires in 60 seconds
    });

    // Increment download count
    project.downloads += 1;
    await project.save();

    res.json({
      success: true,
      data: { downloadUrl: url }
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};