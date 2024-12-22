import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton> {
  bool isOpen = false;
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> generateAnswer() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isBot: false,
      ));
      isLoading = true;
    });

    final userQuestion = _messageController.text;
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBXvyQXa7LjTNqqDkm3uvubhhkQ1A5dWZs',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": userQuestion
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.9,
            "topK": 1,
            "topP": 1
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate response: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response generated');
      }

      final content = candidates[0]['content'] as Map<dynamic, dynamic>?;
      if (content == null) {
        throw Exception('Invalid response format');
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No content parts found');
      }

      final text = parts[0]['text'] as String?;
      if (text == null) {
        throw Exception('No text content found');
      }

      setState(() {
        _messages.add(ChatMessage(
          text: text,
          isBot: true,
        ));
        isLoading = false;
      });
    } catch (error) {
      print('Error: $error');
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I encountered an error. Please try again.",
          isBot: true,
          isError: true,
        ));
        isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isOpen)
          Positioned(
            bottom: 100,
            right: 24,
            child: Container(
              width: 384,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chat Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => isOpen = false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          );
                        }
                        return _messages[index];
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          onSubmitted: (value) {
                            if (!isLoading) generateAnswer();
                          },
                        ),
                        const SizedBox(height: 8),
                        MaterialButton(
                          onPressed: isLoading ? null : generateAnswer,
                          color: Colors.green,
                          disabledColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minWidth: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                isLoading ? 'Generating...' : 'Send',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 24,
          right: 24,
          child: MaterialButton(
            onPressed: () => setState(() => isOpen = !isOpen),
            color: Colors.green,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            child: const Icon(Icons.message, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isBot;
  final bool isError;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isBot,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.android, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isBot
                    ? (isError
                        ? Colors.red.shade100
                        : Colors.grey.shade100)
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isBot ? null : const Radius.circular(0),
                  bottomLeft: isBot ? const Radius.circular(0) : null,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isError ? Colors.red : Colors.black87,
                ),
              ),
            ),
          ),
          if (!isBot)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}