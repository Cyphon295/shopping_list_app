import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ProductService {
  // Fetch product details by barcode
  Future<Map<String, dynamic>> fetchProductDetails(String barcode) async {
    final url = Uri.parse('${Constants.productDetailsUrl}/$barcode.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  // Search for products by name
  Future<List<dynamic>> searchProducts(String query) async {
    final url = Uri.parse('${Constants.searchUrl}?search_terms=$query&page_size=10&json=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['products'];
    } else {
      throw Exception('Failed to load search results');
    }
  }
}