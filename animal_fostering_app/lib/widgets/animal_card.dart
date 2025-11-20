// lib/widgets/animal_card.dart
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const AnimalCard({
    super.key, 
    required this.animal, 
    this.onTap,
    this.onApply,
  });

  String _getSizeDescription(String? size) {
    switch (size?.toLowerCase()) {
      case 'small': return 'Small';
      case 'medium': return 'Medium';
      case 'large': return 'Large';
      default: return 'Medium';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return Colors.green;
      case 'pending': return Colors.orange;
      case 'adopted': return Colors.purple;
      case 'fostered': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = (animal.imageUrl?.isNotEmpty == true)
        ? animal.imageUrl!
        : 'https://placekitten.com/400/400';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: softCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal Image
            Hero(
              tag: 'animal-image-${animal.id}',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Animal Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          animal.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(animal.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _getStatusColor(animal.status).withOpacity(0.3)),
                        ),
                        child: Text(
                          animal.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(animal.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${animal.breed} - ${animal.age} years',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${animal.species} • ${animal.gender} • ${_getSizeDescription(animal.size)}',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    animal.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryPurple,
                            side: BorderSide(color: primaryPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Details'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: animal.status.toLowerCase() == 'available' ? onApply : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}