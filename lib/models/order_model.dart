import 'package:tiket_konser/models/concert_model.dart';
import 'package:tiket_konser/models/user_model.dart';

class OrderModel {
  final String id;
  final String concertId;
  final String userId;
  final String status;
  final ConcertModel? concert;
  final UserModel? user;
  final DateTime createdAt;
  final int jumlahTiket;
  final double totalHarga;

  OrderModel({
    required this.id,
    required this.concertId,
    required this.userId,
    required this.status,
    this.concert,
    this.user,
    required this.createdAt,
    required this.jumlahTiket,
    required this.totalHarga,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Sesuaikan mapping dengan kolom hasil JOIN di CI4
    return OrderModel(
      id: json['id']?.toString() ?? '',
      concertId: json['konser_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      jumlahTiket: int.tryParse(json['jumlah_tiket']?.toString() ?? '1') ?? 1,
      totalHarga: double.tryParse(json['total_harga']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      concert: json['name_konser'] != null ? ConcertModel(
        id: json['konser_id']?.toString() ?? '',
        name: json['name_konser'] ?? '',
        location: json['lokasi'] ?? '',
        date: json['tanggal'] != null ? DateTime.parse(json['tanggal']) : DateTime.now(),
        image: json['gambar'] ?? '',
        price: double.tryParse(json['total_harga']?.toString() ?? '0') ?? 0,
      ) : null,
      user: json['nama_user'] != null ? UserModel(
        id: json['user_id']?.toString() ?? '',
        name: json['nama_user'] ?? '',
        email: '',
        role: 'user',
      ) : null,
    );
  }
}
