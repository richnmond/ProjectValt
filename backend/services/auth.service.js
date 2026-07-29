// backend/src/services/auth.service.js
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const User = require('../models/User.model');

class AuthService {
  generateToken(userId) {
    return jwt.sign(
      { id: userId },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );
  }

  async sendVerificationEmail(user) {
    const token = crypto.randomBytes(32).toString('hex');
    user.emailVerificationToken = token;
    user.emailVerificationExpires = Date.now() + 24 * 60 * 60 * 1000;
    await user.save();

    const transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST,
      port: process.env.EMAIL_PORT,
      secure: false,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
    
    await transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to: user.email,
      subject: 'Verify Your Email - ProjectVault',
      html: `
        <h1>Welcome to ProjectVault!</h1>
        <p>Please verify your email by clicking the link below:</p>
        <a href="${verificationUrl}">Verify Email</a>
        <p>This link will expire in 24 hours.</p>
      `
    });
  }

  async sendPasswordResetEmail(user) {
    const token = crypto.randomBytes(32).toString('hex');
    user.resetPasswordToken = token;
    user.resetPasswordExpires = Date.now() + 1 * 60 * 60 * 1000;
    await user.save();

    const transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST,
      port: process.env.EMAIL_PORT,
      secure: false,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    
    await transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to: user.email,
      subject: 'Reset Password - ProjectVault',
      html: `
        <h1>Reset Your Password</h1>
        <p>Click the link below to reset your password:</p>
        <a href="${resetUrl}">Reset Password</a>
        <p>This link will expire in 1 hour.</p>
        <p>If you didn't request this, please ignore this email.</p>
      `
    });
  }
}

module.exports = new AuthService();