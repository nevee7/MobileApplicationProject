import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal.dart';
import '../models/shelter.dart';
import '../models/adoption_application.dart';
import 'auth_service.dart';
import '../models/user.dart';

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
  static Future<List<Shelter>> getShelters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/shelters'),
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

  static Future<bool> createAdoptionApplication(AdoptionApplication application) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: AuthService.authHeaders,
      body: jsonEncode(application.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateAdoptionApplication(int id, String status, String? adminNotes) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/$id'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'status': status,
        'adminNotes': adminNotes,
      }),
    );

    return response.statusCode == 200;
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
}