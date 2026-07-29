// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            _buildProfilePicture(user, theme),
            const SizedBox(height: 24),

            // User Info
            if (!_isEditing)
              _buildUserInfo(user, theme, projectProvider)
            else
              _buildEditForm(user, theme),

            const SizedBox(height: 32),

            // Stats
            _buildStats(projectProvider, theme),

            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(theme),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(User user, ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor.withOpacity(0.1),
            border: Border.all(
              color: theme.primaryColor,
              width: 3,
            ),
            image: user.profilePicture != null
                ? DecorationImage(
                    image: NetworkImage(user.profilePicture!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: user.profilePicture == null
              ? Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(User user, ThemeData theme, ProjectProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                user.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'About',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(user.bio!),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Member since',
              DateFormat('MMM yyyy').format(user.createdAt),
            ),
            _buildInfoRow(
              context,
              'Projects',
              '${provider.projects.length}',
            ),
            _buildInfoRow(
              context,
              'Files',
              '${provider.projects.fold<int>(0, (sum, p) => sum + p.files.length)}',
            ),
            _buildInfoRow(
              context,
              'Storage Used',
              '${(provider.projects.fold<int>(0, (sum, p) => sum + p.files.fold<int>(0, (s, f) => s + f.fileSize)) / (1024 * 1024)).toStringAsFixed(1)} MB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(User user, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _nameController.text = user.name;
                          _bioController.text = user.bio ?? '';
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(ProjectProvider provider, ThemeData theme) {
    final stats = {
      'Total Projects': provider.projects.length,
      'Completed': provider.projects.where((p) => p.status == 'Completed').length,
      'In Progress': provider.projects.where((p) => p.status == 'In Progress').length,
      'Archived': provider.projects.where((p) => p.status == 'Archived').length,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Project Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: stats.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.value.toString(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        entry.key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.create, size: 20),
              ),
              title: Text('Created new project "E-commerce App"'),
              subtitle: Text('2 hours ago'),
            ),
            const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.upload_file, size: 20),
              ),
              title: Text('Uploaded 3 files to "AI Chatbot"'),
              subtitle: Text('1 day ago'),
            ),
            const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.share, size: 20),
              ),
              title: Text('Shared "Portfolio" with team'),
              subtitle: Text('3 days ago'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.updateProfile({
      'name': _nameController.text,
      'bio': _bioController.text,
    });

    if (mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}