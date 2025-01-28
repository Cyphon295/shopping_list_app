import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../constants.dart';
import 'results_screen.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Home page (index 1)
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1
          ? null
          : AppBar(
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
            decoration: InputDecoration(
              hintText: 'Search for items...',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (query) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResultsScreen(searchQuery: query),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
