// frontend/lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projectvault/services/api_service.dart';
import 'package:projectvault/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  
  AuthProvider() {
    loadToken();
  }
  
  Future<void> loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
    if (_token != null) {
      await getCurrentUser();
    }
    notifyListeners();
  }
  
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.register(name, email, password);
      
      if (response['success']) {
        _user = User.fromJson(response['data']['user']);
        _token = response['data']['token'];
        
        await _secureStorage.write(key: 'auth_token', value: _token);
        
        // Navigate to verify email
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Registration failed';
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
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.login(email, password);
      
      if (response['success']) {
        _user = User.fromJson(response['data']['user']);
        _token = response['data']['token'];
        
        await _secureStorage.write(key: 'auth_token', value: _token);
        
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Login failed';
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
  
  Future<void> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      
      if (response['success']) {
        _user = User.fromJson(response['data']);
        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }
  
  Future<void> logout() async {
    _user = null;
    _token = null;
    await _secureStorage.delete(key: 'auth_token');
    notifyListeners();
  }
  
  Future<void> verifyEmail(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.verifyEmail(token);
      
      if (response['success']) {
        // Email verified successfully
        if (_user != null) {
          _user = _user!.copyWith(isEmailVerified: true);
        }
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Email verification failed';
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
  
  Future<void> forgotPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.forgotPassword(email);
      
      if (!response['success']) {
        _error = response['message'] ?? 'Failed to send reset email';
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
  
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.resetPassword(token, newPassword);
      
      if (!response['success']) {
        _error = response['message'] ?? 'Password reset failed';
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
  
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.updateProfile(data);
      
      if (response['success']) {
        _user = User.fromJson(response['data']);
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Profile update failed';
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
}