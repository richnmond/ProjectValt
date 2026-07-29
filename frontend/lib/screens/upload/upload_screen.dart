// frontend/lib/screens/upload/upload_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:projectvault/providers/upload_provider.dart';
import 'package:projectvault/widgets/upload_file_card.dart';

class UploadScreen extends StatefulWidget {
  final String projectId;
  
  const UploadScreen({super.key, required this.projectId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late DropzoneViewController _dropzoneController;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Files'),
        actions: [
          if (uploadProvider.files.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: uploadProvider.isUploading ? null : () {
                _uploadFiles();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Dropzone area
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isDragging 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                color: _isDragging 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.grey[50],
              ),
              child: Stack(
                children: [
                  DropzoneView(
                    operation: DragOperation.copy,
                    onCreated: (controller) {
                      _dropzoneController = controller;
                    },
                    onDropFile: (file) async {
                      final fileData = await _dropzoneController.getFileData(file);
                      final filename = await _dropzoneController.getFilename(file);
                      final mimeType = await _dropzoneController.getFileMIME(file);
                      if (mounted) {
                        uploadProvider.addFile(
                          name: filename,
                          size: fileData.length,
                          mimeType: mimeType,
                          data: fileData,
                        );
                        setState(() => _isDragging = false);
                      }
                    },
                    onHover: () {
                      if (!_isDragging) {
                        setState(() => _isDragging = true);
                      }
                    },
                    onLeave: () {
                      if (_isDragging) {
                        setState(() => _isDragging = false);
                      }
                    },
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 64,
                          color: _isDragging 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Drag & drop files here',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'or',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Browse Files'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Supported: PDF, ZIP, Images, Videos, Documents',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Max size: 100MB per file',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Upload list
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Files to upload (${uploadProvider.files.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: uploadProvider.files.isEmpty
                      ? Center(
                          child: Text(
                            'No files selected',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: uploadProvider.files.length,
                          itemBuilder: (context, index) {
                            final file = uploadProvider.files[index];
                            return UploadFileCard(
                              file: file,
                              onRemove: () {
                                uploadProvider.removeFile(index);
                              },
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),
          
          // Upload progress
          if (uploadProvider.isUploading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: uploadProvider.uploadProgress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploading... ${uploadProvider.uploadProgress.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'zip', 'png', 'jpg', 'jpeg', 'gif', 
        'mp4', 'webm', 'txt', 'doc', 'docx'
      ],
    );
    
    if (result != null && mounted) {
      final uploadProvider = context.read<UploadProvider>();
      for (var file in result.files) {
        Uint8List? fileBytes = file.bytes;
        if (fileBytes == null && file.path != null) {
          fileBytes = await File(file.path!).readAsBytes();
        }
        if (fileBytes != null) {
          uploadProvider.addFile(
            name: file.name,
            size: file.size,
            mimeType: file.extension ?? 'unknown',
            data: fileBytes,
          );
        }
      }
    }
  }

  Future<void> _uploadFiles() async {
    final uploadProvider = context.read<UploadProvider>();
    final success = await uploadProvider.uploadFiles(widget.projectId);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Files uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadProvider.error ?? 'Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}