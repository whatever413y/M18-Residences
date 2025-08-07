import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  static final String baseUrl = '${dotenv.env['API_URL']}/bills';

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
      } else {
        throw Exception('Failed to load bills for tenant $tenantId');
      }
    } catch (e) {
      throw Exception('Error fetching bills: $e');
    }
  }

  Future<Bill> getById(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);

      if (response.statusCode == 200) {
        return Bill.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load bill with id $id');
      }
    } catch (e) {
      throw Exception('Error fetching bill: $e');
    }
  }
}
