import 'package:flutter/material.dart';
import '../services/product_service.dart';
// ignore: unused_import
import '../constants.dart';

class ResultsScreen extends StatefulWidget {
  final String barcode;

  const ResultsScreen({super.key, required this.barcode});

  @override
  ResultsScreenState createState() => ResultsScreenState();
}

class ResultsScreenState extends State<ResultsScreen> {
  String _productName = 'Loading...';
  String _brand = '';
  String _imageUrl = '';
  bool _isLoading = true;
  String _errorMessage = '';

  // Mock data for store prices
  final List<Map<String, dynamic>> _storePrices = [
    {'store': 'Store A', 'price': '\$3.99'},
    {'store': 'Store B', 'price': '\$4.25'},
    {'store': 'Store C', 'price': '\$3.75'},
  ];

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
          _imageUrl = product['image_url'] ?? '';
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
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image (clickable)
                      GestureDetector(
                        onTap: () {
                          if (_imageUrl.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(imageUrl: _imageUrl),
                              ),
                            );
                          }
                        },
                        child: Hero(
                          tag: 'product-image-${widget.barcode}',
                          child: Container(
                            height: 200, // Fixed height for the image container
                            width: double.infinity,
                            color: Colors.grey[200], // Placeholder background color
                            child: _imageUrl.isNotEmpty
                                ? Image.network(
                                    _imageUrl,
                                    fit: BoxFit.cover, // Maintain aspect ratio
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage();
                                    },
                                  )
                                : _buildPlaceholderImage(),
                          ),
                        ),
                      ),
                      // Product Name and Brand
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _productName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Brand: $_brand',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Store Prices List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Prices from Stores:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _storePrices.length,
                        itemBuilder: (context, index) {
                          final store = _storePrices[index];
                          return ListTile(
                            title: Text(store['store']),
                            trailing: Text(
                              store['price'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  // Placeholder image widget
  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.image_not_supported, // Placeholder icon
        size: 100,
        color: Colors.grey[500],
      ),
    );
  }
}

// Full-screen image viewer
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the full-screen view on tap
        },
        child: Center(
          child: Hero(
            tag: 'product-image-$imageUrl', // Unique tag for Hero animation
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain, // Ensure the image fits within the screen
            ),
          ),
        ),
      ),
    );
  }
}