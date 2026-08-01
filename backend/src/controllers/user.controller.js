// backend/src/controllers/user.controller.js
const bcrypt = require('bcryptjs');
const User = require('../models/User.model');

exports.getProfile = async (req, res) => {
  try {
    const user = req.user;
    res.json({
      success: true,
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        isEmailVerified: user.isEmailVerified,
        storageUsed: user.storageUsed,
        storageLimit: user.storageLimit,
        profilePicture: user.profilePicture,
        bio: user.bio,
        settings: user.settings,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, bio, settings } = req.body;
    const updates = {};
    if (name !== undefined) updates.name = name;
    if (bio !== undefined) updates.bio = bio;
    if (settings !== undefined) updates.settings = settings;

    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      new: true,
      runValidators: true,
    });

    res.json({
      success: true,
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        bio: user.bio,
        settings: user.settings,
        profilePicture: user.profilePicture,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const user = await User.findById(req.user._id).select('+password');

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Current password is incorrect' });
    }

    user.password = await bcrypt.hash(newPassword, 12);
    await user.save();

    res.json({ success: true, message: 'Password updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getActivity = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('activityLogs');
    res.json({ success: true, data: user.activityLogs || [] });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
