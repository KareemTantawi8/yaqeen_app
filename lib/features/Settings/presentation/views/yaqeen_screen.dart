import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model for chat messages
class MessageModel {
  final String role; // "user" or "bot"
  final String content;
  MessageModel({required this.role, required this.content});
}

class YaqeenScreen extends StatefulWidget {
  static const String routeName = '/yaqeen';
  const YaqeenScreen({super.key});

  @override
  State<YaqeenScreen> createState() => _YaqeenScreenState();
}

class _YaqeenScreenState extends State<YaqeenScreen> {
  final List<MessageModel> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // TODO: Replace with your own valid OpenAI API key
  // Store API key securely using environment variables or secure storage
  // final String _apiKey = "YOUR_API_KEY_HERE";

  final String _apiUrl = "https://api.openai.com/v1/chat/completions";

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(MessageModel(role: "user", content: text));
      messageController.clear();
      messages.add(MessageModel(role: "bot", content: "جاري الكتابة..."));
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          // 'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': text}
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      setState(() {
        messages.removeWhere((m) => m.content == "جاري الكتابة...");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["choices"][0]["message"]["content"];
        setState(() {
          messages.add(MessageModel(role: "bot", content: reply.trim()));
        });
      } else {
        setState(() {
          messages.add(MessageModel(
              role: "bot",
              content:
                  "خطأ: ${response.statusCode} - ${response.reasonPhrase ?? ''}"));
        });
      }
      _scrollToBottom();
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      setState(() {
        messages.removeWhere((m) => m.content == "جاري الكتابة...");
        messages.add(MessageModel(role: "bot", content: "خطأ: $e"));
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أسأل يقين ؟')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg.role == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.role == "user"
                          ? Colors.green[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: msg.role == "user"
                            ? Colors.green[900]
                            : Colors.black87,
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                      ),
                      textAlign:
                          msg.role == "user" ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      hintText: 'اكتب سؤالك هنا...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2B7669)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
