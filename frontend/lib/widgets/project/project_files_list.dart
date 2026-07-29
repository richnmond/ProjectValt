// lib/widgets/project/project_files_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';

class ProjectFilesList extends StatefulWidget {
  final String projectId;
  final List<ProjectFile> files;
  final VoidCallback onUpload;

  const ProjectFilesList({
    super.key,
    required this.projectId,
    required this.files,
    required this.onUpload,
  });

  @override
  State<ProjectFilesList> createState() => _ProjectFilesListState();
}

class _ProjectFilesListState extends State<ProjectFilesList> {
  String _filter = 'All';
  String _sortBy = 'Date';
  final List<String> _filterOptions = ['All', 'PDF', 'Images', 'Videos', 'Documents', 'ZIP'];
  final List<String> _sortOptions = ['Date', 'Name', 'Size', 'Type'];

  @override
  Widget build(BuildContext context) {
    final filteredFiles = _getFilteredFiles();
    final sortedFiles = _getSortedFiles(filteredFiles);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Controls
        if (widget.files.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filter,
                  items: _filterOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filter = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // File List
        sortedFiles.isEmpty
            ? Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.files.isEmpty ? 'No files uploaded yet' : 'No files match the filter',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: widget.onUpload,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Files'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedFiles.length,
                itemBuilder: (context, index) {
                  final file = sortedFiles[index];
                  return _buildFileItem(context, file);
                },
              ),
      ],
    );
  }

  Widget _buildFileItem(BuildContext context, ProjectFile file) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            file.icon,
            color: theme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          file.originalName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${file.formattedSize} • ${DateFormat('MMM dd, yyyy').format(file.uploadedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download_outlined, size: 20),
              onPressed: () {
                // Download file
              },
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                _confirmDelete(context, file);
              },
              tooltip: 'Delete',
              color: Colors.red,
            ),
          ],
        ),
        onTap: () {
          // Preview file
          _previewFile(context, file);
        },
      ),
    );
  }

  List<ProjectFile> _getFilteredFiles() {
    if (_filter == 'All') return widget.files;

    return widget.files.where((file) {
      final type = file.fileType.toLowerCase();
      switch (_filter) {
        case 'PDF':
          return type.contains('pdf');
        case 'Images':
          return type.contains('image');
        case 'Videos':
          return type.contains('video');
        case 'Documents':
          return type.contains('text') ||
              type.contains('word') ||
              type.contains('document');
        case 'ZIP':
          return type.contains('zip') || type.contains('rar');
        default:
          return true;
      }
    }).toList();
  }

  List<ProjectFile> _getSortedFiles(List<ProjectFile> files) {
    final sorted = List<ProjectFile>.from(files);

    switch (_sortBy) {
      case 'Name':
        sorted.sort((a, b) => a.originalName.compareTo(b.originalName));
        break;
      case 'Size':
        sorted.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
      case 'Type':
        sorted.sort((a, b) => a.fileType.compareTo(b.fileType));
        break;
      case 'Date':
      default:
        sorted.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        break;
    }

    return sorted;
  }

  void _confirmDelete(BuildContext context, ProjectFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.originalName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete file implementation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${file.originalName}'),
                  backgroundColor: Colors.green,
                ),
              );
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

  void _previewFile(BuildContext context, ProjectFile file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      file.originalName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              // File preview placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        file.icon,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        file.originalName,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        file.formattedSize,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Download file
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}