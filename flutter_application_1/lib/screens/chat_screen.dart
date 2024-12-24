import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {'message': 'Hello!', 'isMe': false},
    {'message': 'Hi there!', 'isMe': true},
    {'message': 'How are you?', 'isMe': false},
  ];

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();

    // Add the user's message to the chat
    setState(() {
      _messages.add({'message': userMessage, 'isMe': true});
      _isLoading = true;
    });
    _controller.clear();

    // Send the request to the server
    try {
      final response = await http.post(
        Uri.parse('https://ad1c-103-92-153-10.ngrok-free.app/api/v1/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverMessage = data['answer'] ?? 'No answer received.';

        // Add the server's response to the chat
        setState(() {
          _messages.add({'message': serverMessage, 'isMe': false});
        });
      } else {
        setState(() {
          _messages
              .add({'message': 'Error: ${response.statusCode}', 'isMe': false});
        });
      }
    } catch (error) {
      setState(() {
        _messages.add({'message': 'An error occurred: $error', 'isMe': false});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat UI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Messages appear from bottom to top
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(
                  message: message['message'],
                  isMe: message['isMe'],
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
