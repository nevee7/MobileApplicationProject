import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/api_service.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _status = 'available';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Animal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Enter name' : null),
              TextFormField(controller: _speciesController, decoration: const InputDecoration(labelText: 'Species'), validator: (v) => v!.isEmpty ? 'Enter species' : null),
              TextFormField(controller: _breedController, decoration: const InputDecoration(labelText: 'Breed'), validator: (v) => v!.isEmpty ? 'Enter breed' : null),
              TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Enter age' : null),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Enter description' : null),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['available','fostered','adopted','pending'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
  if (_formKey.currentState!.validate()) {
    final newAnimal = Animal(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      species: _speciesController.text,
      breed: _breedController.text,
      age: int.parse(_ageController.text),
      gender: 'Unknown',
      size: 'Medium',
      description: _descriptionController.text,
      status: _status,
      imageUrl: '',
      shelterId: 1, // int
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ApiService.createAnimal(newAnimal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Animal added')),
    );

    _formKey.currentState!.reset();
  }
}

}
