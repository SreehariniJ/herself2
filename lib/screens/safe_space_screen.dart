import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/herself_core.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class SafeSpaceScreen extends StatefulWidget {
  const SafeSpaceScreen({super.key});

  @override
  State<SafeSpaceScreen> createState() => _SafeSpaceScreenState();
}

class _SafeSpaceScreenState extends State<SafeSpaceScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial Greeting based on user state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<UserState>(context, listen: false);
      _addBotMessage("Hi ${state.name}, I'm here for you. I noticed you're feeling ${state.mood} today. Would you like to talk about it?");
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    
    final userText = _controller.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _controller.clear();
    });
    _scrollToBottom();

    // Simulated Therapist Logic
    Future.delayed(const Duration(seconds: 1), () {
      String response = _getTherapistResponse(userText);
      _addBotMessage(response);
    });
  }

  String _getTherapistResponse(String input) {
    input = input.toLowerCase();
    if (input.contains("sad") || input.contains("bad")) return "I'm sorry you're feeling this way. Remember that it's okay to have tough days. What's on your mind?";
    if (input.contains("stress") || input.contains("work")) return "Stress can be overwhelming. Try to take a moment for yourself. Have you tried the Box Breathing exercise earlier?";
    if (input.contains("happy") || input.contains("good")) return "That's wonderful to hear! I love seeing you in a positive space. What made your day better?";
    return "I'm listening. Tell me more about that.";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(backgroundColor: Colors.teal, radius: 15, child: Icon(Icons.spa, size: 18, color: Colors.white)),
            SizedBox(width: 10),
            Text('AI Therapist'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.teal : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: msg.isUser ? const Radius.circular(0) : const Radius.circular(20),
                        bottomLeft: msg.isUser ? const Radius.circular(20) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your thoughts...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
