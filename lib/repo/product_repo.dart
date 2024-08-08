import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';

class ProductRepo {
  Future<Map<String, dynamic>> fetchProducts(int value) async {
    final response = await http.get(Uri.parse('${AppConstants.BASE_URL}/get/products'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}