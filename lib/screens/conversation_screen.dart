import 'package:chat_ai/models/conversation/conversation_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Message/message_model.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key? key, required this.conversation})
      : super(key: key);

  final Conversation conversation;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Message> messages = []; // Initialize with existing messages if any

  @override
  void initState() {
    super.initState();
    // Initialize the local messages list with the initial messages from the conversation
    messages = List.from(widget.conversation.messages);
    _loadMessages();

  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('messages_${widget.conversation.id}');

    if (messagesJson != null && messagesJson.isNotEmpty) {
      List<dynamic> messagesData = jsonDecode(messagesJson);
      setState(() {
        messages = messagesData.map((data) => Message.fromJson(data)).toList();
      });
    }
  }

  Future<void> _saveConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String conversationsJson = jsonEncode(
      widget.conversation.toJson(), // Assuming toJson is defined in Conversation
    );
    await prefs.setString('conversations', conversationsJson);
  }

  // Function to send message to AI
  void _sendMessageToAI(String message) {
    // Add the user's message to the current conversation
    setState(() {
      widget.conversation.messages.add(Message(text: message, isUser: true));
      messages = List.from(widget.conversation.messages);
    });

    // Call the OpenAI API or any other AI service to get a response
    // Replace this with the actual code to send a request to OpenAI
    // and handle the response
    String aiResponse = 'AI response goes here';

    // Add the AI's response to the current conversation
    setState(() {
      widget.conversation.messages.add(Message(text: aiResponse, isUser: false));
      messages = List.from(widget.conversation.messages);
    });

    // Save conversations locally
    _saveConversations();

    // Clear the input field
    _messageController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.id),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.conversation.messages[index].text),
                  subtitle: Text(widget.conversation.messages[index].isUser ? 'User' : 'AI'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Call a function to send message to AI
                    _sendMessageToAI(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
