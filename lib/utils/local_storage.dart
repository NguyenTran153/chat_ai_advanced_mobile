// local_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation/conversation_model.dart';

class LocalStorage {
  static const String keyConversations = 'conversations';

  static Future<void> saveConversations(List<Conversation> conversations) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String conversationsJson = jsonEncode(conversations.map((conv) => conv.toJson()).toList());
    prefs.setString(keyConversations, conversationsJson);
  }

  static Future<List<Conversation>> getConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? conversationsJson = prefs.getString(keyConversations);

    if (conversationsJson != null) {
      List<dynamic> conversationsData = jsonDecode(conversationsJson);
      return conversationsData.map((data) => Conversation.fromJson(data)).toList();
    }

    return [];
  }
}

