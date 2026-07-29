// frontend/lib/screens/auth/verify_email_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth/auth_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Verify Your Email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Resend Button
              AuthButton(
                text: 'Resend Verification Email',
                onPressed: () {
                  // Resend verification email
                },
              ),
              const SizedBox(height: 16),
              // Back to Login
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}