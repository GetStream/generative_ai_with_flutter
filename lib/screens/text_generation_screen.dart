import 'package:flutter/material.dart';
import 'package:generative_ai_with_flutter/data/config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class TextGenerationScreen extends StatefulWidget {
  const TextGenerationScreen({super.key});

  @override
  State<TextGenerationScreen> createState() => _TextGenerationScreenState();
}

class _TextGenerationScreenState extends State<TextGenerationScreen> {
  late GenerativeModel _model;
  final TextEditingController _promptController = TextEditingController();
  String _result = "";

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GenAIConfig.apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Generation'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _promptController,
              decoration: InputDecoration(
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
                'Generate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Result: $_result'),
          ),
        ],
      ),
    );
  }

  void _generate() async {
    var prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final content = [Content.text(prompt)];

    final response = await _model.generateContent(content);
    setState(() {
      _result = response.text ?? '';
    });
  }
}
