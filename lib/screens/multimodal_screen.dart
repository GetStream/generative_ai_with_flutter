import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../data/config.dart';

class MultimodalScreen extends StatefulWidget {
  const MultimodalScreen({super.key});

  @override
  State<MultimodalScreen> createState() => _MultimodalScreenState();
}

class _MultimodalScreenState extends State<MultimodalScreen> {
  late GenerativeModel _model;
  late Channel channel;
  final StreamMessageInputController controller =
      StreamMessageInputController();
  List<Attachment> lastAttachments = [];

  @override
  void initState() {
    super.initState();
    channel = StreamChat.of(context).client.channel(
          'messaging',
          id: 'flutter_multimodal_ai_gen_1',
        )..watch();

    _model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: GenAIConfig.geminiApiKey,
    );
    controller.addListener(() {
      if (controller.attachments.isNotEmpty) {
        lastAttachments = controller.attachments;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multimodal Generation'),
      ),
      body: StreamChannel(
        channel: channel,
        child: _ChannelPage(
          onMessageSent: _generate,
          controller: controller,
        ),
      ),
    );
  }

  void _generate(Message message) async {
    var prompt = message.text;
    if (prompt == null) return;
    var attachment = lastAttachments.firstOrNull;

    var contentList = <Part>[
      TextPart(prompt),
    ];

    if (attachment != null) {
      var file = attachment.file;
      var imageMimeType = attachment.mimeType;

      if (imageMimeType == null || file == null) return;

      var imgBytes = file.bytes;

      contentList.add(DataPart(imageMimeType, imgBytes!));
    }

    final content = [
      Content.multi(contentList),
    ];

    final response = await _model.generateContent(content);

    channel.sendMessage(
      Message(
        text: response.text,
        extraData: const {
          'isGeminiMessage': true,
        },
      ),
    );

    lastAttachments.clear();
  }
}

/// Displays the list of messages inside the channel
class _ChannelPage extends StatelessWidget {
  final ValueChanged<Message> onMessageSent;
  final StreamMessageInputController controller;

  const _ChannelPage({
    super.key,
    required this.onMessageSent,
    required this.controller,
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
                  borderRadiusGeometry:
                      const BorderRadius.all(Radius.circular(16)),
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
            attachmentLimit: 1,
            messageInputController: controller,
          ),
        ],
      ),
    );
  }
}
