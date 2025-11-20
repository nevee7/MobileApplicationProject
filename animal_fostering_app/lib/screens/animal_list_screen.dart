// lib/screens/animal_list_screen.dart
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/api_service.dart';
import '../widgets/animal_card.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});
  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  late Future<List<Animal>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = ApiService.getAnimals();
  }

  void _search(String q) {
    setState(() {
      _query = q.trim();
      _future = ApiService.getAnimals(query: _query.isEmpty ? null : {'search': _query});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animals'),
        actions: [
          IconButton(onPressed: () => setState(() => _future = ApiService.getAnimals()), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by name, breed or description',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Animal>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.pets, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No animals found', style: TextStyle(fontSize: 16)),
                  ]));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => AnimalCard(animal: list[i], onTap: () {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
