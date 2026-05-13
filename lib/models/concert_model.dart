class ConcertModel {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String? description;
  final String image;
  final double price;
  final int? jumlahBed;

  ConcertModel({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    this.description,
    required this.image,
    required this.price,
    this.jumlahBed,
  });

  ConcertModel copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? location,
    String? description,
    String? image,
    double? price,
    int? jumlahBed,
  }) {
    return ConcertModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      jumlahBed: jumlahBed ?? this.jumlahBed,
    );
  }

  factory ConcertModel.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    String imageName = json['gambar'] ?? '';
    String fullImageUrl = '';
    
    if (imageName.isNotEmpty) {
      if (imageName.startsWith('http')) {
        fullImageUrl = imageName;
      } else {
        // Gunakan localhost sesuai konfigurasi API Anda
        fullImageUrl = 'http://localhost:8081/image/$imageName';
      }
    } else {
      // URL placeholder jika gambar kosong agar tidak error
      fullImageUrl = 'https://via.placeholder.com/150';
    }

    return ConcertModel(
      id: json['id']?.toString() ?? '',
      name: json['name_konser'] ?? '',
      date: json['tanggal'] != null ? DateTime.parse(json['tanggal']) : DateTime.now(),
      location: json['lokasi'] ?? '',
      // PERBAIKAN: Pastikan menggunakan key yang benar dari DB (description atau deskripsi)
      description: json['description'] ?? json['deskripsi'],
      image: fullImageUrl,
      price: parsePrice(json['harga']),
      jumlahBed: json['jumlah_bed'] != null ? int.tryParse(json['jumlah_bed'].toString()) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_konser': name,
      'tanggal': date.toIso8601String().split('T')[0],
      'lokasi': location,
      'harga': price,
      'gambar': image,
      'jumlah_bed': jumlahBed,
      'description': description,
    };
  }
}
