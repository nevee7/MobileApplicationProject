import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../theme.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  late Future<List<User>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = ApiService.getUsers();
    });
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${user.fullName}'),
              Text('Email: ${user.email}'),
              Text('Role: ${user.role}'),
              Text('Phone: ${user.phone ?? "Not provided"}'),
              Text('Address: ${user.address ?? "Not provided"}'),
              Text('Status: ${user.isActive ? "Active" : "Inactive"}'),
              const SizedBox(height: 16),
              const Text('Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _toggleUserStatus(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.orange : Colors.green,
            ),
            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
          ),
          if (!user.isAdmin)
            ElevatedButton(
              onPressed: () => _makeAdmin(user),
              style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
              child: const Text('Make Admin'),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(User user) async {
    // In a real app, you would call an API endpoint to toggle user status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User ${user.isActive ? 'deactivated' : 'activated'}'),
        backgroundColor: user.isActive ? Colors.orange : Colors.green,
      ),
    );
    Navigator.pop(context);
    _refreshUsers();
  }

  Future<void> _makeAdmin(User user) async {
    // In a real app, you would call an API endpoint to change user role
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Admin'),
        content: Text('Are you sure you want to make ${user.fullName} an admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.fullName} is now an admin'),
                  backgroundColor: Colors.green,
                ),
              );
              _refreshUsers();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            onPressed: _refreshUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search users...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Error loading users'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshUsers,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final users = snapshot.data ?? [];
                final filteredUsers = users.where((user) {
                  return user.fullName.toLowerCase().contains(_searchQuery) ||
                      user.email.toLowerCase().contains(_searchQuery) ||
                      user.role.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No users found'),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Text('Clear search'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.isAdmin ? primaryPurple : primaryViolet,
                          child: Text(
                            user.firstName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text('Role: ${user.role}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (user.isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Icon(
                              user.isActive ? Icons.check_circle : Icons.remove_circle,
                              color: user.isActive ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        onTap: () => _showUserDetails(user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}