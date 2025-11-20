// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'animal_list_screen.dart';
import 'add_animal_screen.dart';
import 'animal_details_screen.dart';
import '../theme.dart';
import '../models/animal.dart';
import '../services/api_service.dart';
import '../widgets/animal_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;
  late Future<List<Animal>> _animalsFuture;
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _animalsFuture = ApiService.getAnimals();
    _statsFuture = _loadStats();
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

  void _refreshData() {
    setState(() {
      _animalsFuture = ApiService.getAnimals();
      _statsFuture = _loadStats();
    });
  }

  void _navigateToAnimalDetails(Animal animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalDetailsScreen(animal: animal),
      ),
    );
  }

  void _showAdoptionDialog(Animal animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Adoption'),
        content: Text('Would you like to apply to adopt ${animal.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitAdoptionApplication(animal);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _submitAdoptionApplication(Animal animal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application submitted for ${animal.name}!'),
        backgroundColor: Colors.green,
      ),
    );
    _refreshData(); // Refresh data to potentially update status
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      AnimalListScreen(onRefresh: _refreshData),
      const AddAnimalScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Animals'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
        ],
      ),
    );
  }

  Widget _homePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Welcome to PawsConnect',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: cuteGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.pets, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Stats Row
            FutureBuilder<Map<String, int>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {
                  'available': 0,
                  'fostered': 0,
                  'adopted': 0,
                  'pending': 0,
                  'total': 0,
                };

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _statCard('Available', stats['available']!.toString(), Colors.green),
                      const SizedBox(width: 12),
                      _statCard('Fostered', stats['fostered']!.toString(), Colors.orange),
                      const SizedBox(width: 12),
                      _statCard('Adopted', stats['adopted']!.toString(), Colors.purple),
                      const SizedBox(width: 12),
                      _statCard('Total', stats['total']!.toString(), Colors.blue),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Recent Animals Header
            Row(
              children: [
                const Text(
                  'Recent Animals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _index = 1), // Navigate to Animals tab
                  child: Text(
                    'View All',
                    style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animals List
            Expanded(
              child: FutureBuilder<List<Animal>>(
                future: _animalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('Error loading animals', style: TextStyle(color: textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _refreshData,
                            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  final list = snapshot.data ?? [];

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pets, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('No animals available', style: TextStyle(fontSize: 16, color: textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _refreshData,
                            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length > 4 ? 4 : list.length, // Show max 4 animals
                    itemBuilder: (_, i) => AnimalCard(
                      animal: list[i],
                      onTap: () => _navigateToAnimalDetails(list[i]),
                      onApply: () => _showAdoptionDialog(list[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [color.withOpacity(0.12), Colors.white]),
        border: Border.all(color: color.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}