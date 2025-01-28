import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'results_screen.dart';
import '../services/product_service.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Home page (index 1)
  late MobileScannerController _scannerController;

  // Search-related state
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  final List<String> _recentSearches = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onBarcodeScanned(BarcodeCapture barcodeCapture) {
    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first.rawValue ?? 'No barcode detected';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(barcode: barcode),
        ),
      );
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await ProductService().searchProducts(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Add to recent searches
      if (!_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.add(query);
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1 ? null : AppBar(
        title: Text(Constants.appName),
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildScanTab();
      case 1:
        return _buildHomeTab();
      case 2:
        return _buildSearchTab();
      default:
        return Container(); // Fallback
    }
  }

  Widget _buildScanTab() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onBarcodeScanned,
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return Center(
      child: Text('Home Page - Display deals and price changes here.'),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for items...',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (query) {
              setState(() {
                _searchResults = []; // Clear results while typing
              });
            },
            onSubmitted: _performSearch,
          ),
        ),
        Expanded(
          child: _searchController.text.isEmpty
              ? _buildRecentSearches()
              : _isSearching
                  ? Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(child: Text('No results found.'))
                      : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return ListView.builder(
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_recentSearches[index]),
          onTap: () {
            _searchController.text = _recentSearches[index];
            _performSearch(_recentSearches[index]);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
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
    );
  }
}