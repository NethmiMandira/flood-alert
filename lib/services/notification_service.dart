import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static const _topicsKey = 'subscribed_topics';
  // Older versions of the app stored a single topic under this key
  static const _legacyTopicKey = 'subscribed_topic';

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
    // ignore: deprecated_member_use
    final token = await _fcm.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'fcmToken': token});
  }

  // Make the device's topic subscriptions match the user's home district
  // plus any extra districts they chose to follow.
  Future<void> syncTopics({
    required String uid,
    required String district,
    required List<String> watchedDistricts,
  }) async {
    // 1. Save the token first. It does not depend on the permission.
    try {
      await saveToken(uid);
      debugPrint('FCM token saved');
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }

    // 2. Ask for permission and update the topic subscriptions
    try {
      final granted = await requestPermission();
      debugPrint('Notification permission granted: $granted');
      if (!granted) return;

      final prefs = await SharedPreferences.getInstance();

      // Topics the user should be subscribed to now
      final wanted = <String>{
        topicFor(district),
        for (final d in watchedDistricts) topicFor(d),
      };

      // Topics this device is subscribed to already
      final current = <String>{...(prefs.getStringList(_topicsKey) ?? [])};
      final legacy = prefs.getString(_legacyTopicKey);
      if (legacy != null) current.add(legacy);

      // Unsubscribe from removed topics, subscribe to new ones
      for (final topic in current.difference(wanted)) {
        await _fcm.unsubscribeFromTopic(topic);
      }
      for (final topic in wanted.difference(current)) {
        await _fcm.subscribeToTopic(topic);
      }

      await prefs.setStringList(_topicsKey, wanted.toList());
      await prefs.remove(_legacyTopicKey);
      debugPrint('Subscribed topics: $wanted');
    } catch (e) {
      // Notifications are optional, so never crash the app because of them
      debugPrint('Topic sync failed: $e');
    }
  }

  // Called on logout so the next user on this phone does not get these alerts
  Future<void> unsubscribe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final topics = <String>{...(prefs.getStringList(_topicsKey) ?? [])};
      final legacy = prefs.getString(_legacyTopicKey);
      if (legacy != null) topics.add(legacy);

      for (final topic in topics) {
        await _fcm.unsubscribeFromTopic(topic);
      }
      await prefs.remove(_topicsKey);
      await prefs.remove(_legacyTopicKey);
    } catch (e) {
      debugPrint('Unsubscribe failed: $e');
    }
  }
}