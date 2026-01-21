import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/api_service.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = ApiService.getNotifications();
    });
  }

  Future<void> _markAsRead(int id) async {
    final success = await ApiService.markNotificationRead(id);
    if (success) {
      _refreshNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await ApiService.markAllNotificationsRead();
    if (success) {
      _refreshNotifications();
    }
  }

  Future<void> _clearAll() async {
    final success = await ApiService.clearNotifications();
    if (success) {
      _refreshNotifications();
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Success':
        return Colors.green;
      case 'Warning':
        return Colors.orange;
      case 'Error':
        return Colors.red;
      case 'Info':
      default:
        return primaryPurple;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Success':
        return Icons.check_circle;
      case 'Warning':
        return Icons.warning;
      case 'Error':
        return Icons.error;
      case 'Info':
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Error loading notifications'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refreshNotifications,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          return notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 100,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No Notifications',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'You\'re all caught up!',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          if (notifications.any((n) => !n.isRead))
                            TextButton.icon(
                              onPressed: _markAllAsRead,
                              icon: const Icon(Icons.mark_email_read),
                              label: const Text('Mark all read'),
                            ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _clearAll,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Clear all'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            color: notification.isRead ? Colors.white : lightPurple,
                            child: ListTile(
                              leading: Icon(
                                _getNotificationIcon(notification.type),
                                color: _getNotificationColor(notification.type),
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification.message),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(notification.createdAt.toLocal()),
                                    style: const TextStyle(fontSize: 12, color: textSecondary),
                                  ),
                                ],
                              ),
                              trailing: !notification.isRead
                                  ? const Icon(
                                      Icons.circle,
                                      color: primaryPurple,
                                      size: 8,
                                    )
                                  : null,
                              onTap: () => _markAsRead(notification.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
