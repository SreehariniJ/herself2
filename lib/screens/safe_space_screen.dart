import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/herself_core.dart';
import '../logic/gemini_chatbot_logic.dart';

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
  late GeminiChatbotLogic _chatbotLogic;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<UserState>(context, listen: false);
      _chatbotLogic = GeminiChatbotLogic(state);
      _addBotMessage(
        "Hi ${state.name}, I'm here for you. How are you feeling today?",
      );
    });
  }

  void _addBotMessage(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _handleSend([String? text]) {
    final userText = text ?? _controller.text.trim();
    if (userText.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Call Gemini API
    _chatbotLogic.getResponse(userText).then((response) {
      if (mounted) {
        _addBotMessage(response);
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildQuickReply(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text),
        backgroundColor: Colors.teal.shade50,
        labelStyle: TextStyle(color: Colors.teal.shade800),
        onPressed: () => _handleSend(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 16,
              child: Icon(Icons.spa, size: 20, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('AI Therapist', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: const [],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 12),
                          child: Row(
                            children: [
                              Text(
                                "Thinking...",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isUser = msg.isUser;
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.teal : Colors.grey.shade100,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isUser
                                  ? const Radius.circular(20)
                                  : const Radius.circular(0),
                              bottomRight: isUser
                                  ? const Radius.circular(0)
                                  : const Radius.circular(20),
                            ),
                            boxShadow: [
                              if (!isUser)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Quick Replies
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickReply("I feel overwhelmed"),
                _buildQuickReply("I need advice"),
                _buildQuickReply("Cheer me up"),
                _buildQuickReply("Just chatting"),
              ],
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your thoughts...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _handleSend(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
