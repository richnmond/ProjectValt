// frontend/lib/providers/project_provider.dart
import 'package:flutter/material.dart';
import 'package:projectvault/models/project_model.dart';
import 'package:projectvault/services/api_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Project> _projects = [];
  Project? _currentProject;
  bool _isLoading = false;
  String? _error;
  
  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadProjects({
    String? search,
    String? category,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.getProjects(
        search: search,
        category: category,
        status: status,
        page: page,
        limit: limit,
      );
      
      if (response['success']) {
        _projects = (response['data'] as List)
            .map((json) => Project.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Failed to load projects';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getProjectById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.getProjectById(id);
      
      if (response['success']) {
        _currentProject = Project.fromJson(response['data']);
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Project not found';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Project?> createProject(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.createProject(data);
      
      if (response['success']) {
        final project = Project.fromJson(response['data']);
        _projects.insert(0, project);
        notifyListeners();
        return project;
      } else {
        _error = response['message'] ?? 'Failed to create project';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateProject(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.updateProject(id, data);
      
      if (response['success']) {
        final updatedProject = Project.fromJson(response['data']);
        final index = _projects.indexWhere((p) => p.id == id);
        if (index != -1) {
          _projects[index] = updatedProject;
        }
        if (_currentProject?.id == id) {
          _currentProject = updatedProject;
        }
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update project';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteProject(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.deleteProject(id);
      
      if (response['success']) {
        _projects.removeWhere((p) => p.id == id);
        if (_currentProject?.id == id) {
          _currentProject = null;
        }
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete project';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> archiveProject(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.archiveProject(id);
      
      if (response['success']) {
        final archivedProject = Project.fromJson(response['data']);
        final index = _projects.indexWhere((p) => p.id == id);
        if (index != -1) {
          _projects[index] = archivedProject;
        }
        if (_currentProject?.id == id) {
          _currentProject = archivedProject;
        }
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to archive project';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.getProjectStats();
      if (response['success']) {
        return response['data'];
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  void clearCurrentProject() {
    _currentProject = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}