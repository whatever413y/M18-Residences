import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:m18_residences/models/billing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  static final String baseUrl = String.fromEnvironment('API_URL');

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<List<Bill>> getAllByTenantId(int tenantId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/tenant/$tenantId'), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Bill.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching bills: $e');
      return [];
    }
  }

  Future<Bill?> getById(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/bills/$id'), headers: headers);

      if (response.statusCode == 200) {
        return Bill.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      print('Error fetching bill by ID: $e');
      return null;
    }
  }
}
