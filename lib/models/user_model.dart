import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({required this.name, required this.phone});

  Map<String, dynamic> toMap() => {'name': name, 'phone': phone};

  factory EmergencyContact.fromMap(Map<String, dynamic> map) =>
      EmergencyContact(
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
      );
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String district;
  final String role; // "user" or "admin"
  final List<EmergencyContact> emergencyContacts;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.district,
    this.role = 'user',
    this.emergencyContacts = const [],
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'district': district,
        'role': role,
        'emergencyContacts':
            emergencyContacts.map((c) => c.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        district: map['district'] ?? '',
        role: map['role'] ?? 'user',
        emergencyContacts: (map['emergencyContacts'] as List<dynamic>? ?? [])
            .map((e) => EmergencyContact.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      );
}