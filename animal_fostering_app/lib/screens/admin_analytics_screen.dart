import 'package:flutter/material.dart';
import '../models/report_definition.dart';
import '../models/alert_rule.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ReportDefinition>> _reportsFuture;
  late Future<List<AlertRule>> _alertsFuture;

  final List<String> _reportMetrics = const [
    'ApplicationsSummary',
    'AnimalsByStatus',
    'SheltersSummary',
  ];

  final List<String> _alertMetrics = const [
    'PendingApplications',
    'ApprovedApplications',
    'NewMessages',
  ];

  final List<String> _alertComparisons = const [
    'GreaterThan',
    'LessThan',
    'EqualTo',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshReports();
    _refreshAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshReports() {
    setState(() {
      _reportsFuture = ApiService.getReports();
    });
  }

  void _refreshAlerts() {
    setState(() {
      _alertsFuture = ApiService.getAlerts();
    });
  }

  Future<void> _showReportDialog({ReportDefinition? report}) async {
    final nameController = TextEditingController(text: report?.name ?? '');
    final descriptionController = TextEditingController(text: report?.description ?? '');
    final filtersController = TextEditingController(text: report?.filtersJson ?? '');
    String metric = report?.metric ?? _reportMetrics.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report == null ? 'Create Report' : 'Edit Report'),
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
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: metric,
                decoration: const InputDecoration(labelText: 'Metric'),
                items: _reportMetrics
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) metric = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: filtersController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Filters JSON (optional)',
                ),
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
    );

    if (saved != true) return;

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final filters = filtersController.text.trim();
    if (name.isEmpty) return;

    final success = report == null
        ? await ApiService.createReport(
            name: name,
            description: description.isEmpty ? null : description,
            metric: metric,
            filtersJson: filters.isEmpty ? null : filters,
          )
        : await ApiService.updateReport(
            id: report.id,
            name: name,
            description: description.isEmpty ? null : description,
            metric: metric,
            filtersJson: filters.isEmpty ? null : filters,
          );

    if (success) {
      _refreshReports();
    }
  }

  Future<void> _showAlertDialog({AlertRule? alert}) async {
    final nameController = TextEditingController(text: alert?.name ?? '');
    final thresholdController = TextEditingController(
      text: alert?.threshold.toString() ?? '',
    );
    String metric = alert?.metric ?? _alertMetrics.first;
    String comparison = alert?.comparison ?? _alertComparisons.first;
    bool isActive = alert?.isActive ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(alert == null ? 'Create Alert' : 'Edit Alert'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: metric,
                  decoration: const InputDecoration(labelText: 'Metric'),
                  items: _alertMetrics
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => metric = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: comparison,
                  decoration: const InputDecoration(labelText: 'Comparison'),
                  items: _alertComparisons
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => comparison = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Threshold'),
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
    final threshold = int.tryParse(thresholdController.text.trim());
    if (name.isEmpty || threshold == null) return;

    final success = alert == null
        ? await ApiService.createAlert(
            name: name,
            metric: metric,
            comparison: comparison,
            threshold: threshold,
            isActive: isActive,
          )
        : await ApiService.updateAlert(
            id: alert.id,
            name: name,
            metric: metric,
            comparison: comparison,
            threshold: threshold,
            isActive: isActive,
          );

    if (success) {
      _refreshAlerts();
    }
  }

  Future<void> _confirmDeleteReport(ReportDefinition report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Delete "${report.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteReport(report.id);
      if (success) {
        _refreshReports();
      }
    }
  }

  Future<void> _confirmDeleteAlert(AlertRule alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Delete "${alert.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteAlert(alert.id);
      if (success) {
        _refreshAlerts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshReports();
              _refreshAlerts();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Reports'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showReportDialog();
          } else {
            _showAlertDialog();
          }
        },
        backgroundColor: primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildAlertsTab(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return FutureBuilder<List<ReportDefinition>>(
      future: _reportsFuture,
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
                const Text('Error loading reports'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refreshReports,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Text(
              'No reports yet',
              style: TextStyle(color: textSecondary.withOpacity(0.8)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(report.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.description?.isNotEmpty == true)
                      Text(report.description!),
                    Text('Metric: ${report.metric}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showReportDialog(report: report),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteReport(report),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    return FutureBuilder<List<AlertRule>>(
      future: _alertsFuture,
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
                const Text('Error loading alerts'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refreshAlerts,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final alerts = snapshot.data ?? [];
        if (alerts.isEmpty) {
          return Center(
            child: Text(
              'No alerts yet',
              style: TextStyle(color: textSecondary.withOpacity(0.8)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(alert.name),
                subtitle: Text(
                  '${alert.metric} ${_comparisonLabel(alert.comparison)} ${alert.threshold}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      alert.isActive ? Icons.check_circle : Icons.pause_circle,
                      color: alert.isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAlertDialog(alert: alert),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteAlert(alert),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _comparisonLabel(String comparison) {
    switch (comparison) {
      case 'GreaterThan':
        return '>';
      case 'LessThan':
        return '<';
      case 'EqualTo':
        return '=';
      default:
        return comparison;
    }
  }
}
