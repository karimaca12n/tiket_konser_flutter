import 'package:flutter/material.dart';
import 'package:tiket_konser/api/api_service.dart';
import 'package:tiket_konser/models/concert_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ConcertProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ConcertModel> _concerts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ConcertModel> get concerts => _concerts.where((c) => 
    c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
    c.location.toLowerCase().contains(_searchQuery.toLowerCase())
  ).toList();
  
  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchConcerts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('konser');
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map && data.containsKey('data')) {
           data = data['data'];
        }

        _concerts = (data as List)
            .map((e) => ConcertModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Fetch concerts error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addConcert(Map<String, dynamic> data, dynamic imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> formDataMap = {
        'name_konser': data['name'], 
        'lokasi': data['location'],
        'tanggal': data['date'].toString().split(' ')[0], 
        'harga': data['price'].toString(),
        'description': data['description'], // SEKARANG DIKIRIM
        'jumlah_bed': '0',
      };

      if (imageFile != null) {
        formDataMap['gambar'] = await MultipartFile.fromBytes(
          imageFile.bytes!,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        );
      }

      FormData formData = FormData.fromMap(formDataMap);
      final response = await _apiService.dio.post('konser', data: formData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchConcerts();
        return true;
      }
    } catch (e) {
      debugPrint('Add concert error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateConcert(String id, Map<String, dynamic> data, dynamic imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> formDataMap = {
        '_method': 'PUT', 
        'name_konser': data['name'],
        'lokasi': data['location'],
        'tanggal': data['date'].toString().split(' ')[0],
        'harga': data['price'].toString(),
        'description': data['description'], // SEKARANG DIKIRIM
        'jumlah_bed': '0',
      };

      if (imageFile != null) {
        formDataMap['gambar'] = await MultipartFile.fromBytes(
          imageFile.bytes!,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        );
      }

      FormData formData = FormData.fromMap(formDataMap);
      final response = await _apiService.dio.post('konser/$id', data: formData);

      if (response.statusCode == 200) {
        await fetchConcerts();
        return true;
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint('Update error response: ${e.response?.data}');
      }
      debugPrint('Update concert error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteConcert(String id) async {
    try {
      final response = await _apiService.dio.delete('konser/$id');
      if (response.statusCode == 200) {
        _concerts.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
    return false;
  }
}
