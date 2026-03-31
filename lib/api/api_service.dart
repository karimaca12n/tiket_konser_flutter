import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class ApiService {
  // Fungsi untuk mendapatkan IP yang tepat berdasarkan platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081/api/';
    } else {
      // Jika di Android Emulator, gunakan 10.0.2.2
      return 'http://10.0.2.2:8081/api/';
    }
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
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
