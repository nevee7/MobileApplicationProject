// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'animal_list_screen.dart';
import 'add_animal_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _animalsFuture = ApiService.getAnimals();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      const AnimalListScreen(),
      const AddAnimalScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: primaryPurple,
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
          children: [
            Row(
              children: [
                const Expanded(child: Text('Welcome to PawsConnect', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                Container(
                  decoration: BoxDecoration(gradient: cuteGradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.12), blurRadius: 12, offset: Offset(0, 6))]),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.pets, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 18),
            // stat row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _statCard('Available', '8', Colors.green),
                  const SizedBox(width: 12),
                  _statCard('Fostered', '3', Colors.orange),
                  const SizedBox(width: 12),
                  _statCard('Adopted', '2', Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: FutureBuilder<List<Animal>>(
                future: _animalsFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final list = snap.data ?? [];
                  return ListView.builder(
                    itemCount: list.length > 4 ? 4 : list.length,
                    itemBuilder: (_, i) => AnimalCard(animal: list[i], onTap: () {}),
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
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: color.withOpacity(0.8))),
      ]),
    );
  }
}
