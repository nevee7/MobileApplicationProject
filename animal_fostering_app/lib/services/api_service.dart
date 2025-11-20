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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }
}
