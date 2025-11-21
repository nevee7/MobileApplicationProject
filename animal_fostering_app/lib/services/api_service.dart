import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal.dart';
import '../models/shelter.dart';
import '../models/adoption_application.dart';
import 'auth_service.dart';

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

  // Shelters
  static Future<List<Shelter>> getShelters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/shelters'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Shelter.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load shelters');
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
      // Add more mock animals as needed
    ];
  }
}