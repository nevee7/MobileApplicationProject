import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<List<Animal>> getAnimals() async {
    final response = await http.get(Uri.parse('$baseUrl/animals'));
    
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Animal.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load animals');
    }
  }

  static Future<Animal> getAnimal(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/animals/$id'));
    
    if (response.statusCode == 200) {
      return Animal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load animal');
    }
  }

  static Future<Animal> createAnimal(Animal animal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/animals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(animal.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Animal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create animal');
    }
  }

  static Future<void> updateAnimal(Animal animal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/animals/${animal.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(animal.toJson()),
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to update animal');
    }
  }

  static Future<void> deleteAnimal(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/animals/$id'));
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete animal');
    }
  }
}