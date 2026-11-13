import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static const _prefKey = 'subscribed_topic';

  // "Nuwara Eliya" -> "district_nuwara_eliya"
  // Topic names cannot contain spaces
  static String topicFor(String district) =>
      'district_${district.toLowerCase().replaceAll(' ', '_')}';

  // Messages that arrive while the app is open
  Stream<RemoteMessage> get foregroundMessages => FirebaseMessaging.onMessage;

  // Ask the user for notification permission (Android 13+ and iOS)
  Future<bool> requestPermission() async {
    final settings = await _fcm.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // Save this device's FCM token on the user's profile
  Future<void> saveToken(String uid) async {
    final token = await _fcm.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'fcmToken': token});
  }

  // Subscribe to the user's district topic.
  // If the district changed, unsubscribe from the old topic first.
  Future<void> syncDistrict({
    required String uid,
    required String district,
  }) async {
    // 1. Save the token first. It does not depend on the permission.
    try {
      await saveToken(uid);
      debugPrint('FCM token saved');
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }

    // 2. Ask for permission and subscribe to the district topic
    try {
      final granted = await requestPermission();
      debugPrint('Notification permission granted: $granted');
      if (!granted) return;

      final prefs = await SharedPreferences.getInstance();
      final newTopic = topicFor(district);
      final oldTopic = prefs.getString(_prefKey);
      if (oldTopic == newTopic) return;

      if (oldTopic != null) await _fcm.unsubscribeFromTopic(oldTopic);
      await _fcm.subscribeToTopic(newTopic);
      await prefs.setString(_prefKey, newTopic);
      debugPrint('Subscribed to topic: $newTopic');
    } catch (e) {
      debugPrint('Topic subscribe failed: $e');
    }
  }

  // Called on logout so the next user on this phone does not get these alerts
  Future<void> unsubscribe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final topic = prefs.getString(_prefKey);
      if (topic != null) {
        await _fcm.unsubscribeFromTopic(topic);
        await prefs.remove(_prefKey);
      }
    } catch (e) {
      debugPrint('Unsubscribe failed: $e');
    }
  }
}