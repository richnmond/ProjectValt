// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/project_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoSave = true;
  String _language = 'English';
  final String _storageLocation = 'Cloud (Default)';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // User Profile Section
          if (user != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: user.isEmailVerified
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.isEmailVerified ? 'Verified' : 'Unverified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: user.isEmailVerified
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.go('/profile');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Account Section
          _buildSection(
            context,
            title: 'Account',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Change your personal information',
                onTap: () {
                  context.go('/profile');
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {
                  context.push('/forgot-password');
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Appearance Section
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Preferences Section
          _buildSection(
            context,
            title: 'Preferences',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive notifications about your projects'),
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.save_outlined),
                title: const Text('Auto-save'),
                subtitle: const Text('Automatically save your work'),
                value: _autoSave,
                onChanged: (value) {
                  setState(() {
                    _autoSave = value;
                  });
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: _language,
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.storage,
                title: 'Storage Location',
                subtitle: _storageLocation,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Storage Section
          _buildSection(
            context,
            title: 'Storage',
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Used Storage',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${(projectProvider.projects.fold<int>(0, (sum, p) => sum + p.files.fold<int>(0, (s, f) => s + f.fileSize)) / (1024 * 1024)).toStringAsFixed(1)} MB',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (projectProvider.projects.fold<int>(0, (sum, p) => sum + p.files.fold<int>(0, (s, f) => s + f.fileSize)) / (1024 * 1024)) / 1024,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 GB total storage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Support Section
          _buildSection(
            context,
            title: 'Support',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () {
                  _launchURL('https://projectvault.com/help');
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Tell us what you think',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About ProjectVault',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Account Actions Section
          _buildSection(
            context,
            title: 'Account Actions',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () {
                  _confirmLogout(context);
                },
                iconColor: Colors.red,
                titleColor: Colors.red,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () {
                  _confirmDeleteAccount(context);
                },
                iconColor: Colors.red,
                titleColor: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                setState(() {
                  _language = 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () {
                setState(() {
                  _language = 'Spanish';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('French'),
              onTap: () {
                setState(() {
                  _language = 'French';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'ProjectVault',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.folder,
            color: Colors.white,
            size: 28,
          ),
        ),
        children: const [
          SizedBox(height: 8),
          Text(
            'Your Personal Project Repository\n'
            'Store, organize, and share your projects.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your projects and data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion requested'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}