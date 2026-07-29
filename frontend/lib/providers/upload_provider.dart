// frontend/lib/providers/upload_provider.dart
import 'package:flutter/material.dart';
import 'package:projectvault/services/api_service.dart';
import 'dart:typed_data';

class UploadFile {
  final String name;
  final int size;
  final String mimeType;
  final Uint8List data;
  String? downloadUrl;
  
  UploadFile({
    required this.name,
    required this.size,
    required this.mimeType,
    required this.data,
    this.downloadUrl,
  });
}

class UploadProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<UploadFile> _files = [];
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _error;
  
  List<UploadFile> get files => _files;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;
  
  void addFile({
    required String name,
    required int size,
    required String mimeType,
    required Uint8List data,
  }) {
    _files.add(UploadFile(
      name: name,
      size: size,
      mimeType: mimeType,
      data: data,
    ));
    notifyListeners();
  }
  
  void removeFile(int index) {
    _files.removeAt(index);
    notifyListeners();
  }
  
  void clearFiles() {
    _files.clear();
    _uploadProgress = 0;
    notifyListeners();
  }
  
  Future<bool> uploadFiles(String projectId) async {
    if (_files.isEmpty) return false;
    
    try {
      _isUploading = true;
      _error = null;
      _uploadProgress = 0;
      notifyListeners();
      
      final formData = await _apiService.uploadFiles(projectId, _files);
      
      // Simulate progress updates
      for (var i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        _uploadProgress = i.toDouble();
        notifyListeners();
      }
      
      _uploadProgress = 100;
      _isUploading = false;
      _files.clear();
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}