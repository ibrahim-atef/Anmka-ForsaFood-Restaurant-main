// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:restaurant/constant/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant/models/notification_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class SendNotification {
  static final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  static Future<String> _loadFcmKeyFile() async {
    try {
      // Try to load from local asset file first
      final String jsonString = await rootBundle.loadString(
        'assets/fcmkeyfile/forsa-food-b6b50-firebase-adminsdk-fbsvc-32809c880a.json'
      );
      return jsonString;
    } catch (e) {
      debugPrint("Error loading local FCM key file: $e");
      // Fallback to URL if local file not found
      if (Constant.jsonNotificationFileURL.isNotEmpty) {
        final response = await http.get(Uri.parse(Constant.jsonNotificationFileURL.toString()));
        return response.body;
      }
      throw Exception("FCM key file not found locally and URL not configured");
    }
  }

  static Future<String> getAccessToken() async {
    Map<String, dynamic> jsonData = {};

    try {
      final jsonString = await _loadFcmKeyFile();
      jsonData = json.decode(jsonString);
    } catch (e) {
      debugPrint("Error loading FCM credentials: $e");
      rethrow;
    }
    
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonData);
    final client = await clientViaServiceAccount(serviceAccountCredentials, _scopes);
    return client.credentials.accessToken.data;
  }

  static Future<bool> sendFcmMessage(String type, String token, Map<String, dynamic>? payload) async {
    print(type);
    try {
      final String accessToken = await getAccessToken();
      debugPrint("accessToken=======>");
      debugPrint(accessToken);
      NotificationModel? notificationModel = await FireStoreUtils.getNotificationContent(type);

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {'body': notificationModel!.message ?? '', 'title': notificationModel.subject ?? ''},
              'data': payload,
            }
          },
        ),
      );

      debugPrint("Notification=======>");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static sendOneNotification({required String token, required String title, required String body, required Map<String, dynamic> payload}) async {
    try {
      final String accessToken = await getAccessToken();
      debugPrint("accessToken=======>");
      debugPrint(accessToken);

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {'body': body, 'title': title},
              'data': payload,
            }
          },
        ),
      );

      debugPrint("Notification=======>");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> sendChatFcmMessage(String title, String message, String token, Map<String, dynamic>? payload) async {
    try {
      final String accessToken = await getAccessToken();
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {'body': message, 'title': title},
              'data': payload,
            }
          },
        ),
      );
      debugPrint("Notification=======>");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
