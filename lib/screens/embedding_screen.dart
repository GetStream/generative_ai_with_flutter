import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../data/config.dart';

class EmbeddingScreen extends StatefulWidget {
  const EmbeddingScreen({super.key});

  @override
  State<EmbeddingScreen> createState() => _EmbeddingScreenState();
}

class _EmbeddingScreenState extends State<EmbeddingScreen> {
  late GenerativeModel _model;
  final TextEditingController _promptController = TextEditingController();
  String _result = "";

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'embedding-001',
      apiKey: GenAIConfig.geminiApiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Embedding'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          OutlinedButton(
            onPressed: _generate,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Create embedding',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Result: $_result'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generate() async {
    var prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final content = Content.text(prompt);

    final response = await _model.embedContent(content);
    setState(() {
      _result = response.embedding.values.toString();
    });
  }
}
