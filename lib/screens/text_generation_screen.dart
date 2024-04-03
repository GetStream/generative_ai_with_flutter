import 'package:flutter/material.dart';
import 'package:generative_ai_with_flutter/data/config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class TextGenerationScreen extends StatefulWidget {
  const TextGenerationScreen({super.key});

  @override
  State<TextGenerationScreen> createState() => _TextGenerationScreenState();
}

class _TextGenerationScreenState extends State<TextGenerationScreen> {
  late GenerativeModel _model;
  late Channel channel;

  @override
  void initState() {
    super.initState();
    channel = StreamChat.of(context).client.channel(
          'messaging',
          id: 'flutter_text_ai_gen_1',
        )..watch();

    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GenAIConfig.geminiApiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Generation'),
      ),
      body: StreamChannel(
        channel: channel,
        child: _ChannelPage(
          onMessageSent: _generate,
        ),
      ),
    );
  }

  void _generate(Message message) async {
    String prompt = message.text!;
    if (prompt.isEmpty) return;

    final content = [Content.text(prompt)];

    final response = await _model.generateContent(content);
    channel.sendMessage(
      Message(
        text: response.text,
        extraData: const {
          'isGeminiMessage': true,
        },
      ),
    );
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
                  reverse:
                      !(details.message.extraData['isGeminiMessage'] as bool? ??
                          false),
                  borderRadiusGeometry: const BorderRadius.all(
                    Radius.circular(16),
                  ),
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
