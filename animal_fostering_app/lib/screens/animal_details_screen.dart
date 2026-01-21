// lib/screens/animal_details_screen.dart
import 'package:animal_fostering_app/screens/edit_animal_screen.dart';
import 'package:animal_fostering_app/services/api_service.dart';
import 'package:animal_fostering_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme.dart';

class AnimalDetailsScreen extends StatelessWidget {
  final Animal animal;

  const AnimalDetailsScreen({super.key, required this.animal});

  void _showAdoptionDialog(BuildContext context) {
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
              _submitAdoptionApplication(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

Future<void> _submitAdoptionApplication(BuildContext context) async {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login to apply for adoption'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final TextEditingController messageController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Adoption Application'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Applying for ${animal.name}'),
          const SizedBox(height: 16),
          TextField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              final message = messageController.text.trim();
              final success = await ApiService.createAdoptionApplication(
                animalId: animal.id,
                message: message.isEmpty ? null : message,
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Application submitted for ${animal.name}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to submit application'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
          child: const Text('Submit Application'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final image = (animal.imageUrl?.isNotEmpty == true)
        ? animal.imageUrl!
        : 'https://placekitten.com/400/400';

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (AuthService.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAnimalScreen(animal: animal),
                  ),
                );
                if (result == true) {
                  Navigator.pop(context, true); // Refresh animal details
                }
    },
  ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Hero(
              tag: 'animal-image-${animal.id}',
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Animal Info
            Text(
              animal.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              '${animal.breed} • ${animal.age} years old',
              style: const TextStyle(fontSize: 18, color: textSecondary),
            ),
            const SizedBox(height: 16),

            // Info Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem('Species', animal.species),
                  _infoItem('Gender', animal.gender),
                  _infoItem('Size', animal.size ?? 'Medium'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              animal.description,
              style: const TextStyle(fontSize: 16, color: textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Medical Notes if available
            if (animal.medicalNotes?.isNotEmpty == true) ...[
              const Text(
                'Medical Notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                animal.medicalNotes!,
                style: const TextStyle(fontSize: 16, color: textSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
            ],

            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(animal.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(animal.status).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _getStatusColor(animal.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${animal.status}',
                    style: TextStyle(
                      color: _getStatusColor(animal.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Apply Button
            if (animal.status.toLowerCase() == 'available') 
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAdoptionDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply to Adopt',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
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
