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
  late Future<List<Animal>> _animalsFuture;

  @override
  void initState() {
    super.initState();
    _animalsFuture = ApiService.getAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animals')),
      body: FutureBuilder<List<Animal>>(
        future: _animalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No animals found.'));
          }

          final animals = snapshot.data!;

          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return AnimalCard(
                animal: animal,
                onTap: () {
                  // Optional: navigate to animal details page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Clicked on ${animal.name}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
