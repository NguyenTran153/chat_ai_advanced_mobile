import 'package:chat_ai/models/conversation/conversation_model.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/Message/message_model.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key? key, required this.conversation})
      : super(key: key);

  final Conversation conversation;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = []; // Initialize with existing messages if any
  // late OpenAI? chatGPT;

  @override
  void initState() {
    super.initState();
    // Initialize the local messages list with the initial messages from the conversation
    messages = List.from(widget.conversation.messages);
    _loadMessages();
    // chatGPT = OpenAI.instance.build(
    //     token: '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',
    //     baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 2)),enableLog: true,
    // );
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson =
        prefs.getString('messages_${widget.conversation.id}');

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
      widget.conversation
          .toJson(), // Assuming toJson is defined in Conversation
    );
    await prefs.setString('conversations', conversationsJson);

    String messagesJson = jsonEncode(messages.map((message) => message.toJson()).toList());
    await prefs.setString('messages_${widget.conversation.id}', messagesJson);
  }

  // Function to send message to AI
  Future<void> _sendMessageToAI(String message) async {
    // Tạo một tin nhắn mới từ người dùng
    Message userMessage = Message(text: message, isUser: true);

    // Thêm tin nhắn của người dùng vào danh sách tin nhắn
    setState(() {
      widget.conversation.messages.add(userMessage);
      messages = List.from(widget.conversation.messages);
    });

    try {
      // Gọi API OpenAI để nhận phản hồi
      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization':
          'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages.map((message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          }).toList(),
          'max_tokens': 3000,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String aiResponse = responseData['choices'][0]['message']['content'];

        _saveConversations();

        setState(() {
          widget.conversation.messages.add(Message(text: aiResponse, isUser: false));
          messages = List.from(widget.conversation.messages);
        });

        _messageController.clear();
      } else {
        String aiResponse = 'Error: ${response.statusCode}, ${response.body}';
        _saveConversations();

        setState(() {
          widget.conversation.messages.add(Message(text: aiResponse, isUser: false));
          messages = List.from(widget.conversation.messages);
        });

        _messageController.clear();
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      String aiResponse = 'Error calling API: $e';
      _saveConversations();

      setState(() {
        widget.conversation.messages.add(Message(text: aiResponse, isUser: false));
        messages = List.from(widget.conversation.messages);
      });

      _messageController.clear();
      print('Error calling API: $e');
    }
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
                if (index < messages.length) {
                  final message = messages[index];
                  return ListTile(
                    title: Text(
                      message.text,
                      textAlign:
                          message.isUser ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        color: message.isUser ? Colors.blue : Colors.black,
                      ),
                    ),
                    // Adjust alignment based on the sender
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: message.isUser ? 20.0 : 8.0,
                    ),
                    trailing: message.isUser
                        ? const Icon(Icons.person)
                        : null, // Add a trailing icon for User messages
                    leading:
                        message.isUser ? null : const Icon(Icons.android), //
                    // Add other styling as needed
                  );
                } else {
                  // Handle the case when the index is out of bounds
                  return const SizedBox.shrink();
                }
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
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    // Call a function to send message to AI
                    await _sendMessageToAI(_messageController.text);
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
