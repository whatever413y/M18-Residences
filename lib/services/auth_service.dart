import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:m18_residences/models/tenant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _tenantIdKey = 'tenant_id';

  Tenant? _cachedTenant;
  Tenant? get cachedTenant => _cachedTenant;

  Future<String?> login(String username) async {
    try {
      final url = Uri.parse('${dotenv.env['API_URL']}/auth/login');
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': username}))
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        final tenantJson = data['tenant'] as Map<String, dynamic>?;
        if (token == null || tenantJson == null) return null;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_tenantIdKey, tenantJson['id'].toString());

        _cachedTenant = Tenant.fromJson(tenantJson);
        return token;
      }

      return null;
    } on TimeoutException {
      throw TimeoutException('Request timed out.');
    } on SocketException {
      throw SocketException('No internet connection');
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
    final token = prefs.getString(_tokenKey);
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
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/auth/validate-token'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  Future<Tenant?> getByTenantId(int id) async {
    try {
      final url = '${dotenv.env['API_URL']}/tenants/$id';
      final response = await http.get(Uri.parse(url), headers: await _getAuthHeaders());
      if (response.statusCode == 200) {
        return Tenant.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching tenant by ID: $e');
      return null;
    }
  }

  Future<String?> fetchReceiptUrl(String tenantId, String filename) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('${dotenv.env['API_URL']}/auth/receipts/$tenantId/$filename');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String?;
    } else {
      print('Error fetching receipt URL: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
