import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final bool _isAdmin = AuthService.isAdmin;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // In a real app, load messages from API
    setState(() {
      _messages.addAll([
        ChatMessage(
          id: 1,
          text: _isAdmin 
              ? 'Hello! How can I help you today?' 
              : 'Hi Admin, I have a question about my application.',
          sender: _isAdmin ? 'Admin' : 'You',
          time: DateTime.now().subtract(const Duration(minutes: 5)),
          isMe: !_isAdmin,
          isAdmin: _isAdmin,
        ),
        ChatMessage(
          id: 2,
          text: _isAdmin 
              ? 'What would you like to know?' 
              : 'When will my application be reviewed?',
          sender: _isAdmin ? 'You' : 'Admin',
          time: DateTime.now().subtract(const Duration(minutes: 4)),
          isMe: _isAdmin,
          isAdmin: !_isAdmin,
        ),
        ChatMessage(
          id: 3,
          text: 'Applications are usually reviewed within 24-48 hours.',
          sender: 'Admin',
          time: DateTime.now().subtract(const Duration(minutes: 3)),
          isMe: false,
          isAdmin: true,
        ),
      ]);
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: _messages.length + 1,
        text: text,
        sender: _isAdmin ? 'You' : 'You',
        time: DateTime.now(),
        isMe: true,
        isAdmin: _isAdmin,
      ));
    });

    _messageController.clear();
    
    // Auto-reply for demo
    if (!_isAdmin) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(ChatMessage(
            id: _messages.length + 1,
            text: 'Thanks for your message! An admin will respond soon.',
            sender: 'Admin',
            time: DateTime.now(),
            isMe: false,
            isAdmin: true,
          ));
        });
      });
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  setState(() => _messages.clear());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 100,
                          color: primaryPurple.withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isAdmin 
                              ? 'Users will appear here when they message you'
                              : 'Start a conversation with our support team',
                          style: const TextStyle(
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe && message.isAdmin)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: primaryPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isMe ? primaryPurple : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!message.isMe)
                    Text(
                      message.sender,
                      style: const TextStyle(
                        color: primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      color: message.isMe ? Colors.white70 : textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              gradient: cuteGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return 'Today ${_formatHour(time)}';
    } else if (messageDay == yesterday) {
      return 'Yesterday ${_formatHour(time)}';
    } else {
      return '${time.day}/${time.month} ${_formatHour(time)}';
    }
  }

  String _formatHour(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final int id;
  final String text;
  final String sender;
  final DateTime time;
  final bool isMe;
  final bool isAdmin;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
    required this.isAdmin,
  });
}