import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../data/config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GenerativeModel _model;
  late ChatSession _chatSession;
  late Channel channel;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GenAIConfig.geminiApiKey,
    );
    channel = StreamChat.of(context).client.channel(
      'messaging',
      id: 'flutter_chat_ai_gen_1',
    )..watch();
    _startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: StreamChannel(
        channel: channel,
        child: _ChannelPage(
          onMessageSent: _generate,
        ),
      ),
    );
  }

  void _startChat() {
    _chatSession = _model.startChat();
  }

  void _generate(Message message) async {
    var prompt = message.text!;
    if (prompt.isEmpty) return;

    final content = Content.text(prompt);

    var response = await _chatSession.sendMessage(content);
    channel.sendMessage(
      Message(
        text: response.text,
        extraData: const {
          'isGeminiMessage': true,
        },
      ),
    );
    setState(() {});
  }
}

/// Displays the list of messages inside the channel
class _ChannelPage extends StatelessWidget {
  final ValueChanged<Message> onMessageSent;

  const _ChannelPage({
    super.key,
    required this.onMessageSent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StreamChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              messageBuilder: (context, details, list, def) {
                return def.copyWith(
                  reverse: !(details.message.extraData['isGeminiMessage'] as bool? ?? false),
                  borderRadiusGeometry: BorderRadius.all(Radius.circular(16)),
                  showUsername: false,
                  showSendingIndicator: false,
                  showTimestamp: false,
                );
              },
            ),
          ),
          StreamMessageInput(
            onMessageSent: onMessageSent,
            showCommandsButton: false,
            disableAttachments: true,
          ),
        ],
      ),
    );
  }
}
