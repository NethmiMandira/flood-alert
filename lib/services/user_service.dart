import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Update the editable profile fields in one write
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String district,
    required List<EmergencyContact> contacts,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name.trim(),
      'district': district,
      'emergencyContacts': contacts.map((c) => c.toMap()).toList(),
    });
  }
}