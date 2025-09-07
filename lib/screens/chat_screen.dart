import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage.isNotEmpty) {
      _messages.add(Message(widget.initialMessage, true));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
      _sendToGemini(widget.initialMessage);
    }
  }

  Future<void> _sendToGemini(String userText) async {
    setState(() => _isLoading = true);

    try {
      final reply =
          await _geminiService.chat(userText, AppLocalizations.of(context)!);
      setState(() => _messages.add(Message(reply, false)));
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() =>
          _messages.add(Message(AppLocalizations.of(context)!.errorWithMessage(e.toString()), false)));
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _sendToGemini(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
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
              controller: _scrollCtrl,
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
