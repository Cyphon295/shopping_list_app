import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'results_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  SearchResultsScreenState createState() => SearchResultsScreenState();
}

class SearchResultsScreenState extends State<SearchResultsScreen> {
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    try {
      final results = await _productService.searchProducts(widget.searchQuery);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
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
        title: Text('Search Results'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _searchResults.isEmpty
                  ? Center(child: Text('No results found.'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final product = _searchResults[index];
                        return ListTile(
                          title: Text(product['product_name'] ?? 'Unknown Product'),
                          subtitle: Text(product['brands'] ?? 'Unknown Brand'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultsScreen(barcode: product['code']),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
