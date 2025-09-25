import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-IA App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedModel = 'chatgpt';
  List<String> models = ['chatgpt','claude','grok','gemini'];
  List<Map<String,String>> history = []; // Historique local

  Map<String,String> _comparisonResult = {}; // Comparaison automatique

  Future<String> sendPromptToModel(String model, String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/prompt'), // Remplacer par IP du serveur
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'model': model, 'prompt': prompt}),
      );
      final data = jsonDecode(response.body);
      return data['answer'] ?? data['error'];
    } catch (e) {
      return 'Erreur: $e';
    }
  }

  Future<void> sendPrompt() async {
    final prompt = _controller.text;

    if (_selectedModel == 'auto') {
      // Comparer tous les modèles automatiquement
      Map<String,String> results = {};
      for (var model in models) {
        results[model] = await sendPromptToModel(model, prompt);
      }
      setState(() {
        _comparisonResult = results;
        history.add({'prompt': prompt, 'answer': results.toString()});
      });
    } else {
      final answer = await sendPromptToModel(_selectedModel, prompt);
      setState(() {
        history.add({'prompt': prompt, 'answer': answer});
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multi-IA Chat')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Votre prompt'),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedModel,
              items: [...models, 'auto']
                  .map((m) => DropdownMenuItem(child: Text(m), value: m))
                  .toList(),
              onChanged: (val) {
                setState(() { _selectedModel = val!; });
              },
            ),
            ElevatedButton(onPressed: sendPrompt, child: Text('Envoyer')),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context,index){
                  final item = history[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical:5),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prompt: ${item['prompt']}', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height:5),
                          Text('Réponse: ${item['answer']}'),
                        ],
                      ),
                    ),
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }
}
