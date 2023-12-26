import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/conversation/conversation_model.dart';
import 'conversation_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  List<Conversation> conversations = [];
  Conversation? selectedConversation;

  Future<void> _createNewConversation(BuildContext context) async {
    // Add logic to create a new conversation
    Conversation newConversation = Conversation(
      id: DateTime.now().toString(),
      messages: [],
    );

    // Add the new conversation to the list
    conversations.add(newConversation);

    // Save conversations locally
    await _saveConversations();

    // Set the selected conversation to the newly created one
    setState(() {
      selectedConversation = newConversation;
    });
  }

  Future<void> _saveConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String conversationsJson = jsonEncode(
      conversations.map((conversation) => conversation.toJson()).toList(),
    );
    await prefs.setString('conversations', conversationsJson);
  }

  Future<void> _loadConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? conversationsJson = prefs.getString('conversations');

    if (conversationsJson != null && conversationsJson.isNotEmpty) {
      dynamic conversationsData = jsonDecode(conversationsJson);

      if (conversationsData is List) {
        conversations = conversationsData.map((data) => Conversation.fromJson(data)).toList();
      } else if (conversationsData is Map) {
        conversations = [Conversation.fromJson(conversationsData)];
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _loadConversations().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with AI'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity, // Set
              height: 160, // the width to fill the entire space
              color: Colors.deepPurple,
              alignment: Alignment.center,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text(
                  'Chat Thread',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text('Conversation ${index + 1}'),
                      onTap: () {
                        setState(() {
                          selectedConversation = conversations[index];
                        });
                      });
                },
              ),
            ),
            Container(
              color:
                  Colors.deepPurple, // Set the background color of the button
              child: ListTile(
                title: Text(
                  'Create New Conversation',
                  style: TextStyle(color: Colors.white), // Set the text color
                ),
                onTap: () {
                  // Add logic to create a new conversation
                  _createNewConversation(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: selectedConversation != null
          ? ConversationScreen(conversation: selectedConversation!)
          : Container(
              alignment: Alignment.center,
              child: Text('No conversation selected.'),
            ),
    );
  }
}
