import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../data/config.dart';

class MultimodalScreen extends StatefulWidget {
  const MultimodalScreen({super.key});

  @override
  State<MultimodalScreen> createState() => _MultimodalScreenState();
}

class _MultimodalScreenState extends State<MultimodalScreen> {
  late GenerativeModel _model;
  final TextEditingController _promptController = TextEditingController();
  XFile? _image;
  String _result = "";

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: GenAIConfig.apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multimodal Generation'),
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
          if (_image != null)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Image chosen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: OutlinedButton(
              onPressed: _pickImage,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Choose image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
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
    if (prompt.isEmpty || _image == null) return;

    var imgBytes = await _image!.readAsBytes();
    var imageMimeType = lookupMimeType(_image!.path);

    if (imageMimeType == null) return;

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart(imageMimeType, imgBytes),
      ]),
    ];

    final response = await _model.generateContent(content);
    setState(() {
      _result = response.text ?? '';
    });
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    _image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }
}
