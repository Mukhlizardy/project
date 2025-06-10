import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalDatabase {
  static const String _keyCartHistory = 'cart_history';
  static const String _keyCartData = 'cart_data_';
  static const int _maxHistoryItems =
      50; // Limit untuk mencegah storage overflow

  // === CART HISTORY METHODS ===

  /// Menambahkan cart ID ke history
  static Future<void> addToCartHistory(int cartId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? cartHistoryStrings = prefs.getStringList(_keyCartHistory);
      List<int> cartHistory =
          cartHistoryStrings?.map((id) => int.parse(id)).toList() ?? [];

      // Hindari duplikasi
      if (!cartHistory.contains(cartId)) {
        cartHistory.add(cartId);

        // Batasi jumlah item dalam history
        if (cartHistory.length > _maxHistoryItems) {
          // Hapus item terlama
          List<int> removedItems =
              cartHistory.sublist(0, cartHistory.length - _maxHistoryItems);
          cartHistory =
              cartHistory.sublist(cartHistory.length - _maxHistoryItems);

          // Hapus data cart yang sudah tidak diperlukan
          for (int removedId in removedItems) {
            await _removeCartData(removedId);
          }
        }

        // Simpan kembali ke SharedPreferences
        List<String> cartHistoryStrings =
            cartHistory.map((id) => id.toString()).toList();
        await prefs.setStringList(_keyCartHistory, cartHistoryStrings);
      }
    } catch (e) {
      print('Error adding cart to history: $e');
      throw Exception('Failed to add cart to history');
    }
  }

  /// Mengambil daftar cart ID dari history
  static Future<List<int>> getCartHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? cartHistoryStrings = prefs.getStringList(_keyCartHistory);
      return cartHistoryStrings?.map((id) => int.parse(id)).toList() ?? [];
    } catch (e) {
      print('Error getting cart history: $e');
      return [];
    }
  }

  /// Menghapus cart dari history
  static Future<void> removeFromCartHistory(int cartId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? cartHistoryStrings = prefs.getStringList(_keyCartHistory);
      List<int> cartHistory =
          cartHistoryStrings?.map((id) => int.parse(id)).toList() ?? [];

      if (cartHistory.contains(cartId)) {
        cartHistory.remove(cartId);

        // Update SharedPreferences
        List<String> updatedHistoryStrings =
            cartHistory.map((id) => id.toString()).toList();
        await prefs.setStringList(_keyCartHistory, updatedHistoryStrings);

        // Hapus data cart terkait
        await _removeCartData(cartId);
      }
    } catch (e) {
      print('Error removing cart from history: $e');
      throw Exception('Failed to remove cart from history');
    }
  }

  /// Membersihkan seluruh history
  static Future<void> clearCartHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Ambil daftar cart yang akan dihapus
      List<int> cartHistory = await getCartHistory();

      // Hapus semua data cart
      for (int cartId in cartHistory) {
        await _removeCartData(cartId);
      }

      // Hapus history list
      await prefs.remove(_keyCartHistory);
    } catch (e) {
      print('Error clearing cart history: $e');
      throw Exception('Failed to clear cart history');
    }
  }

  /// Mengecek apakah cart ID ada dalam history
  static Future<bool> isCartInHistory(int cartId) async {
    try {
      List<int> cartHistory = await getCartHistory();
      return cartHistory.contains(cartId);
    } catch (e) {
      print('Error checking cart in history: $e');
      return false;
    }
  }

  /// Mendapatkan jumlah item dalam history
  static Future<int> getHistoryCount() async {
    try {
      List<int> cartHistory = await getCartHistory();
      return cartHistory.length;
    } catch (e) {
      print('Error getting history count: $e');
      return 0;
    }
  }

  // === CART DATA METHODS ===

  /// Menyimpan data cart lengkap untuk akses offline
  static Future<void> saveCartData(
      int cartId, Map<String, dynamic> cartData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cartDataJson = json.encode(cartData);
      await prefs.setString('$_keyCartData$cartId', cartDataJson);
    } catch (e) {
      print('Error saving cart data: $e');
      throw Exception('Failed to save cart data');
    }
  }

  /// Mengambil data cart yang disimpan secara lokal
  static Future<Map<String, dynamic>?> getCartData(int cartId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cartDataJson = prefs.getString('$_keyCartData$cartId');

      if (cartDataJson != null) {
        return json.decode(cartDataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting cart data: $e');
      return null;
    }
  }

  /// Menghapus data cart tertentu
  static Future<void> _removeCartData(int cartId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyCartData$cartId');
    } catch (e) {
      print('Error removing cart data: $e');
    }
  }

  /// Mendapatkan semua data cart yang tersimpan
  static Future<Map<int, Map<String, dynamic>>> getAllCartData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      Map<int, Map<String, dynamic>> allCartData = {};

      for (String key in keys) {
        if (key.startsWith(_keyCartData)) {
          String cartIdString = key.substring(_keyCartData.length);
          int? cartId = int.tryParse(cartIdString);

          if (cartId != null) {
            String? cartDataJson = prefs.getString(key);
            if (cartDataJson != null) {
              try {
                Map<String, dynamic> cartData = json.decode(cartDataJson);
                allCartData[cartId] = cartData;
              } catch (e) {
                print('Error parsing cart data for ID $cartId: $e');
                // Hapus data yang rusak
                await prefs.remove(key);
              }
            }
          }
        }
      }

      return allCartData;
    } catch (e) {
      print('Error getting all cart data: $e');
      return {};
    }
  }

  // === UTILITY METHODS ===

  /// Membersihkan data yang rusak atau tidak valid
  static Future<void> cleanupInvalidData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      List<String> keysToRemove = [];

      for (String key in keys) {
        if (key.startsWith(_keyCartData)) {
          String? cartDataJson = prefs.getString(key);
          if (cartDataJson != null) {
            try {
              json.decode(cartDataJson);
            } catch (e) {
              // Data rusak, tandai untuk dihapus
              keysToRemove.add(key);
            }
          }
        }
      }

      // Hapus data yang rusak
      for (String key in keysToRemove) {
        await prefs.remove(key);
      }

      print('Cleaned up ${keysToRemove.length} invalid data entries');
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  /// Mendapatkan ukuran storage yang digunakan (perkiraan)
  static Future<int> getStorageSize() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      int totalSize = 0;

      for (String key in keys) {
        if (key.startsWith(_keyCartHistory) || key.startsWith(_keyCartData)) {
          String? value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }

      return totalSize;
    } catch (e) {
      print('Error calculating storage size: $e');
      return 0;
    }
  }

  /// Export data untuk backup
  static Future<Map<String, dynamic>> exportData() async {
    try {
      List<int> cartHistory = await getCartHistory();
      Map<int, Map<String, dynamic>> allCartData = await getAllCartData();

      return {
        'cartHistory': cartHistory,
        'cartData': allCartData,
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error exporting data: $e');
      throw Exception('Failed to export data');
    }
  }

  /// Import data dari backup
  static Future<void> importData(Map<String, dynamic> backupData) async {
    try {
      // Clear existing data
      await clearCartHistory();

      // Import cart history
      if (backupData['cartHistory'] != null) {
        List<dynamic> historyData = backupData['cartHistory'];
        List<int> cartHistory = historyData.cast<int>();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> cartHistoryStrings =
            cartHistory.map((id) => id.toString()).toList();
        await prefs.setStringList(_keyCartHistory, cartHistoryStrings);
      }

      // Import cart data
      if (backupData['cartData'] != null) {
        Map<String, dynamic> cartDataMap = backupData['cartData'];
        for (String cartIdString in cartDataMap.keys) {
          int? cartId = int.tryParse(cartIdString);
          if (cartId != null && cartDataMap[cartIdString] != null) {
            await saveCartData(cartId, cartDataMap[cartIdString]);
          }
        }
      }
    } catch (e) {
      print('Error importing data: $e');
      throw Exception('Failed to import data');
    }
  }
}
