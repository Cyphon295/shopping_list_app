import 'package:shared_preferences/shared_preferences.dart';

class FavoriteManager {
  static const String _favoritesKey = 'favoritedProducts';

  // Add a product to favorites
  static Future<void> addFavorite(String barcode, String productName, String brand, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    final productData = '$barcode|$productName|$brand|$imageUrl';

    if (!favorites.contains(productData)) {
      favorites.add(productData);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Remove a product from favorites
  static Future<void> removeFavorite(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    favorites.removeWhere((item) => item.startsWith('$barcode|'));
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Get all favorited products
  static Future<List<Map<String, String>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    return favorites.map((item) {
      final parts = item.split('|');
      return {
        'barcode': parts[0],
        'productName': parts[1],
        'brand': parts[2],
        'imageUrl': parts[3],
      };
    }).toList();
  }

  // Check if a product is favorited
  static Future<bool> isFavorited(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.any((item) => item.startsWith('$barcode|'));
  }
}