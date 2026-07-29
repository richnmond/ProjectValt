// frontend/lib/screens/projects/project_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../widgets/project/project_details_header.dart';
import '../../widgets/project/project_files_list.dart';
import '../../widgets/common/loading_widget.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;
  
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    final provider = context.read<ProjectProvider>();
    await provider.getProjectById(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final project = projectProvider.currentProject;
    final theme = Theme.of(context);
    
    if (projectProvider.isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }
    
    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Project not found',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The project you\'re looking for doesn\'t exist',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.go('/projects');
                },
                child: const Text('Back to Projects'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: Icon(
              project.visibility == 'Public' ? Icons.public : Icons.lock,
            ),
            onPressed: () {
              // Toggle visibility
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMenu(context, project);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Project Header
                ProjectDetailsHeader(project: project),
                const SizedBox(height: 24),
                // Description
                if (project.description.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                ],
                // Technologies
                if (project.technologies.isNotEmpty) ...[
                  Text(
                    'Technologies',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: project.technologies.map((tech) {
                      return Chip(
                        label: Text(tech),
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Tags
                if (project.tags.isNotEmpty) ...[
                  Text(
                    'Tags',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: project.tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Project Info
                _buildProjectInfo(project, theme),
                const SizedBox(height: 24),
                // Files
                Text(
                  'Files (${project.files.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ProjectFilesList(
                  projectId: project.id,
                  files: project.files,
                  onUpload: () {
                    context.go('/upload/${project.id}');
                  },
                ),
                const SizedBox(height: 24),
                // Documentation
                if (project.documentation != null) ...[
                  Text(
                    'Documentation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDocumentation(project, theme),
                ],
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/upload/${project.id}');
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Files'),
      ),
    );
  }

  Widget _buildProjectInfo(dynamic project, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Category',
              project.category,
              Icons.category,
              theme,
            ),
            _buildInfoRow(
              'Status',
              project.status,
              _getStatusIcon(project.status),
              theme,
            ),
            _buildInfoRow(
              'Created',
              DateFormat('MMM dd, yyyy').format(project.dateStarted),
              Icons.calendar_today,
              theme,
            ),
            if (project.dateCompleted != null)
              _buildInfoRow(
                'Completed',
                DateFormat('MMM dd, yyyy').format(project.dateCompleted),
                Icons.check_circle,
                theme,
              ),
            _buildInfoRow(
              'Files',
              '${project.files.length} files',
              Icons.attach_file,
              theme,
            ),
            _buildInfoRow(
              'Views',
              '${project.views}',
              Icons.remove_red_eye,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'In Progress':
        return Icons.timeline;
      case 'Archived':
        return Icons.archive;
      default:
        return Icons.help;
    }
  }

  Widget _buildDocumentation(dynamic project, ThemeData theme) {
    final docs = project.documentation;
    final Map<String, String> docSections = {
      'Requirements': docs['requirements'] ?? '',
      'Design': docs['design'] ?? '',
      'Implementation': docs['implementation'] ?? '',
      'Testing': docs['testing'] ?? '',
      'Deployment': docs['deployment'] ?? '',
      'User Manual': docs['userManual'] ?? '',
      'API Documentation': docs['apiDocs'] ?? '',
    };
    
    final visibleDocs = docSections.entries.where((e) => e.value.isNotEmpty).toList();
    
    if (visibleDocs.isEmpty) {
      return const Text('No documentation available');
    }
    
    return Column(
      children: visibleDocs.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              entry.key,
              style: theme.textTheme.titleSmall,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  entry.value,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showMenu(BuildContext context, dynamic project) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Project'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit
                },
              ),
              ListTile(
                leading: Icon(
                  project.isArchived ? Icons.unarchive : Icons.archive,
                ),
                title: Text(project.isArchived ? 'Unarchive' : 'Archive'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleArchive(project);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Project'),
                onTap: () {
                  Navigator.pop(context);
                  // Share project
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download All Files'),
                onTap: () {
                  Navigator.pop(context);
                  // Download all files
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Project',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(project);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleArchive(dynamic project) async {
    final provider = context.read<ProjectProvider>();
    if (project.isArchived) {
      // Unarchive - we need to implement this
    } else {
      await provider.archiveProject(project.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project ${project.isArchived ? 'unarchived' : 'archived'} successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProject();
    }
  }

  Future<void> _confirmDelete(dynamic project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final provider = context.read<ProjectProvider>();
      await provider.deleteProject(project.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/projects');
      }
    }
  }
}