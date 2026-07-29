// frontend/lib/config/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projectvault/screens/splash_screen.dart';
import 'package:projectvault/screens/auth/login_screen.dart';
import 'package:projectvault/screens/auth/register_screen.dart';
import 'package:projectvault/screens/auth/forgot_password_screen.dart';
import 'package:projectvault/screens/auth/verify_email_screen.dart';
import 'package:projectvault/screens/dashboard/dashboard_screen.dart';
import 'package:projectvault/screens/projects/projects_screen.dart';
import 'package:projectvault/screens/projects/project_details_screen.dart';
import 'package:projectvault/screens/projects/create_project_screen.dart';
import 'package:projectvault/screens/upload/upload_screen.dart';
import 'package:projectvault/screens/settings/settings_screen.dart';
import 'package:projectvault/screens/profile/profile_screen.dart';
import 'package:projectvault/screens/main_shell.dart';
import 'package:projectvault/providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          name: 'verify-email',
          builder: (context, state) => const VerifyEmailScreen(),
        ),
        
        // ShellRoute for main tabs
        ShellRoute(
          builder: (context, state, child) {
            return MainShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
              redirect: (context, state) {
                return authProvider.isAuthenticated ? null : '/login';
              },
            ),
            GoRoute(
              path: '/projects',
              name: 'projects',
              builder: (context, state) => const ProjectsScreen(),
              redirect: (context, state) {
                return authProvider.isAuthenticated ? null : '/login';
              },
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
              redirect: (context, state) {
                return authProvider.isAuthenticated ? null : '/login';
              },
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
              redirect: (context, state) {
                return authProvider.isAuthenticated ? null : '/login';
              },
            ),
          ],
        ),

        // Sub-routes outside ShellRoute
        // IMPORTANT: /projects/create MUST be defined BEFORE /projects/:id
        GoRoute(
          path: '/projects/create',
          name: 'create-project',
          builder: (context, state) => const CreateProjectScreen(),
          redirect: (context, state) {
            return authProvider.isAuthenticated ? null : '/login';
          },
        ),
        GoRoute(
          path: '/projects/:id',
          name: 'project-details',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProjectDetailsScreen(projectId: id);
          },
          redirect: (context, state) {
            return authProvider.isAuthenticated ? null : '/login';
          },
        ),
        GoRoute(
          path: '/upload/:projectId',
          name: 'upload',
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            return UploadScreen(projectId: projectId);
          },
          redirect: (context, state) {
            return authProvider.isAuthenticated ? null : '/login';
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you\'re looking for doesn\'t exist.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fallback static getter for backward compatibility
  static GoRouter get router => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/projects/create',
        name: 'create-project',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'project-details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectDetailsScreen(projectId: id);
        },
      ),
      GoRoute(
        path: '/upload/:projectId',
        name: 'upload',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return UploadScreen(projectId: projectId);
        },
      ),
    ],
  );
}