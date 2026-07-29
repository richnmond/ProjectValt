// frontend/lib/screens/projects/projects_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/project_provider.dart';
import '../../widgets/project_card.dart';
import '../../widgets/common/custom_search_bar.dart';
import '../../widgets/common/filter_chips.dart';
import '../../widgets/common/loading_widget.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  
  final List<String> _categories = [
    'All',
    'Web Development',
    'Mobile App',
    'Desktop App',
    'Game Development',
    'Machine Learning',
    'Data Science',
    'IoT',
    'Blockchain',
    'DevOps',
    'UI/UX Design',
    'Documentation',
    'Research',
    'Other',
  ];
  
  final List<String> _statuses = [
    'All',
    'In Progress',
    'Completed',
    'Archived',
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final provider = context.read<ProjectProvider>();
    await provider.loadProjects(
      search: _searchController.text,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      status: _selectedStatus == 'All' ? null : _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/projects/create');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: (value) {
                _loadProjects();
              },
              hintText: 'Search projects...',
            ),
          ),
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterChips(
                  title: 'Category',
                  chips: _categories,
                  selected: _selectedCategory,
                  onSelected: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _loadProjects();
                  },
                ),
                const SizedBox(height: 8),
                FilterChips(
                  title: 'Status',
                  chips: _statuses,
                  selected: _selectedStatus,
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _loadProjects();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Project List
          Expanded(
            child: projectProvider.isLoading && projectProvider.projects.isEmpty
                ? const LoadingWidget()
                : projectProvider.projects.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: projectProvider.projects.length,
                          itemBuilder: (context, index) {
                            final project = projectProvider.projects[index];
                            return ProjectCard(
                              project: project,
                              onTap: () {
                                context.go('/projects/${project.id}');
                              },
                              onEdit: () {
                                // Navigate to edit project or details
                                context.go('/projects/${project.id}');
                              },
                              onDelete: () async {
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
                                
                                if (confirm == true && mounted) {
                                  await projectProvider.deleteProject(project.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Project deleted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No projects found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to get started',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/projects/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
        ],
      ),
    );
  }
}