import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../data/gemini_service.dart';

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
      _messages.insert(0, Message(widget.initialMessage, true));
      _sendToGemini(widget.initialMessage);
    }
  }

  Future<void> _sendToGemini(String userText) async {
    setState(() => _isLoading = true);

    try {
      final reply =
          await _geminiService.chat(userText, AppLocalizations.of(context)!);
      setState(() => _messages.insert(0, Message(reply, false)));
    } catch (e) {
      setState(() => _messages.insert(
          0, Message(AppLocalizations.of(context)!.errorWithMessage(e.toString()), false)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(0, Message(text, true));
      _controller.clear();
    });
    _sendToGemini(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.chatAI)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Container(
                  alignment: msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg.fromUser
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
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
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterMessage,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: AppLocalizations.of(context)!.send,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text(AppLocalizations.of(context)!.send),
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
