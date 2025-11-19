import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback? onTap;

  const AnimalCard({super.key, required this.animal, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Animal Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  animal.imageUrl ?? 'https://via.placeholder.com/150',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Animal Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('${animal.species} - ${animal.breed}'),
                    const SizedBox(height: 4),
                    Text('Age: ${animal.age}'),
                    const SizedBox(height: 4),
                    Text('Status: ${animal.status}'),
                    if (animal.shelterId != null) // optional
                      Text('Shelter ID: ${animal.shelterId}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
