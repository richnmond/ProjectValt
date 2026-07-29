// lib/widgets/upload_file_card.dart
import 'package:flutter/material.dart';
import '../providers/upload_provider.dart';

class UploadFileCard extends StatelessWidget {
  final UploadFile file;
  final VoidCallback onRemove;

  const UploadFileCard({
    super.key,
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileSize = _formatFileSize(file.size);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // File Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(file.mimeType),
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // File Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fileSize,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onRemove,
              color: Colors.grey[600],
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String mimeType) {
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('zip') || mimeType.contains('rar')) return Icons.folder_zip;
    if (mimeType.contains('image')) return Icons.image;
    if (mimeType.contains('video')) return Icons.video_library;
    if (mimeType.contains('text') || mimeType.contains('plain')) return Icons.text_fields;
    if (mimeType.contains('word') || mimeType.contains('document')) return Icons.description;
    if (mimeType.contains('excel') || mimeType.contains('sheet')) return Icons.table_chart;
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) {
      return Icons.slideshow;
    }
    return Icons.attach_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}