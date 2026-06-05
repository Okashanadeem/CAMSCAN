import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://camscan-api.vercel.app'; 
  static const String apiKey = 'CAMSCAN_v1_Secret_Key_2026';

  Future<List<Course>> fetchCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/courses'),
        headers: {'X-API-KEY': apiKey},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Course.fromMap(json)).toList();
      }
      throw Exception('Failed to fetch courses');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> uploadSessions(List<Map<String, dynamic>> sessionsPayload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/bulk-upload'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(sessionsPayload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearRemoteData() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/clear-all'),
        headers: {'X-API-KEY': apiKey},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
