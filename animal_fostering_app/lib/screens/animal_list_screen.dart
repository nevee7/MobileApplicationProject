import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/api_service.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  late Future<List<Animal>> futureAnimals;

  @override
  void initState() {
    super.initState();
    futureAnimals = ApiService.getAnimals();
  }

  void _refreshAnimals() {
    setState(() {
      futureAnimals = ApiService.getAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Animal>>(
        future: futureAnimals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No animals found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Animal animal = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: animal.imageUrl.isNotEmpty 
                        ? NetworkImage(animal.imageUrl)
                        : const AssetImage('assets/default_animal.png') as ImageProvider,
                  ),
                  title: Text(animal.name),
                  subtitle: Text('${animal.species} • ${animal.breed} • ${animal.age} years'),
                  trailing: Chip(
                    label: Text(
                      animal.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(animal.status),
                  ),
                  onTap: () {
                    // Navigate to animal details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshAnimals,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'fostered':
        return Colors.orange;
      case 'adopted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}