// lib/screens/add_animal_screen.dart
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});
  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _species = TextEditingController();
  final _breed = TextEditingController();
  final _age = TextEditingController();
  final _description = TextEditingController();
  String _status = 'available';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _breed.dispose();
    _age.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);

    final newAnimal = Animal(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _name.text.trim(),
      species: _species.text.trim(),
      breed: _breed.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      gender: 'Unknown',
      size: 'Medium',
      description: _description.text.trim(),
      medicalNotes: null,
      status: _status,
      imageUrl: null,
      shelterId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final ok = await ApiService.createAnimal(newAnimal);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Animal created')));
        _form.currentState!.reset();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Animal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Enter name' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _species, decoration: const InputDecoration(labelText: 'Species'), validator: (v) => v == null || v.isEmpty ? 'Enter species' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _breed, decoration: const InputDecoration(labelText: 'Breed'), validator: (v) => v == null || v.isEmpty ? 'Enter breed' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _age, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Enter age' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, validator: (v) => v == null || v.isEmpty ? 'Enter description' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['available', 'fostered', 'adopted', 'pending'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v ?? 'available'),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                  child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Create animal'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
