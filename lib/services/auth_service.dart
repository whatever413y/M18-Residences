import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _tenantIdKey = 'tenant_id';

  Future<String?> login(String username, String tenantId) async {
    if (username.isNotEmpty) {
      final token = 'dummy_token_123';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_tenantIdKey, tenantId);
      return token;
    }
    return null;
  }

  //   Future<String?> login(String username) async {
  //   final response = await http.post(
  //     Uri.parse('${dotenv.env['API_URL']}/auth/login'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'username': username}),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final token = data['token'];
  //     final tenantId = data['tenant']['id'].toString();

  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString(_tokenKey, token);
  //     await prefs.setString(_tenantIdKey, tenantId);
  //     return token;
  //   } else {
  //     throw Exception('Login failed: ${response.body}');
  //   }
  // }

  // Logout – clears token and tenant ID
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tenantIdKey);
  }

  // Get saved token (if any)
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get saved tenant ID (if any)
  Future<String?> getSavedTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tenantIdKey);
  }

  // Check if user is authenticated (token exists)
  Future<bool> isAuthenticated() async {
    final token = await getSavedToken();
    return token != null;
  }

  Future<Tenant> getByTenantName(String name) async {
    final String baseUrl = '${dotenv.env['API_URL']}/tenants/tenant/name';
    final response = await http.get(Uri.parse('$baseUrl/$name'));

    if (response.statusCode == 200) {
      return Tenant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load tenant with name $name');
    }
  }
}
