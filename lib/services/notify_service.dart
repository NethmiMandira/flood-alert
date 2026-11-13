import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Asks the Vercel API to send a push notification for a new report
class NotifyService {
  static const _baseUrl = 'https://flood-alert-api.vercel.app';

  // Never throws: the report is already saved, so a failed notification
  // must not break the reporting flow.
  Future<void> notifyReport(String reportId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // The server uses this token to verify who is calling
      final idToken = await user.getIdToken();

      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/notify'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({'reportId': reportId}),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('Notify response: ${res.statusCode} ${res.body}');
    } catch (e) {
      debugPrint('Notify failed: $e');
    }
  }
}