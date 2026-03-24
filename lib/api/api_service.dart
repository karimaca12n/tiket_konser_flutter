import 'package:dio/dio.dart';

class ApiService {
  // Base URL diatur ke root API agar bisa mengakses /login dan /konser
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8081/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      // Content-Type dihapus agar Dio bisa handle Multipart/form-data secara otomatis
    },
  ));

  Dio get dio => _dio;

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
}
