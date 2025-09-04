import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  final String initialMessage;
  const ChatScreen({super.key, required this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool fromUser;
  Message(this.text, this.fromUser);
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage.isNotEmpty) {
      _messages.add(Message(widget.initialMessage, true));
      _sendToGemini(widget.initialMessage);
    }
  }

  Future<void> _sendToGemini(String userText) async {
    setState(() => _isLoading = true);

    try {
      final reply = await _geminiService.chat(userText);
      setState(() => _messages.add(Message(reply, false)));
    } catch (e) {
      setState(() => _messages.add(Message("Lỗi: $e", false)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(Message(text, true));
      _controller.clear();
    });
    _sendToGemini(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Container(
                  alignment: msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg.fromUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Gửi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
