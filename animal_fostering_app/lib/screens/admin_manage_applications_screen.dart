import 'package:flutter/material.dart';
import '../models/adoption_application.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AdminManageApplicationsScreen extends StatefulWidget {
  const AdminManageApplicationsScreen({super.key});

  @override
  State<AdminManageApplicationsScreen> createState() => _AdminManageApplicationsScreenState();
}

class _AdminManageApplicationsScreenState extends State<AdminManageApplicationsScreen> {
  late Future<List<AdoptionApplication>> _applicationsFuture;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _refreshApplications();
  }

  void _refreshApplications() {
    setState(() {
      _applicationsFuture = ApiService.getAdoptionApplications();
    });
  }

  Future<void> _updateApplicationStatus(AdoptionApplication application, String status) async {
    try {
      final success = await ApiService.updateAdoptionApplication(
        application.id,
        status,
        application.adminNotes,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application ${status.toLowerCase()}'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshApplications();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmAndUpdate(AdoptionApplication application, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status == 'Approved' ? 'Approve' : 'Reject'} Application'),
        content: Text(
          'Are you sure you want to ${status.toLowerCase()} this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
            ),
            child: Text(status == 'Approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateApplicationStatus(application, status);
    }
  }

  void _showApplicationDetails(AdoptionApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User: ${application.user?.fullName ?? application.userId}'),
              Text('Email: ${application.user?.email ?? "N/A"}'),
              Text('Animal: ${application.animal?.name ?? application.animalId}'),
              const SizedBox(height: 16),
              if (application.message != null) ...[
                const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(application.message!),
                const SizedBox(height: 16),
              ],
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(application.status),
              const SizedBox(height: 16),
              Text('Applied: ${application.applicationDate.toLocal()}'),
              if (application.reviewedDate != null) ...[
                Text('Reviewed: ${application.reviewedDate!.toLocal()}'),
              ],
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
  }

  void _showAdminNotesDialog(AdoptionApplication application) {
    final controller = TextEditingController(text: application.adminNotes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Notes'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add notes for this application...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await ApiService.updateAdoptionApplication(
                  application.id,
                  application.status,
                  controller.text.trim().isEmpty ? null : controller.text.trim(),
                );
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notes updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _refreshApplications();
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption Applications'),
        actions: [
          IconButton(
            onPressed: _refreshApplications,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Statuses')),
              const PopupMenuItem(value: 'Pending', child: Text('Pending')),
              const PopupMenuItem(value: 'Approved', child: Text('Approved')),
              const PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<AdoptionApplication>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error loading applications'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshApplications,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final applications = snapshot.data ?? [];
          final filteredApplications = _filterStatus == 'All'
              ? applications
              : applications.where((a) => a.status == _filterStatus).toList();

          if (filteredApplications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_filterStatus.toLowerCase() == 'all' ? '' : '${_filterStatus.toLowerCase()} '}applications',
                    style: const TextStyle(fontSize: 18, color: textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredApplications.length,
            itemBuilder: (context, index) {
              final application = filteredApplications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        application.animal?.name ?? 'Animal ${application.animalId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Applicant: ${application.user?.fullName ?? "User ${application.userId}"}'),
                          Text('Status: ${application.status}'),
                          Text('Applied: ${application.applicationDate.toLocal().toString().split(' ')[0]}'),
                        ],
                      ),
                      trailing: _buildStatusChip(application.status),
                      onTap: () => _showApplicationDetails(application),
                      onLongPress: () => _showAdminNotesDialog(application),
                    ),
                    if (application.isPending)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _confirmAndUpdate(application, 'Rejected'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _confirmAndUpdate(application, 'Approved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
      case 'rejected':
        color = Colors.red;
      case 'pending':
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
