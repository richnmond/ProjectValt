// backend/src/models/Project.model.js
const mongoose = require('mongoose');

const projectSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: [true, 'Please provide a project name'],
    trim: true,
    maxlength: [100, 'Project name cannot be more than 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Please provide a project description'],
    maxlength: [2000, 'Description cannot be more than 2000 characters']
  },
  technologies: [{
    type: String,
    trim: true
  }],
  category: {
    type: String,
    required: [true, 'Please provide a category'],
    enum: ['Web Development', 'Mobile App', 'Desktop App', 'Game Development', 
           'Machine Learning', 'Data Science', 'IoT', 'Blockchain', 'DevOps',
           'UI/UX Design', 'Documentation', 'Research', 'Other']
  },
  status: {
    type: String,
    enum: ['In Progress', 'Completed', 'Archived'],
    default: 'In Progress'
  },
  visibility: {
    type: String,
    enum: ['Public', 'Private'],
    default: 'Private'
  },
  tags: [{
    type: String,
    trim: true
  }],
  dateStarted: {
    type: Date,
    default: Date.now
  },
  dateCompleted: {
    type: Date
  },
  files: [{
    fileName: String,
    originalName: String,
    fileType: String,
    fileSize: Number,
    fileUrl: String,
    s3Key: String,
    uploadedAt: {
      type: Date,
      default: Date.now
    },
    isEncrypted: {
      type: Boolean,
      default: true
    }
  }],
  documentation: {
    requirements: String,
    design: String,
    implementation: String,
    testing: String,
    deployment: String,
    userManual: String,
    apiDocs: String
  },
  collaborators: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    role: {
      type: String,
      enum: ['viewer', 'editor', 'admin'],
      default: 'viewer'
    },
    addedAt: {
      type: Date,
      default: Date.now
    }
  }],
  views: {
    type: Number,
    default: 0
  },
  downloads: {
    type: Number,
    default: 0
  },
  archivedAt: {
    type: Date
  },
  isArchived: {
    type: Boolean,
    default: false
  },
  version: {
    type: Number,
    default: 1
  },
  versions: [{
    versionNumber: Number,
    changes: String,
    createdAt: {
      type: Date,
      default: Date.now
    },
    files: [String]
  }]
}, {
  timestamps: true
});

// Index for search
projectSchema.index({ name: 'text', description: 'text', tags: 'text' });

module.exports = mongoose.model('Project', projectSchema);