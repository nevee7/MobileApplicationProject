import 'package:flutter/material.dart';
import '../models/shelter.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AdminManageSheltersScreen extends StatefulWidget {
  const AdminManageSheltersScreen({super.key});

  @override
  State<AdminManageSheltersScreen> createState() => _AdminManageSheltersScreenState();
}

class _AdminManageSheltersScreenState extends State<AdminManageSheltersScreen> {
  late Future<List<Shelter>> _sheltersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _refreshShelters();
  }

  void _refreshShelters() {
    setState(() {
      _sheltersFuture = ApiService.getShelters(includeInactive: true);
    });
  }

  Future<void> _showShelterForm({Shelter? shelter}) async {
    final nameController = TextEditingController(text: shelter?.name ?? '');
    final addressController = TextEditingController(text: shelter?.address ?? '');
    final cityController = TextEditingController(text: shelter?.city ?? 'Timisoara');
    final phoneController = TextEditingController(text: shelter?.phone ?? '');
    final emailController = TextEditingController(text: shelter?.email ?? '');
    final latController = TextEditingController(
      text: shelter?.latitude?.toString() ?? '',
    );
    final lngController = TextEditingController(
      text: shelter?.longitude?.toString() ?? '',
    );
    final descriptionController = TextEditingController(text: shelter?.description ?? '');
    bool isActive = shelter?.isActive ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(shelter == null ? 'Add Shelter' : 'Edit Shelter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lngController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: isActive,
                  title: const Text('Active'),
                  onChanged: (value) => setDialogState(() => isActive = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    if (name.isEmpty || address.isEmpty) return;

    final shelterPayload = Shelter(
      id: shelter?.id ?? 0,
      name: name,
      address: address,
      city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
      phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      latitude: double.tryParse(latController.text.trim()),
      longitude: double.tryParse(lngController.text.trim()),
      description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      isActive: isActive,
      source: 'Local',
    );

    final success = shelter == null
        ? await ApiService.createShelter(shelterPayload)
        : await ApiService.updateShelter(shelterPayload);

    if (success) {
      _refreshShelters();
    }
  }

  Future<void> _confirmDelete(Shelter shelter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Shelter'),
        content: Text('Deactivate "${shelter.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteShelter(shelter.id);
      if (success) {
        _refreshShelters();
      }
    }
  }

  Future<void> _showShelterDetails(Shelter shelter) async {
    try {
      final details = await ApiService.getShelterDetails(shelter.id);
      final stats = details['stats'] as Map<String, dynamic>? ?? {};
      final animals = (details['animals'] as List<dynamic>? ?? []);

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(shelter.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address: ${shelter.address}'),
                if (shelter.phone != null) Text('Phone: ${shelter.phone}'),
                if (shelter.email != null) Text('Email: ${shelter.email}'),
                const SizedBox(height: 12),
                const Text('Stats', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Total animals: ${stats['total'] ?? 0}'),
                Text('Available: ${stats['available'] ?? 0}'),
                Text('Adopted: ${stats['adopted'] ?? 0}'),
                Text('Fostered: ${stats['fostered'] ?? 0}'),
                Text('Pending: ${stats['pending'] ?? 0}'),
                const SizedBox(height: 12),
                const Text('Animals', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (animals.isEmpty)
                  const Text('No animals assigned'),
                ...animals.map((a) {
                  final name = a['name'] ?? 'Unknown';
                  final species = a['species'] ?? 'N/A';
                  final status = a['status'] ?? 'N/A';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('$name - $species ($status)'),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shelters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshShelters,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShelterForm(),
        backgroundColor: primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search shelters...',
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _showInactive,
                  title: const Text('Show inactive shelters'),
                  onChanged: (value) => setState(() => _showInactive = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Shelter>>(
              future: _sheltersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Error loading shelters'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshShelters,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final shelters = snapshot.data ?? [];
                final filtered = shelters.where((s) {
                  if (!_showInactive && (s.isActive == false)) return false;
                  if (_searchQuery.isEmpty) return true;
                  return s.name.toLowerCase().contains(_searchQuery) ||
                      (s.city ?? '').toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No shelters found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final shelter = filtered[index];
                    final active = shelter.isActive ?? true;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(shelter.name),
                        subtitle: Text(shelter.city ?? 'Timisoara'),
                        leading: Icon(
                          Icons.location_city,
                          color: active ? primaryPurple : Colors.grey,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _statusChip(active),
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () => _showShelterDetails(shelter),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showShelterForm(shelter: shelter),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(shelter),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool isActive) {
    final color = isActive ? Colors.green : Colors.grey;
    final label = isActive ? 'Active' : 'Inactive';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
