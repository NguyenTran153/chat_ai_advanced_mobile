import 'package:flutter/material.dart';

import '../../models/conversation/conversation_model.dart';
import '../conversation_screen.dart';

class ConversationCard extends StatelessWidget {
  const ConversationCard({Key? key, required this.conversation}) : super(key: key);

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              conversation: conversation,
            ),
          ),
        );
      },
    );
  }
}
