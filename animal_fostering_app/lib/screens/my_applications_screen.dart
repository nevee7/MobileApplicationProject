import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/adoption_application.dart';
import '../theme.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late Future<List<AdoptionApplication>> _applicationsFuture;

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

  void _showApplicationDetails(AdoptionApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Animal: ${application.animal?.name ?? "Unknown"}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Species', application.animal?.species ?? 'N/A'),
              _buildDetailRow('Breed', application.animal?.breed ?? 'N/A'),
              _buildDetailRow('Age', '${application.animal?.age ?? 0} years'),
              const SizedBox(height: 16),
              const Text('Application Info:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailRow('Status', application.status),
              _buildDetailRow('Applied on', application.applicationDate.toLocal().toString().split(' ')[0]),
              if (application.reviewedDate != null)
                _buildDetailRow('Reviewed on', application.reviewedDate!.toLocal().toString().split(' ')[0]),
              if (application.message != null) ...[
                const SizedBox(height: 12),
                const Text('Your Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(application.message!),
              ],
              if (application.adminNotes != null) ...[
                const SizedBox(height: 12),
                const Text('Admin Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(application.adminNotes!),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (application.status == 'Pending')
            ElevatedButton(
              onPressed: () => _withdrawApplication(application),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Withdraw'),
            ),
        ],
      ),
    );
  }

  Future<void> _withdrawApplication(AdoptionApplication application) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: const Text('Are you sure you want to withdraw this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              Navigator.pop(context); // Close details dialog
              
              try {
                final success = await ApiService.updateAdoptionApplication(
                  application.id,
                  'Withdrawn',
                  'Application withdrawn by user',
                );
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Application withdrawn'),
                      backgroundColor: Colors.orange,
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'withdrawn':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshApplications,
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Error loading applications'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refreshApplications,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 100,
                    color: primaryPurple.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Applications Yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Apply for adoption to see your applications here',
                    style: TextStyle(
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/animals');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                    child: const Text('Browse Animals'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: application.animal?.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            application.animal!.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.pets,
                            color: primaryPurple,
                            size: 30,
                          ),
                        ),
                  title: Text(
                    application.animal?.name ?? 'Unknown Animal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Status: ${application.status}'),
                      Text('Applied: ${application.applicationDate.toLocal().toString().split(' ')[0]}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(application.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(application.status).withOpacity(0.3)),
                    ),
                    child: Text(
                      application.status,
                      style: TextStyle(
                        color: _getStatusColor(application.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => _showApplicationDetails(application),
                ),
              );
            },
          );
        },
      ),
    );
  }
}