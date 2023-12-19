import 'package:chat_ai/models/conversation/conversation_model.dart';
import 'package:flutter/material.dart';

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

  // Function to send message to AI
  void _sendMessageToAI(String message) {
    // Add the user's message to the conversation
    setState(() {
      messages.add(Message(text: message, isUser: true));
    });

    // Call the OpenAI API or any other AI service to get a response
    // Replace this with the actual code to send a request to OpenAI
    // and handle the response
    String aiResponse = 'AI response goes here';

    // Add the AI's response to the conversation
    setState(() {
      messages.add(Message(text: aiResponse, isUser: false));
    });

    // Clear the input field
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index].text),
                  subtitle: Text(messages[index].isUser ? 'User' : 'AI'),
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
