import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // your backend URL

  // CREATE a new animal
  static Future<bool> createAnimal(Animal animal) async {
    final url = Uri.parse('$baseUrl/animals');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(animal.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create animal: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  // Optional: fetch all animals
  static Future<List<Animal>> getAnimals() async {
    final url = Uri.parse('$baseUrl/animals');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Animal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load animals');
    }
  }
}
