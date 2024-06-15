import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Stock {
  final String uniqueId;
  final String date;
  final String product;
  final String desc;
  final int quantity;
  final bool isAdd;

  static List<Stock> listStock = [];
  static List finalStock = [];

  Stock({
    required this.uniqueId,
    required this.date,
    required this.product,
    required this.desc,
    required this.quantity,
    required this.isAdd,
  });

  static Future<void> updateStock(String date, String product, int quantity,
      bool isAdd, String desc) async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/stock');
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          'fields': {
            'product': {'stringValue': product},
            'quantity': {'integerValue': quantity},
            'isAdd': {'booleanValue': isAdd},
            'date': {'stringValue': date},
            'desc': {'stringValue': desc},
          }
        },
      ),
    );
  }

  Future<void> deleteStock() async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/inventory/$uniqueId');
    await http.delete(url);
  }

  static Future<void> getStock(bool getStockPage) async {
    listStock = [];
    finalStock = [];
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/stock');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['documents'] ?? [];
      data.map((element) {
        final fields = element['fields'];
        final uniqueId = element['name'];

        listStock.add(
          Stock(
            uniqueId: uniqueId,
            date: fields['date']['stringValue'],
            product: fields['product']['stringValue'],
            desc: fields['desc']['stringValue'],
            quantity: int.parse(fields['quantity']['integerValue']),
            isAdd: fields['isAdd']['booleanValue'],
          ),
        );
      }).toList();

      listStock.sort((a, b) {
        DateTime aDate = DateFormat('d MMMM yyyy').parse(a.date);
        DateTime bDate = DateFormat('d MMMM yyyy').parse(b.date);
        return bDate.compareTo(aDate);
      });

      if (getStockPage) {
        while (listStock.isNotEmpty) {
          final String keepDate = listStock[0].date;
          final List<Stock> sameDate =
              listStock.where((data) => data.date == keepDate).toList();

          List<Map<String, dynamic>> stocks = [];

          while (sameDate.isNotEmpty) {
            final String keepProduct = sameDate[0].product;
            final List<Stock> sameProduct =
                sameDate.where((data) => data.product == keepProduct).toList();

            while (sameProduct.isNotEmpty) {
              final String keepDescription = sameProduct[0].desc;
              final List<Stock> sameDescription = sameProduct
                  .where((data) => data.desc == keepDescription)
                  .toList();

              int totalQuantity = 0;

              for (var item in sameDescription) {
                totalQuantity += item.quantity;
              }

              stocks.add({
                'uniqueId': sameDescription[0].uniqueId,
                'date': keepDate,
                'product': keepProduct,
                'desc': keepDescription,
                'quantity': totalQuantity,
                'isAdd': sameDescription[0].isAdd,
              });

              sameProduct.removeWhere(
                  (deleteData) => deleteData.desc == keepDescription);
            }
            sameDate
                .removeWhere((deleteData) => deleteData.product == keepProduct);
          }

          finalStock.add({
            'date': keepDate,
            'stock': stocks,
          });

          listStock.removeWhere((deleteData) => deleteData.date == keepDate);
        }
      }
    }
  }
}
