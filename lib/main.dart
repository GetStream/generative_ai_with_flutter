import 'package:flutter/material.dart';
import 'package:generative_ai_with_flutter/data/config.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'screens/screens.dart';

void main() async {
  final client = StreamChatClient(
    GenAIConfig.streamApiKey,
    logLevel: Level.INFO,
  );

  var token = client.devToken('gemini');
  await client.connectUser(
    User(
      id: 'gemini',
      name: 'gemini',
      role: 'admin',
    ),
    token.rawValue,
  );

  runApp(
    MyApp(
      client: client,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.client,
  });

  final StreamChatClient client;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) => StreamChat(
        client: client,
        child: child,
      ),
      home: const HomeScreen(),
    );
  }
}
