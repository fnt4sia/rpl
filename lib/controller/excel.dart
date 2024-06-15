import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scentco/model/sale.dart';
import 'package:scentco/model/stock_model.dart';
import 'package:path/path.dart';

class ExcelController {
  final bool isRecapStock;
  final bool isRecapSales;
  final DateTime dateFirst;
  final DateTime dateLast;
  final String stockDescription;
  final String stockType;
  final Map<String, bool> listProductStock;

  final String penerima;
  final Map<String, bool> listProvider;

  ExcelController({
    required this.isRecapStock,
    required this.isRecapSales,
    required this.dateFirst,
    required this.dateLast,
    required this.stockDescription,
    required this.stockType,
    required this.listProductStock,
    required this.penerima,
    required this.listProvider,
  });

  Future<void> createExcel() async {
    var excel = Excel.createExcel();
    excel.delete('Sheet1');

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/excel_${DateTime.now()}.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!, flush: true);

    await Sale.getSale();
    await Stock.getStock(false);

    if (isRecapStock) {
      Sheet stockSheet = excel['Recap Stock'];
      stockSheet.appendRow([
        const TextCellValue('Tanggal'),
        const TextCellValue('Deskripsi'),
        const TextCellValue('Tipe'),
        const TextCellValue('Produk'),
        const TextCellValue('Jumlah'),
      ]);

      List<Stock> tempListStock = Stock.listStock
          .where((element) =>
              DateFormat('d MMMM yyyy')
                  .parse(element.date)
                  .isAfter(dateFirst) &&
              DateFormat('d MMMM yyyy').parse(element.date).isBefore(dateLast))
          .toList();

      if (stockDescription.isNotEmpty) {
        tempListStock = tempListStock
            .where((element) => element.desc == stockDescription)
            .toList();
      }

      if (stockType == "Masuk") {
        tempListStock =
            tempListStock.where((element) => element.isAdd).toList();
      } else if (stockType == "Keluar") {
        tempListStock =
            tempListStock.where((element) => !element.isAdd).toList();
      }

      listProductStock.forEach((key, value) {
        if (!value) {
          tempListStock.removeWhere((element) => element.product == key);
        }
      });

      for (var stock in tempListStock) {
        stockSheet.appendRow([
          TextCellValue(stock.date),
          TextCellValue(stock.desc),
          TextCellValue(stock.isAdd ? 'Masuk' : 'Keluar'),
          TextCellValue(stock.product),
          TextCellValue((stock.quantity).toString()),
        ]);
      }
    }

    if (isRecapSales) {
      Sheet salesSheet = excel['Recap Sales'];
      salesSheet.appendRow([
        const TextCellValue('Tanggal'),
        const TextCellValue('Penerima'),
        const TextCellValue('Provider'),
        for (var product in listProductStock.keys)
          if (listProductStock[product]!) TextCellValue(product),
        const TextCellValue('Gambar Resi'),
        const TextCellValue('No Resi'),
      ]);

      List tempListSale = Sale.listSale
          .where((element) =>
              DateFormat('d MMMM yyyy')
                  .parse(element.date)
                  .isAfter(dateFirst) &&
              DateFormat('d MMMM yyyy').parse(element.date).isBefore(dateLast))
          .toList();

      if (penerima.isNotEmpty) {
        tempListSale = tempListSale
            .where((element) => element.penerima == penerima)
            .toList();
      }

      listProvider.forEach((key, value) {
        if (!value) {
          tempListSale =
              tempListSale.where((element) => element.via != key).toList();
        }
      });

      for (var sale in tempListSale) {
        salesSheet.appendRow([
          TextCellValue(sale.date),
          TextCellValue(sale.penerima),
          TextCellValue(sale.via),
          for (var product in listProductStock.keys)
            if (listProductStock[product]!)
              TextCellValue(sale.product[product]),
          TextCellValue(sale.imageUrl),
          TextCellValue(sale.noResi),
        ]);
      }
    }

    Future.value(excel.encode()).then((onValue) {
      if (onValue != null) {
        File(join(file.path))
          ..createSync(recursive: true)
          ..writeAsBytesSync(onValue);
      }
    });

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child('excels/excel_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await ref.putFile(file);
  }
}
