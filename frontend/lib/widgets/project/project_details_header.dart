// lib/widgets/project/project_details_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';

class ProjectDetailsHeader extends StatelessWidget {
  final Project project;

  const ProjectDetailsHeader({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: theme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(project.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: project.isPublic
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  project.isPublic
                                      ? Icons.public
                                      : Icons.lock,
                                  size: 12,
                                  color: project.isPublic
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  project.isPublic ? 'Public' : 'Private',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: project.isPublic
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.calendar_today,
                  'Created',
                  DateFormat('MMM dd, yyyy').format(project.dateStarted),
                ),
                _buildStatItem(
                  context,
                  Icons.attach_file,
                  'Files',
                  '${project.files.length}',
                ),
                _buildStatItem(
                  context,
                  Icons.remove_red_eye,
                  'Views',
                  '${project.views}',
                ),
                if (project.dateCompleted != null)
                  _buildStatItem(
                    context,
                    Icons.check_circle,
                    'Completed',
                    DateFormat('MMM dd, yyyy').format(project.dateCompleted!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}