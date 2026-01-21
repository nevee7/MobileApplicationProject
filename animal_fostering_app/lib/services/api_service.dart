import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/animal.dart';
import '../models/shelter.dart';
import '../models/adoption_application.dart';
import 'auth_service.dart';
import '../models/user.dart';
import '../models/app_notification.dart';
import '../models/report_definition.dart';
import '../models/alert_rule.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Animals
  static Future<List<Animal>> getAnimals({Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl/animals').replace(queryParameters: query);
    final response = await http.get(uri, headers: AuthService.authHeaders);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Animal.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load animals: ${response.statusCode}');
    }
  }

  static Future<Animal> getAnimal(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/animals/$id'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return Animal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load animal');
    }
  }

  static Future<bool> createAnimal(Animal animal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/animals'),
      headers: AuthService.authHeaders,
      body: jsonEncode(animal.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateAnimal(Animal animal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/animals/${animal.id}'),
      headers: AuthService.authHeaders,
      body: jsonEncode(animal.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteAnimal(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/animals/$id'),
      headers: AuthService.authHeaders,
    );

    return response.statusCode == 200;
  }

  // Shelters - LOCAL DATABASE
  static Future<List<Shelter>> getShelters({bool includeInactive = false}) async {
    final uri = Uri.parse('$baseUrl/shelters').replace(
      queryParameters: includeInactive ? {'includeInactive': 'true'} : null,
    );
    final response = await http.get(
      uri,
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Shelter.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load shelters: ${response.statusCode}');
    }
  }

  // Shelters - GOOGLE PLACES API (REAL-TIME)
  static Future<List<Shelter>> getRealSheltersFromGooglePlaces() async {
    try {
      print("Fetching shelters from Google Places API for Timisoara...");
      
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Get token from AuthService
      if (AuthService.token != null && AuthService.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${AuthService.token}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/googleplaces/shelters/timisoara'),
        headers: headers,
      );
      
      print("Google Places response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Google Places API response: ${data['message'] ?? 'No message'}");
        
        // Check if shelters data exists in the response
        if (data['shelters'] is List) {
          final List sheltersData = data['shelters'] as List;
          print("Found ${sheltersData.length} shelters from API");
          
          List<Shelter> shelters = [];
          for (var item in sheltersData) {
            try {
              final shelter = Shelter.fromJson(item);
              if (shelter.latitude != null && shelter.longitude != null) {
                shelters.add(shelter);
              }
            } catch (e) {
              print("Error parsing shelter: $e");
            }
          }

          return shelters;
        } else {
          print("No shelters data found in response");
          return [];
        }
      } else {
        print("Google Places API error: ${response.statusCode}");
        print("Response body: ${response.body}");
      }

      return [];

    } catch (e) {
      print("Exception fetching real shelters from Google Places: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> checkGooglePlacesHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/googleplaces/shelters/health'),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return {'status': 'ERROR', 'googleApiKeyConfigured': false};

    } catch (e) {
      return {'status': 'ERROR', 'googleApiKeyConfigured': false, 'error': e.toString()};
    }
  }

  // Adoption Applications
  static Future<List<AdoptionApplication>> getAdoptionApplications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => AdoptionApplication.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load adoption applications');
    }
  }

  static Future<bool> createAdoptionApplication({
    required int animalId,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'animalId': animalId,
        'message': message,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
    }

    throw Exception('Failed to submit application');
  }

  static Future<bool> updateAdoptionApplication(int id, String status, String? adminNotes) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/applications/$id/status'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'status': status,
        'adminNotes': adminNotes,
        'reviewedByAdminId': AuthService.currentUser?.id,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Map<String, dynamic>> getShelterDetails(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/shelters/$id/details'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to load shelter details');
  }

  static Future<bool> createShelter(Shelter shelter) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shelters'),
      headers: AuthService.authHeaders,
      body: jsonEncode(shelter.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateShelter(Shelter shelter) async {
    final response = await http.put(
      Uri.parse('$baseUrl/shelters/${shelter.id}'),
      headers: AuthService.authHeaders,
      body: jsonEncode(shelter.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> updateShelterStatus(int id, bool isActive) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/shelters/$id/status'),
      headers: AuthService.authHeaders,
      body: jsonEncode({'isActive': isActive}),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> deleteShelter(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/shelters/$id'),
      headers: AuthService.authHeaders,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // User Management
  static Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // For user's own applications
  static Future<List<AdoptionApplication>> getMyApplications() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/applications'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => AdoptionApplication.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  // Send message to admin/user
  static Future<bool> sendMessage({
  int? receiverId,
  required String content,
  String messageType = 'Text',
}) async {
  final headers = <String, String>{
    ...AuthService.authHeaders,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final body = {
    // Use the SAME names as the C# DTO to avoid binding issues
    'ReceiverId': receiverId,
    'Message': content,
    'MessageType': messageType,
  };

  final res = await http.post(
    Uri.parse('$baseUrl/messages'),
    headers: headers,
    body: jsonEncode(body),
  );

  // IMPORTANT: print what the server says
  debugPrint('sendMessage status: ${res.statusCode}');
  debugPrint('sendMessage body: ${res.body}');

  return res.statusCode == 200 || res.statusCode == 201;
}



  static Future<List<dynamic>> getMessages() async {
  final res = await http.get(
    Uri.parse('$baseUrl/messages'),
    headers: AuthService.authHeaders,
  );

  // If backend says "no" or anything weird -> return empty list
  if (res.statusCode != 200) return [];

  if (res.body.trim().isEmpty || res.body.trim() == "null") return [];

  final decoded = jsonDecode(res.body);

  // Your backend controller returns Ok(messages) => should be a JSON array
  if (decoded is List) return decoded;

  // In case you ever wrap it like { "messages": [...] }
  if (decoded is Map<String, dynamic> && decoded['messages'] is List) {
    return decoded['messages'] as List;
  }

  // Fallback
  return [];
}

  // Notifications
  static Future<List<AppNotification>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load notifications');
  }

  static Future<bool> markNotificationRead(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: AuthService.authHeaders,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> markAllNotificationsRead() async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: AuthService.authHeaders,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> clearNotifications() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/clear'),
      headers: AuthService.authHeaders,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // Reports
  static Future<List<ReportDefinition>> getReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => ReportDefinition.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load reports');
  }

  static Future<bool> createReport({
    required String name,
    String? description,
    required String metric,
    String? filtersJson,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'name': name,
        'description': description,
        'metric': metric,
        'filtersJson': filtersJson,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateReport({
    required int id,
    required String name,
    String? description,
    required String metric,
    String? filtersJson,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reports/$id'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'name': name,
        'description': description,
        'metric': metric,
        'filtersJson': filtersJson,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> deleteReport(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reports/$id'),
      headers: AuthService.authHeaders,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // Alerts
  static Future<List<AlertRule>> getAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => AlertRule.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load alerts');
  }

  static Future<bool> createAlert({
    required String name,
    required String metric,
    required String comparison,
    required int threshold,
    required bool isActive,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alerts'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'name': name,
        'metric': metric,
        'comparison': comparison,
        'threshold': threshold,
        'isActive': isActive,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateAlert({
    required int id,
    required String name,
    required String metric,
    required String comparison,
    required int threshold,
    required bool isActive,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/alerts/$id'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'name': name,
        'metric': metric,
        'comparison': comparison,
        'threshold': threshold,
        'isActive': isActive,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> deleteAlert(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alerts/$id'),
      headers: AuthService.authHeaders,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }




  // Update user status (activate/deactivate)
  static Future<bool> updateUserStatus(int userId, bool isActive) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/status'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'isActive': isActive,
      }),
    );

    return response.statusCode == 200;
  }

  // Update user role
  static Future<bool> updateUserRole(int userId, String role) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'role': role,
      }),
    );

    return response.statusCode == 200;
  }

  // Helper methods
  static Future<List<Shelter>> getSheltersWithFallback() async {
    try {
      // First try Google Places API for real shelters
      final googleShelters = await getRealSheltersFromGooglePlaces();
      if (googleShelters.isNotEmpty) {
        return googleShelters;
      }
      
      // Fallback to local shelters
      return await getShelters();
    } catch (e) {
      // Last resort: return empty list
      return [];
    }
  }

  // Mock data fallback
  static List<Animal> _getMockAnimals() {
    return [
      Animal(
        id: 1,
        name: 'Luna',
        species: 'Dog',
        breed: 'Golden Retriever',
        age: 2,
        gender: 'Female',
        size: 'Large',
        description: 'Luna is a friendly and energetic golden retriever who loves to play and cuddle.',
        medicalNotes: 'Up to date on all vaccinations',
        status: 'available',
        imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
        shelterId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Get application statistics
  static Future<Map<String, int>> getApplicationStats() async {
    try {
      final applications = await getAdoptionApplications();
      final pending = applications.where((a) => a.isPending).length;
      final approved = applications.where((a) => a.isApproved).length;
      final rejected = applications.where((a) => a.isRejected).length;
      final withdrawn = applications.where((a) => a.isWithdrawn).length;
      
      return {
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'withdrawn': withdrawn,
        'total': applications.length,
      };
    } catch (e) {
      return {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'withdrawn': 0,
        'total': 0,
      };
    }
  }

  // Get animal statistics
  static Future<Map<String, int>> getAnimalStats() async {
    try {
      final animals = await getAnimals();
      final available = animals.where((a) => a.status.toLowerCase() == 'available').length;
      const pending = 0;
      const adopted = 0;
      const fostered = 0;
      const total = 0;
      
      return {
        'available': available,
        'pending': pending,
        'adopted': adopted,
        'fostered': fostered,
        'total': total,
      };
    } catch (e) {
      return {
        'available': 0,
        'pending': 0,
        'adopted': 0,
        'fostered': 0,
        'total': 0,
      };
    }
  }
}
