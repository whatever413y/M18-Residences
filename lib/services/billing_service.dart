import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rental_management_system_flutter/models/billing.dart';

class BillingService {
  static final String baseUrl = '${dotenv.env['API_URL']}/bills';

  Future<List<Bill>> getAllByTenantId(int tenantId) async {
    final response = await http.get(Uri.parse('$baseUrl/tenant/$tenantId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Bill.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bills for tenant $tenantId');
    }
  }

  Future<Bill> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Bill.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load bill with id $id');
    }
  }
}
