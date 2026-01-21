import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final _controller = TextEditingController();
  bool _loading = true;
  String? _error;
  List<dynamic> _messages = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final all = await ApiService.getMessages();
      final myId = AuthService.currentUser!.id;

      // User view: show messages involving me (and admin broadcast if any)
      final filtered = all.where((m) {
        final senderId = _getValue(m, 'senderId');
        final receiverId = _getValue(m, 'receiverId');
        return senderId == myId || receiverId == myId || receiverId == null;
      }).toList();

      filtered.sort((a, b) {
        final ta = DateTime.tryParse((_getValue(a, 'sentAt') ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final tb = DateTime.tryParse((_getValue(b, 'sentAt') ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return ta.compareTo(tb);
      });

      setState(() => _messages = filtered);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      // Send to admin: keep receiverId null (your backend allows it)
      await ApiService.sendMessage(
        receiverId: null,
        content: text,
        messageType: 'Text',
      );

      _controller.clear();
      await _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = AuthService.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final m = _messages[i];
                          final isMe = (_getValue(m, 'senderId') == myId);
                          final content = (_getValue(m, 'content') ?? '').toString();

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(content),
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Type a message',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _send,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  dynamic _getValue(Map<String, dynamic> map, String key) {
    if (map.containsKey(key)) return map[key];
    final camel = key.isEmpty ? key : key[0].toLowerCase() + key.substring(1);
    if (map.containsKey(camel)) return map[camel];
    final pascal = key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
    if (map.containsKey(pascal)) return map[pascal];
    return null;
  }
}
