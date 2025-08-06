import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';

class TenantService {
  static final String baseUrl = '${dotenv.env['API_URL']}/tenants/tenant/name';
  Future<Tenant> getByTenantName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/$name'));

    if (response.statusCode == 200) {
      return Tenant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load tenant with name $name');
    }
  }
}
