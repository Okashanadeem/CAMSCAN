import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Replace with actual API/AI endpoint

  Future<List<Course>> fetchCourses() async {
    // In a real scenario, this would be an HTTP GET request
    // For now, I'll simulate it or use a placeholder
    try {
      // final response = await http.get(Uri.parse('$baseUrl/api/courses'));
      // if (response.statusCode == 200) {
      //   List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => Course.fromMap(json)).toList();
      // }
      
      // Simulated response
      await Future.delayed(const Duration(seconds: 1));
      return [
        Course(id: 'CS-101', name: 'Data Structures'),
        Course(id: 'CS-102', name: 'Algorithms'),
        Course(id: 'CS-103', name: 'Database Systems'),
        Course(id: 'CS-104', name: 'Software Engineering'),
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> uploadSessions(List<Map<String, dynamic>> sessionsPayload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/bulk-upload'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(sessionsPayload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
