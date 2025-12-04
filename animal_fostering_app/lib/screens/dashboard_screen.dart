import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/animal.dart';
import '../widgets/animal_card.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Animal>> _animalsFuture;
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _animalsFuture = ApiService.getAnimals();
      _statsFuture = _loadStats();
    });
  }

  Future<Map<String, int>> _loadStats() async {
    try {
      final animals = await ApiService.getAnimals();
      final available = animals.where((a) => a.status.toLowerCase() == 'available').length;
      final fostered = animals.where((a) => a.status.toLowerCase() == 'fostered').length;
      final adopted = animals.where((a) => a.status.toLowerCase() == 'adopted').length;
      final pending = animals.where((a) => a.status.toLowerCase() == 'pending').length;
      
      return {
        'available': available,
        'fostered': fostered,
        'adopted': adopted,
        'pending': pending,
        'total': animals.length,
      };
    } catch (e) {
      return {'available': 0, 'fostered': 0, 'adopted': 0, 'pending': 0, 'total': 0};
    }
  }

  void _navigateToAnimalDetails(Animal animal) {
    Navigator.pushNamed(
      context,
      '/animal-details',
      arguments: animal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService.isAdmin;
    final currentUser = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PawsConnect'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'logout':
                  AuthService.logout();
                  Navigator.pushReplacementNamed(context, '/');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('My Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: isAdmin ? _buildAdminDashboard() : _buildUserDashboard(),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add-animal'),
              backgroundColor: primaryPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAdminDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome, Admin ${AuthService.currentUser?.firstName}!',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your shelter efficiently',
            style: TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 20),

          // Stats
          FutureBuilder<Map<String, int>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = snapshot.data ?? {};
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statCard('Available', stats['available'] ?? 0, Colors.green),
                    const SizedBox(width: 12),
                    _statCard('Pending', stats['pending'] ?? 0, Colors.orange),
                    const SizedBox(width: 12),
                    _statCard('Adopted', stats['adopted'] ?? 0, Colors.purple),
                    const SizedBox(width: 12),
                    _statCard('Total', stats['total'] ?? 0, Colors.blue),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _adminActionCard('Manage Animals', Icons.pets, '/animals'),
                _adminActionCard('Adoption Requests', Icons.assignment, '/applications'),
                _adminActionCard('Manage Shelters', Icons.location_city, '/shelters'),
                _adminActionCard('User Management', Icons.people, '/users'),
                _adminActionCard('Upload Photos', Icons.photo_camera, '/camera'),
                _adminActionCard('Analytics', Icons.analytics, '/analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome, ${AuthService.currentUser?.firstName}!',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find your perfect furry companion',
            style: TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 20),

          // User Features
          Expanded(
            child: ListView(
              children: [
                _userFeatureCard(
                  'Browse Animals',
                  Icons.pets,
                  'Discover animals waiting for a loving home',
                  '/animals',
                ),
                _userFeatureCard(
                  'Find Shelters',
                  Icons.map,
                  'Locate shelters near you',
                  '/map',
                ),
                _userFeatureCard(
                  'My Applications',
                  Icons.assignment,
                  'Track your adoption requests',
                  '/my-applications',
                ),
                _userFeatureCard(
                  'Chat Support',
                  Icons.chat,
                  'Get help from our team',
                  '/chat',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminActionCard(String title, IconData icon, String route) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: primaryPurple),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userFeatureCard(String title, IconData icon, String subtitle, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: primaryPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}