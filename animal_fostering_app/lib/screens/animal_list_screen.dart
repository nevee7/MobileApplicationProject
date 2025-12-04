// lib/screens/animal_list_screen.dart
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/api_service.dart';
import '../widgets/animal_card.dart';
import '../theme.dart';
import 'animal_details_screen.dart';

class AnimalListScreen extends StatefulWidget {
  final VoidCallback? onRefresh;
  
  const AnimalListScreen({super.key, this.onRefresh});
  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  late Future<List<Animal>> _future;
  String _query = '';
  String _selectedSpecies = 'All Species';
  String _selectedStatus = 'All Status';
  String _selectedShelter = 'All Shelters';

  final List<String> _speciesOptions = ['All Species', 'Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _statusOptions = ['All Status', 'Available', 'Fostered', 'Adopted', 'Pending'];
  final List<String> _shelterOptions = ['All Shelters', 'Happy Paws', 'Animal Rescue', 'Safe Haven'];

  @override
  void initState() {
    super.initState();
    _future = ApiService.getAnimals();
  }

  void _refresh() {
    setState(() {
      _future = ApiService.getAnimals(query: _buildQueryParameters());
    });
    widget.onRefresh?.call(); // Notify parent to refresh stats
  }

  Map<String, String>? _buildQueryParameters() {
    final params = <String, String>{};
    
    if (_query.isNotEmpty) {
      params['search'] = _query;
    }
    if (_selectedSpecies != 'All Species') {
      params['species'] = _selectedSpecies;
    }
    if (_selectedStatus != 'All Status') {
      params['status'] = _selectedStatus.toLowerCase();
    }
    if (_selectedShelter != 'All Shelters') {
      params['shelter'] = _selectedShelter;
    }
    
    return params.isEmpty ? null : params;
  }

  void _search(String q) {
    setState(() {
      _query = q.trim();
      _future = ApiService.getAnimals(query: _buildQueryParameters());
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
    // In a real app, this would call your API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application submitted for ${animal.name}!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Refresh the list to potentially update status
    _refresh();
  }

  Widget _buildFilterChip({
    required String label,
    required String selectedValue,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: options.map((option) {
          final isSelected = selectedValue == option;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) => onSelected(option),
              selectedColor: primaryPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : textSecondary,
                fontSize: 14,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? primaryPurple : Colors.grey.shade300,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('PawsConnect'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search animals...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _search,
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Species Filter
                const Text('Species', style: TextStyle(fontSize: 14, color: textSecondary)),
                const SizedBox(height: 4),
                _buildFilterChip(
                  label: 'Species',
                  selectedValue: _selectedSpecies,
                  options: _speciesOptions,
                  onSelected: (value) {
                    setState(() {
                      _selectedSpecies = value;
                      _future = ApiService.getAnimals(query: _buildQueryParameters());
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Status Filter
                const Text('Status', style: TextStyle(fontSize: 14, color: textSecondary)),
                const SizedBox(height: 4),
                _buildFilterChip(
                  label: 'Status',
                  selectedValue: _selectedStatus,
                  options: _statusOptions,
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _future = ApiService.getAnimals(query: _buildQueryParameters());
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Shelter Filter
                const Text('Shelter', style: TextStyle(fontSize: 14, color: textSecondary)),
                const SizedBox(height: 4),
                _buildFilterChip(
                  label: 'Shelter',
                  selectedValue: _selectedShelter,
                  options: _shelterOptions,
                  onSelected: (value) {
                    setState(() {
                      _selectedShelter = value;
                      _future = ApiService.getAnimals(query: _buildQueryParameters());
                    });
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 20),

          // Animals List
          Expanded(
            child: FutureBuilder<List<Animal>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Error loading animals', style: TextStyle(color: textSecondary)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refresh,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final animals = snapshot.data ?? [];

                if (animals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pets, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No animals found', style: TextStyle(fontSize: 16, color: textSecondary)),
                        const SizedBox(height: 8),
                        const Text('Try adjusting your filters', style: TextStyle(color: textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSpecies = 'All Species';
                              _selectedStatus = 'All Status';
                              _selectedShelter = 'All Shelters';
                              _query = '';
                              _future = ApiService.getAnimals();
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: animals.length,
                  itemBuilder: (context, index) => AnimalCard(
                    animal: animals[index],
                    onTap: () => _navigateToAnimalDetails(animals[index]),
                    onApply: () => _showAdoptionDialog(animals[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}