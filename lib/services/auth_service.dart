import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:m18_residences/models/tenant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = String.fromEnvironment('API_URL');
  static const _tokenKey = 'auth_token';
  static const _tenantIdKey = 'tenant_id';

  Tenant? _cachedTenant;

  Tenant? get cachedTenant => _cachedTenant;

  Future<String?> login(String username) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': username}));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String?;
      final tenantJson = data['tenant'] as Map<String, dynamic>;

      if (token == null || token.isEmpty) {
        throw Exception('Token is missing from login response');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_tenantIdKey, tenantJson['id'].toString());

      _cachedTenant = Tenant.fromJson(tenantJson);
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tenantIdKey);
    _cachedTenant = null;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getSavedTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tenantIdKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getSavedToken();
    if (token == null || token.isEmpty) return false;
    final headers = await _getAuthHeaders();
    try {
      final response = await http.get(Uri.parse('$baseUrl/auth/validate-token'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error validating token: $e');
    }
  }

  Future<Tenant> getByTenantId(int id) async {
    final String url = '$baseUrl/tenants/$id';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Tenant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load tenant with id $id');
    }
  }
}
