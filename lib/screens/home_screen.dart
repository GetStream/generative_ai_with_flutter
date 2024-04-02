import 'package:flutter/material.dart';
import 'package:generative_ai_with_flutter/screens/screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, Widget> pages = {
    'Text to Text': const TextGenerationScreen(),
    'Chat': const ChatScreen(),
    'Embedding': const EmbeddingScreen(),
    'Multimodal': const MultimodalScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generative AI with Flutter'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, int index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => pages.values.toList()[index],
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(
                  16.0,
                ),
              ),
              child: Center(
                child: Text(
                  pages.keys.toList()[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: pages.length,
      ),
    );
  }
}
