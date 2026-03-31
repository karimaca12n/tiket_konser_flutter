import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? token;
  final String? avatar; 

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String avatarName = json['avatar'] ?? '';
    String fullAvatarUrl = avatarName;
    
    // Gunakan host yang dinamis agar tampil di Web maupun Emulator
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    
    if (avatarName.isNotEmpty && !avatarName.startsWith('http')) {
      fullAvatarUrl = 'http://$host:8081/uploads/profile/$avatarName';
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['nama'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'],
      avatar: fullAvatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': name,
      'email': email,
      'role': role,
      'token': token,
      'avatar': avatar,
    };
  }
}
