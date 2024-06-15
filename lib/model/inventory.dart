import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class Inventory {
  String uniqueId;
  String name;
  String category;
  String stock;
  String imageUrl;

  static List listInventory = [];

  Inventory({
    required this.uniqueId,
    required this.name,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  static addInventory(
      String name, String category, int stock, String imageUrl) async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/inventory');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'fields': {
            'name': {'stringValue': name},
            'category': {'stringValue': category},
            'stock': {'integerValue': stock},
            'imageUrl': {'stringValue': imageUrl},
          },
        },
      ),
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static getInventory() async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/inventory');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      listInventory.clear();
      final List data = jsonDecode(response.body)['documents'] ?? [];

      data.map((data) {
        final uniqueId = data['name'];
        final newData = data['fields'];

        listInventory.add(
          Inventory(
            uniqueId: uniqueId.split('/').last,
            name: newData['name']['stringValue'],
            category: newData['category']['stringValue'],
            stock: (newData['stock']['integerValue']),
            imageUrl: (newData['imageUrl']['stringValue']),
          ),
        );
      }).toList();
    }
  }

  static editInventory(Inventory item) async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/inventory/${item.uniqueId}');
    final response = await http.patch(
      url,
      body: jsonEncode(
        {
          'fields': {
            'name': {'stringValue': item.name},
            'category': {'stringValue': item.category},
            'stock': {'integerValue': int.parse(item.stock)},
            'imageUrl': {'stringValue': item.imageUrl},
          },
        },
      ),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static deleteInventory(Inventory item) async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/inventory/${item.uniqueId}');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference oldImage = storage.refFromURL(item.imageUrl);
      await oldImage.delete();
      return true;
    }
  }
}
