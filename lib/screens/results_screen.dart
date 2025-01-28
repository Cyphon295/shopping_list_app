import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ResultsScreen extends StatefulWidget {
  final String barcode;

  const ResultsScreen({super.key, required this.barcode});

  @override
  ResultsScreenState createState() => ResultsScreenState();
}

class ResultsScreenState extends State<ResultsScreen> {
  String _productName = 'Loading...';
  String _brand = '';
  String _quantity = '';
  bool _isLoading = true;
  String _errorMessage = '';

  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final data = await _productService.fetchProductDetails(widget.barcode);
      if (data['status'] == 1) {
        final product = data['product'];
        setState(() {
          _productName = product['product_name'] ?? 'Unknown Product';
          _brand = product['brands'] ?? 'Unknown Brand';
          _quantity = product['quantity'] ?? 'Unknown Quantity';
          _isLoading = false;
        });
      } else {
        setState(() {
          _productName = 'Product not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Name: $_productName',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Brand: $_brand'),
                      SizedBox(height: 10),
                      Text('Quantity: $_quantity'),
                    ],
                  ),
                ),
    );
  }
}
