import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/animal.dart';
import '../theme.dart';
import 'animal_list_screen.dart';
import 'map_screen.dart';
import 'my_applications_screen.dart';
import 'user_chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Animal>> _animalsFuture;
  late Future<Map<String, int>> _statsFuture;
  
  // Bottom navigation index
  int _selectedIndex = 0;
  
  // Screens for bottom navigation
  final List<Widget> _userScreens = [
    const UserHomeScreen(),
    const MapScreen(),
    const MyApplicationsScreen(),
    const UserChatScreen(),
  ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService.isAdmin;

    return Scaffold(
      // AppBar only for admin, users get app bar inside their screens
      appBar: isAdmin ? _buildAdminAppBar() : null,
      body: isAdmin ? _buildAdminDashboard() : _userScreens[_selectedIndex],
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add-animal'),
              backgroundColor: primaryPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: !isAdmin ? _buildBottomNavigationBar() : null,
    );
  }

  AppBar _buildAdminAppBar() {
    return AppBar(
      title: const Text('PawsConnect Admin'),
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
                _adminActionCard('Analytics', Icons.analytics, '/analytics'),
                _adminActionCard('Chat', Icons.chat_bubble_outline, '/admin-chat'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Shelters',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Applications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: primaryPurple,
      unselectedItemColor: textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: _onItemTapped,
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
      ));
  }

Widget _adminActionCard(String title, IconData icon, String route) {
  return Card(
    elevation: 2,
    child: InkWell(
      onTap: () {
        if (route == '/applications') {
          Navigator.pushNamed(context, '/admin/applications');
        } else if (route == '/users') {
          Navigator.pushNamed(context, '/admin/users');
        } else if (route == '/admin-chat') {
          Navigator.pushNamed(context, '/admin-chat');
        } else {
          Navigator.pushNamed(context, route);
        }
      },

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
}

// User Home Screen
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late Future<List<Animal>> _animalsFuture;
  late Future<Map<String, int>> _statsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      return {
        'available': available,
        'total': animals.length,
      };
    } catch (e) {
      return {'available': 0, 'total': 0};
    }
  }

  void _navigateToAnimalDetails(Animal animal) {
    Navigator.pushNamed(
      context,
      '/animal-details',
      arguments: animal,
    );
  }

  void _searchAnimals(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${currentUser?.firstName}!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              'Find your furry friend',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          return Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search animals by name, breed, or species...',
                          hintStyle: TextStyle(color: textSecondary),
                          border: InputBorder.none,
                        ),
                        onChanged: _searchAnimals,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: textSecondary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _searchAnimals('');
                        },
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats Cards
              FutureBuilder<Map<String, int>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stats = snapshot.data ?? {};
                  return Row(
                    children: [
                      Expanded(
                        child: _userStatCard(
                          'Available Pets',
                          stats['available'] ?? 0,
                          Icons.pets,
                          primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _userStatCard(
                          'Total Pets',
                          stats['total'] ?? 0,
                          Icons.emoji_nature,
                          primaryViolet,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Featured Pets Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Pets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnimalListScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          'Browse All',
                          style: TextStyle(color: primaryPurple),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: primaryPurple),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Featured Animals Grid (Removed quick actions, showing more pets)
              FutureBuilder<List<Animal>>(
                future: _animalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return const Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Error loading animals',
                            style: TextStyle(color: textSecondary),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final animals = (snapshot.data ?? [])
                      .where((a) => a.status.toLowerCase() != 'adopted')
                      .toList();
                  
                  // Filter animals based on search query
                  List<Animal> filteredAnimals = animals;
                  if (_searchQuery.isNotEmpty) {
                    filteredAnimals = animals.where((animal) {
                      return animal.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             animal.breed.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             animal.species.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();
                  }
                  
                  // Show only available animals first, then others
                  filteredAnimals.sort((a, b) {
                    if (a.status.toLowerCase() == 'available' && b.status.toLowerCase() != 'available') {
                      return -1;
                    } else if (a.status.toLowerCase() != 'available' && b.status.toLowerCase() == 'available') {
                      return 1;
                    }
                    return 0;
                  });
                  
                  // Take up to 6 animals for display
                  final displayedAnimals = filteredAnimals.take(6).toList();
                  
                  if (displayedAnimals.isEmpty) {
                    return Column(
                      children: [
                        Icon(Icons.pets, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No pets available right now'
                              : 'No pets found for "$_searchQuery"',
                          style: const TextStyle(color: textSecondary),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              _searchAnimals('');
                            },
                            child: const Text(
                              'Clear search',
                              style: TextStyle(color: primaryPurple),
                            ),
                          ),
                      ],
                    );
                  }
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75, // Adjusted for better pet card proportions
                    ),
                    itemCount: displayedAnimals.length,
                    itemBuilder: (context, index) {
                      final animal = displayedAnimals[index];
                      return _petCard(animal);
                    },
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Browse All Button
              if (_searchQuery.isEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnimalListScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Browse All Pets',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
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
              Text(
                title,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _petCard(Animal animal) {
    final image = (animal.imageUrl?.isNotEmpty == true)
        ? animal.imageUrl!
        : 'https://placekitten.com/300/200';

    return GestureDetector(
      onTap: () => _navigateToAnimalDetails(animal),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(animal.status).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        animal.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Animal Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    animal.breed,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      const Icon(Icons.cake, size: 12, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${animal.age} yrs',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.transgender, size: 12, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        animal.gender,
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Species tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: primaryPurple.withOpacity(0.3)),
                    ),
                    child: Text(
                      animal.species,
                      style: const TextStyle(
                        fontSize: 10,
                        color: primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'adopted':
        return Colors.purple;
      case 'fostered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
