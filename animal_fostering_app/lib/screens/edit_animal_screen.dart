import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/api_service.dart';
import '../theme.dart';

class EditAnimalScreen extends StatefulWidget {
  final Animal animal;

  const EditAnimalScreen({super.key, required this.animal});

  @override
  State<EditAnimalScreen> createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _descriptionController;
  late TextEditingController _medicalNotesController;
  late String _gender;
  late String _size;
  late String _status;
  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.animal.name);
    _speciesController = TextEditingController(text: widget.animal.species);
    _breedController = TextEditingController(text: widget.animal.breed);
    _ageController = TextEditingController(text: widget.animal.age.toString());
    _descriptionController = TextEditingController(text: widget.animal.description);
    _medicalNotesController = TextEditingController(text: widget.animal.medicalNotes ?? '');
    _gender = widget.animal.gender;
    _size = widget.animal.size ?? 'Medium';
    _status = widget.animal.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _updateAnimal() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final updatedAnimal = Animal(
      id: widget.animal.id,
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _gender,
      size: _size,
      description: _descriptionController.text.trim(),
      medicalNotes: _medicalNotesController.text.trim().isEmpty ? null : _medicalNotesController.text.trim(),
      status: _status,
      imageUrl: widget.animal.imageUrl,
      shelterId: widget.animal.shelterId,
      createdAt: widget.animal.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      final success = await ApiService.updateAnimal(updatedAnimal);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Animal updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update animal'),
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAnimal() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Animal'),
        content: Text('Are you sure you want to delete ${widget.animal.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isDeleting = true);
              
              try {
                final success = await ApiService.deleteAnimal(widget.animal.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.animal.name} deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete animal'),
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
              } finally {
                setState(() => _isDeleting = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Animal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAnimal,
            tooltip: 'Delete Animal',
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _speciesController,
                      decoration: const InputDecoration(labelText: 'Species'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter species' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(labelText: 'Breed'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter breed' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter age';
                        final age = int.tryParse(v);
                        if (age == null || age < 0) return 'Enter valid age';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      items: ['Unknown', 'Male', 'Female']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v ?? 'Unknown'),
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _size,
                      items: ['Small', 'Medium', 'Large']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _size = v ?? 'Medium'),
                      decoration: const InputDecoration(labelText: 'Size'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _medicalNotesController,
                      decoration: const InputDecoration(labelText: 'Medical Notes (optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _status,
                      items: ['available', 'fostered', 'adopted', 'pending']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? 'available'),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateAnimal,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Update Animal', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}