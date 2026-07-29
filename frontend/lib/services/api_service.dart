// frontend/lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projectvault/providers/upload_provider.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String baseUrl = 'http://localhost:5000/api';
  
  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, clear storage
          await _secureStorage.delete(key: 'auth_token');
        }
        return handler.next(error);
      },
    ));
  }
  
  // Auth endpoints
  Future<dynamic> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> verifyEmail(String token) async {
    try {
      final response = await _dio.post('/auth/verify-email', data: {
        'token': token,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/profile', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Project endpoints
  Future<dynamic> getProjects({
    String? search,
    String? category,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null) query['search'] = search;
      if (category != null) query['category'] = category;
      if (status != null) query['status'] = status;
      
      final response = await _dio.get('/projects', queryParameters: query);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> getProjectById(String id) async {
    try {
      final response = await _dio.get('/projects/$id');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> createProject(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/projects', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/projects/$id', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> deleteProject(String id) async {
    try {
      final response = await _dio.delete('/projects/$id');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> archiveProject(String id) async {
    try {
      final response = await _dio.post('/projects/$id/archive');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> getProjectStats() async {
    try {
      final response = await _dio.get('/projects/stats');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // File endpoints
  Future<dynamic> uploadFiles(String projectId, List<UploadFile> files) async {
    try {
      final formData = FormData();
      
      for (var file in files) {
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromBytes(
              file.data,
              filename: file.name,
              contentType: DioMediaType.parse(file.mimeType),
            ),
          ),
        );
      }
      
      final response = await _dio.post(
        '/files/$projectId/upload',
        data: formData,
        onSendProgress: (sent, total) {
          // Progress tracking
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> getFiles(String projectId) async {
    try {
      final response = await _dio.get('/files/$projectId/files');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> deleteFile(String projectId, String fileId) async {
    try {
      final response = await _dio.delete('/files/$projectId/files/$fileId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> downloadFile(String projectId, String fileId) async {
    try {
      final response = await _dio.get(
        '/files/$projectId/files/$fileId/download',
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Server error: ${error.response?.statusCode}';
      }
      return error.message ?? 'Network error';
    }
    return error.toString();
  }
}