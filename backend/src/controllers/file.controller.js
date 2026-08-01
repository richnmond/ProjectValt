// backend/src/controllers/file.controller.js
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Project = require('../models/Project.model');
const User = require('../models/User.model');

// Local storage directory
const UPLOAD_DIR = path.join(__dirname, '../../uploads');
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

// Configure multer for local disk storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(UPLOAD_DIR, req.user._id.toString(), req.params.projectId);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const safeName = file.originalname.replace(/[^a-zA-Z0-9._-]/g, '_');
    cb(null, `${timestamp}-${safeName}`);
  },
});

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
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
];

exports.upload = multer({
  storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (req, file, cb) => {
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('File type not allowed'), false);
    }
  },
});

exports.uploadFiles = async (req, res) => {
  try {
    const project = await Project.findOne({ _id: req.params.projectId, user: req.user._id });
    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    const files = req.files.map((file) => ({
      fileName: file.filename,
      originalName: file.originalname,
      fileType: file.mimetype,
      fileSize: file.size,
      fileUrl: `/uploads/${req.user._id}/${req.params.projectId}/${file.filename}`,
      s3Key: file.path,
      isEncrypted: false,
    }));

    project.files.push(...files);
    await project.save();

    const totalSize = files.reduce((sum, f) => sum + f.fileSize, 0);
    await User.findByIdAndUpdate(req.user._id, { $inc: { storageUsed: totalSize } });

    res.json({ success: true, data: files });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.getFiles = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
      $or: [{ user: req.user._id }, { visibility: 'Public' }, { 'collaborators.user': req.user._id }],
    });

    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    res.json({ success: true, data: project.files });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.deleteFile = async (req, res) => {
  try {
    const project = await Project.findOne({ _id: req.params.projectId, user: req.user._id });
    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    const fileIndex = project.files.findIndex((f) => f._id.toString() === req.params.fileId);
    if (fileIndex === -1) {
      return res.status(404).json({ success: false, message: 'File not found' });
    }

    const file = project.files[fileIndex];

    // Delete from local disk
    if (file.s3Key && fs.existsSync(file.s3Key)) {
      fs.unlinkSync(file.s3Key);
    }

    project.files.splice(fileIndex, 1);
    await project.save();
    await User.findByIdAndUpdate(req.user._id, { $inc: { storageUsed: -file.fileSize } });

    res.json({ success: true, message: 'File deleted successfully' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.downloadFile = async (req, res) => {
  try {
    const project = await Project.findOne({
      _id: req.params.projectId,
      $or: [{ user: req.user._id }, { visibility: 'Public' }, { 'collaborators.user': req.user._id }],
    });

    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    const file = project.files.find((f) => f._id.toString() === req.params.fileId);
    if (!file) {
      return res.status(404).json({ success: false, message: 'File not found' });
    }

    project.downloads += 1;
    await project.save();

    if (file.s3Key && fs.existsSync(file.s3Key)) {
      return res.download(file.s3Key, file.originalName);
    }

    res.json({ success: true, data: { downloadUrl: file.fileUrl } });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};