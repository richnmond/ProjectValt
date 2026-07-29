// frontend/lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projectvault/providers/project_provider.dart';
import 'package:projectvault/providers/auth_provider.dart';
import 'package:projectvault/widgets/dashboard_stats_card.dart';
import 'package:projectvault/widgets/recent_project_card.dart';
import 'package:projectvault/widgets/loading_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final projectProvider = context.read<ProjectProvider>();
    
    // Load projects
    await projectProvider.loadProjects();
    
    // Load stats
    _stats = await projectProvider.getStats();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    
    if (_isLoading) {
      return const LoadingWidget();
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${authProvider.user?.name ?? ''}!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Here\'s your project overview',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: DashboardStatsCard(
                        title: 'Projects',
                        value: _stats['totalProjects']?.toString() ?? '${projectProvider.projects.length}',
                        icon: Icons.folder,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatsCard(
                        title: 'Files',
                        value: _stats['totalFiles']?.toString() ?? '${projectProvider.projects.fold<int>(0, (sum, p) => sum + p.files.length)}',
                        icon: Icons.attach_file,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DashboardStatsCard(
                        title: 'Storage',
                        value: _formatStorage(_stats['totalStorage'] ?? projectProvider.projects.fold<int>(0, (sum, p) => sum + p.files.fold<int>(0, (s, f) => s + f.fileSize))),
                        icon: Icons.storage,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatsCard(
                        title: 'Completed',
                        value: _stats['completedProjects']?.toString() ?? '${projectProvider.projects.where((p) => p.status == 'Completed').length}',
                        icon: Icons.check_circle,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Chart Section
                _buildChartSection(theme),
                
                const SizedBox(height: 24),
                
                // Recent Projects
                _buildRecentProjects(projectProvider, theme),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(ThemeData theme) {
    final completed = ((_stats['completedProjects'] ?? 0) as num).toDouble();
    final total = ((_stats['totalProjects'] ?? 0) as num).toDouble();
    final archived = ((_stats['archivedProjects'] ?? 0) as num).toDouble();
    final inProgress = (total - completed - archived).clamp(0.0, double.infinity);

    final hasData = completed > 0 || inProgress > 0 || archived > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: hasData
                  ? PieChart(
                      PieChartData(
                        sections: [
                          if (completed > 0)
                            PieChartSectionData(
                              value: completed,
                              color: Colors.green,
                              title: 'Completed',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (inProgress > 0)
                            PieChartSectionData(
                              value: inProgress,
                              color: Colors.blue,
                              title: 'In Progress',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (archived > 0)
                            PieChartSectionData(
                              value: archived,
                              color: Colors.grey,
                              title: 'Archived',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    )
                  : Center(
                      child: Text(
                        'No project metrics yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProjects(ProjectProvider provider, ThemeData theme) {
    final recentProjects = provider.projects.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Projects',
              style: theme.textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {
                context.go('/projects');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentProjects.map((project) => RecentProjectCard(project: project)),
        if (recentProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects yet',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.go('/projects/create');
                  },
                  child: const Text('Create Your First Project'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatStorage(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}