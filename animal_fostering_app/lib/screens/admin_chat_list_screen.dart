import 'dart:async';
import 'package:animal_fostering_app/screens/admin_chat_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;

  // Each item: { userId, name, email, lastMessage, lastTime }
  List<Map<String, dynamic>> _threads = [];

  @override
  void initState() {
    super.initState();
    _loadThreads();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadThreads());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final msgs = await ApiService.getMessages(); // your existing method
      final myId = AuthService.currentUser?.id; // or however you store it

      // Group by "other user"
      final Map<int, Map<String, dynamic>> byUser = {};

      for (final m in msgs) {
        final sender = _getValue(m, 'sender');
        final receiver = _getValue(m, 'receiver');

        final bool senderIsAdmin = (sender?['role'] == 'Admin' || sender?['Role'] == 'Admin');
        final other = senderIsAdmin ? receiver : sender;

        if (other == null) continue;
        final int otherId = other['id'];

        final sentAtRaw = _getValue(m, 'sentAt');
        final DateTime sentAt =
            DateTime.tryParse((sentAtRaw ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);

        final contentRaw = _getValue(m, 'content');
        final String content = (contentRaw ?? '').toString();

        final existing = byUser[otherId];
        if (existing == null || sentAt.isAfter(existing['lastTime'] as DateTime)) {
          byUser[otherId] = {
            'userId': otherId,
            'name': '${_getValue(other, 'firstName') ?? ''} ${_getValue(other, 'lastName') ?? ''}'.trim(),
            'email': _getValue(other, 'email') ?? '',
            'lastMessage': content,
            'lastTime': sentAt,
          };
        }
      }

      final threads = byUser.values.toList();
      threads.sort((a, b) => (b['lastTime'] as DateTime).compareTo(a['lastTime'] as DateTime));

      setState(() => _threads = threads);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  dynamic _getValue(Map<String, dynamic> map, String key) {
    if (map.containsKey(key)) return map[key];
    final camel = key.isEmpty ? key : key[0].toLowerCase() + key.substring(1);
    if (map.containsKey(camel)) return map[camel];
    final pascal = key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
    if (map.containsKey(pascal)) return map[pascal];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadThreads,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _threads.isEmpty
                  ? const Center(child: Text('No conversations yet.'))
                  : ListView.separated(
                      itemCount: _threads.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final t = _threads[i];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(t['name'] ?? 'Unknown'),
                          subtitle: Text(t['lastMessage'] ?? ''),
                          trailing: Text(
                            (t['lastTime'] as DateTime).toLocal().toString().substring(0, 16),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminChatDetailScreen(
                                  userId: t['userId'],
                                  userName: t['name'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
