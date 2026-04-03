import 'package:flutter/material.dart';
import 'package:tiket_konser/api/api_service.dart';
import 'package:tiket_konser/models/order_model.dart';
import 'package:tiket_konser/models/concert_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<OrderModel> get orders {
    final filtered = _orders.where((o) => 
      (o.concert?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
      (o.user?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
    
    filtered.sort((a, b) => b.id.compareTo(a.id));
    return filtered;
  }

  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getTicketDetails(String orderId) async {
    try {
      final response = await _apiService.dio.get('orders/cetak/$orderId');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Error getting ticket details: $e');
    }
    return null;
  }

  // DOWNLOAD TIKET PDF (Dinamis untuk Web & Android)
  Future<void> downloadTicket(String orderId) async {
    String host = 'localhost'; // Gunakan localhost untuk HP Fisik via ADB Reverse
    // URL ini akan memanggil rute: api/orders/download/ID
    final String url = 'http://$host:8081/api/orders/download/$orderId';
    final Uri uri = Uri.parse(url);
    
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
    }
  }

  Future<void> fetchUserOrders(String userId) async {
    if (userId.contains('admin')) {
      _orders = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('orders/user/$userId');
      if (response.statusCode == 200) {
        _orders = (response.data as List).map((e) => OrderModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch user orders error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('orders');
      if (response.statusCode == 200) {
        _orders = (response.data as List).map((e) => OrderModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch all orders error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder(ConcertModel concert, String userId) async {
    try {
      final response = await _apiService.dio.post('orders', data: {
        'user_id': userId,
        'konser_id': concert.id,
        'jumlah_tiket': 1,
        'total_harga': concert.price,
      });
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Create order error: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String id, String status) async {
    try {
      final response = await _apiService.dio.patch('orders/$id', data: {
        'status': status,
      });
      if (response.statusCode == 200) {
        await fetchAllOrders();
        return true;
      }
    } catch (e) {
      debugPrint('Update status error: $e');
    }
    return false;
  }
}
