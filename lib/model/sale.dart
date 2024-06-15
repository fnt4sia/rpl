import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scentco/model/inventory.dart';

class Sale {
  final String uniqueId;
  final String id;
  final String date;
  final String via;
  final Map<String, dynamic> product;
  final bool completed;
  final String imageUrl;
  final String fileExtension;
  final String noResi;
  final String penerima;

  static List listSale = [];

  Sale({
    required this.uniqueId,
    required this.id,
    required this.date,
    required this.via,
    required this.product,
    required this.completed,
    required this.imageUrl,
    required this.fileExtension,
    required this.noResi,
    required this.penerima,
  });

  static addSale(
    Map<String, dynamic> product,
    String via,
    String date,
    String imageUrl,
    String fileExtension,
    String noResi,
    String penerima,
  ) async {
    int? highestValue;
    if (listSale.isNotEmpty) {
      listSale.sort((a, b) => a.id.compareTo(b.id));
      highestValue = int.parse(listSale.last.id) + 1;
    } else {
      highestValue = 1;
    }

    final String id = highestValue.toString().padLeft(4, '0');
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/sale');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          'fields': {
            'id': {'stringValue': id},
            'product': {
              'mapValue': {
                'fields': product,
              }
            },
            'completed': {'booleanValue': false},
            'via': {'stringValue': via},
            'date': {'stringValue': date},
            'imageUrl': {'stringValue': imageUrl},
            'fileExtension': {'stringValue': fileExtension},
            'noResi': {'stringValue': noResi},
            'penerima': {'stringValue': penerima},
          },
        },
      ),
    );
    if (response.statusCode == 200) {
      Inventory.listInventory
          .where((element) => element.category == "Product")
          .forEach((element) async {
        final url = Uri.parse(
            'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/inventory/${element.uniqueId}');
        await http.patch(
          url,
          body: jsonEncode({
            'fields': {
              'name': {'stringValue': element.name},
              'category': {'stringValue': element.category},
              'stock': {
                'integerValue': (int.parse(element.stock) -
                    product[element.name]['integerValue'])
              },
              'imageUrl': {'stringValue': element.imageUrl},
            }
          }),
        );
      });
      return true;
    }
  }

  static ocrResi(FileImage image) async {
    final Uri url = Uri.parse('https://api.ocr.space/parse/image');
    http.post(
      url,
      body: {
        'apikey': 'helloworld',
        'language': 'eng',
        'isOverlayRequired': 'true',
        'base64Image': base64Encode(
          image.file.readAsBytesSync(),
        ),
      },
    );
  }

  static getSale() async {
    final url = Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/scentco-fe75a/databases/(default)/documents/sale',
      {
        'pageSize': '1000',
      },
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      listSale.clear();
      final List data = jsonDecode(response.body)['documents'] ?? [];
      data.map((data) {
        final specialId = data['name'];
        final newData = data['fields'];
        listSale.add(
          Sale(
            uniqueId: specialId.split('/').last,
            id: newData['id']['stringValue'],
            date: newData['date']['stringValue'],
            via: newData['via']['stringValue'],
            product: newData['product']['mapValue'],
            completed: newData['completed']['booleanValue'],
            imageUrl: newData['imageUrl']['stringValue'],
            fileExtension: newData['fileExtension']['stringValue'],
            noResi: newData['noResi']['stringValue'],
            penerima: newData['penerima']['stringValue'],
          ),
        );
      }).toList();
    }
  }

  static checkBox(list) async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/sale/${list.uniqueId}');
    final response = await http.patch(
      url,
      body: jsonEncode(
        {
          'fields': {
            'id': {'stringValue': list.id},
            'completed': {'booleanValue': !list.completed},
            'product': {'mapValue': list.product},
            'via': {'stringValue': list.via},
            'date': {'stringValue': list.date},
            'imageUrl': {'stringValue': list.imageUrl},
            'fileExtension': {'stringValue': list.fileExtension},
            'noResi': {'stringValue': list.noResi},
            'penerima': {'stringValue': list.penerima},
          }
        },
      ),
    );
    if (response.statusCode == 200) return true;
  }

  static Future<void> deleteSale(list) async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/sale/${list.uniqueId}');
    await http.delete(url);
  }
}
