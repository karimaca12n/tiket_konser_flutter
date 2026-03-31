import 'package:flutter/material.dart';
import 'package:tiket_konser/api/api_service.dart';
import 'package:tiket_konser/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _user;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  UserModel? get user => _user;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  bool get isAdmin => _user?.role == 'admin';
  bool get isAuthenticated => _user != null;

  List<UserModel> get filteredUsers {
    return _allUsers.where((u) => 
      u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      u.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('users');
      if (response.statusCode == 200) {
        _allUsers = (response.data as List).map((e) => UserModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch users error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({required String name, dynamic imageFile}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> dataMap = {
        'nama': name,
      };

      if (imageFile != null) {
        dataMap['avatar'] = await MultipartFile.fromBytes(
          imageFile.bytes!,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        );
      }

      FormData formData = FormData.fromMap(dataMap);
      final response = await _apiService.dio.post('users/${_user!.id}', data: formData);

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        if (userData != null) {
          _user = UserModel.fromJson(userData);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        _user = UserModel.fromJson(response.data);
        if (_user!.token != null) {
          _apiService.setToken(_user!.token!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint('Login API error details: ${e.response?.data}');
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    _apiService.clearToken();
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('register', data: {
        'nama': name,
        'username': email.split('@')[0],
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
