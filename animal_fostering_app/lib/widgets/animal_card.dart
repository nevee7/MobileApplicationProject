// lib/widgets/animal_card.dart
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback? onTap;

  const AnimalCard({super.key, required this.animal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = (animal.imageUrl?.isNotEmpty == true)
        ? animal.imageUrl!
        : 'http://placekitten.com/400/400';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: softCardDecoration,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // left image
            Hero(
              tag: 'animal_${animal.id}',
              child: Image.network(
                image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: lightPurple,
                  alignment: Alignment.center,
                  child: Icon(Icons.pets, color: primaryPurple, size: 44),
                ),
              ),
            ),

            // right info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(animal.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: 6),
                    Text('${animal.species} • ${animal.breed}', style: TextStyle(color: textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoPill('${animal.age} y'),
                        const SizedBox(width: 8),
                        _infoPill(animal.gender),
                        const SizedBox(width: 8),
                        if (animal.size != null) _infoPill(animal.size!),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      animal.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryPurple.withOpacity(0.9)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Details', style: TextStyle(color: primaryPurple)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: animal.status.toLowerCase() == 'available' ? () {} : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(animal.status.toLowerCase() == 'available' ? 'Apply to adopt' : 'Not available'),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: primaryViolet.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
