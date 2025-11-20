// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal.dart';
import '../models/shelter.dart';

class ApiService {
  // For Android emulator: 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static Future<List<Animal>> getAnimals({Map<String, String>? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/animals').replace(queryParameters: query);
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        return data.map((e) => Animal.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('API ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      // For demo purposes, return mock data if API is not available
      print('API Error: $e');
      return _getMockAnimals();
    }
  }

  static Future<bool> createAnimal(Animal a) async {
    try {
      final uri = Uri.parse('$baseUrl/animals');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(a.toJson()),
      ).timeout(const Duration(seconds: 8));
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      print('Create Animal Error: $e');
      // For demo purposes, return true
      return true;
    }
  }

  static Future<List<Shelter>> getShelters() async {
    try {
      final uri = Uri.parse('$baseUrl/shelters');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        return data.map((e) => Shelter.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('API ${res.statusCode}');
      }
    } catch (e) {
      print('Get Shelters Error: $e');
      return [];
    }
  }

  // Mock data for demo purposes
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
        description: 'Luna is a friendly and energetic golden retriever who loves to play and cuddle. She gets along well with children and other dogs.',
        medicalNotes: 'Up to date on all vaccinations',
        status: 'available',
        imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
        shelterId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Animal(
        id: 2,
        name: 'Whiskers',
        species: 'Cat',
        breed: 'Siamese',
        age: 3,
        gender: 'Male',
        size: 'Medium',
        description: 'Whiskers is a calm and affectionate cat who enjoys quiet environments. He loves sitting by the window and watching birds.',
        medicalNotes: 'Neutered and vaccinated',
        status: 'available',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
        shelterId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Animal(
        id: 3,
        name: 'Max',
        species: 'Dog',
        breed: 'Labrador',
        age: 4,
        gender: 'Male',
        size: 'Large',
        description: 'Max is a loyal and protective companion. He knows basic commands and loves going for long walks.',
        medicalNotes: 'Heartworm negative',
        status: 'pending',
        imageUrl: 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=400',
        shelterId: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Animal(
        id: 4,
        name: 'Bella',
        species: 'Cat',
        breed: 'Persian',
        age: 1,
        gender: 'Female',
        size: 'Small',
        description: 'Bella is a playful kitten who loves chasing toys and taking naps in sunny spots.',
        medicalNotes: 'Too young for spaying',
        status: 'available',
        imageUrl: 'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400',
        shelterId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}