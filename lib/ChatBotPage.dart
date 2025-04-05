import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:gym/config/config.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getString('chat_history');
    if (savedMessages != null) {
      setState(() {
        _messages.addAll(List<Map<String, String>>.from(jsonDecode(savedMessages)));
      });
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(_messages));
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": message});
      _isLoading = true;
    });
    await _saveChatHistory();

    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$geminiApiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": _messages
              .map((msg) => {
            "role": msg["role"],
            "parts": [
              {"text": msg["content"]}
            ]
          })
              .toList(),
          "generationConfig": {"maxOutputTokens": 2048}
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final candidates = responseData['candidates'];
        final fullText = (candidates != null && candidates.isNotEmpty)
            ? candidates[0]['content']['parts'][0]['text'] ?? "No response from AI."
            : "No candidates returned.";

        setState(() {
          _messages.add({"role": "assistant", "content": fullText});
        });
      } else {
        String errorMessage = "Unknown error";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData["error"]["message"] ?? "No error message provided.";
        } catch (e) {
          errorMessage = "Failed to parse error response.";
        }
        setState(() {
          _messages.add({"role": "assistant", "content": "Error: $errorMessage"});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "Error: Network issue or API failure."});
      });
    } finally {
      _isLoading = false;
      await _saveChatHistory();
      setState(() {});
    }
  }

  void _showCopyShareOptions(String content) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('Copy'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Share.share(content);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msg = _messages[index];
                return Align(
                  alignment: msg["role"] == "user" ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () => _showCopyShareOptions(msg["content"]!),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: msg["role"] == "user" ? Colors.blue[300] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                          maxHeight: 300,
                        ),
                        child: SingleChildScrollView(
                          child: Text(msg["content"]!),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _sendMessage(value);
                        _controller.clear();
                      }
                    },
                    decoration: const InputDecoration(hintText: "Ask something..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
