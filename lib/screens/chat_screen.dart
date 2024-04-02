import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../data/config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GenerativeModel _model;
  late ChatSession _chatSession;
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GenAIConfig.apiKey,
    );
    _startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                var item = _chatSession.history.toList()[index];
                if (item.parts.any((e) => e is TextPart)) {
                  var textParts = item.parts.where((e) => e is TextPart);
                  return Text(
                    textParts.fold(
                        "",
                        (String previousValue, Part element) =>
                            previousValue + (element as TextPart).text),
                  );
                } else {
                  return const SizedBox();
                }
              },
              itemCount: _chatSession.history.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter prompt here',
              ),
            ),
          ),
          SafeArea(
            child: OutlinedButton(
              onPressed: _generate,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Send',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startChat() {
    _chatSession = _model.startChat();
  }

  void _generate() async {
    var prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final content = Content.text(prompt);

    await _chatSession.sendMessage(content);
    setState(() {});
  }
}
