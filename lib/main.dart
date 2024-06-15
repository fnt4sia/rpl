import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scentco/firebase_options.dart';
import 'package:scentco/pages/export/export.dart';
import 'package:scentco/pages/stock/stock_page.dart';
import 'pages/login/login.dart';
import 'pages/retail/retail.dart';
import 'pages/retail/add_retail.dart';
import 'pages/retail/detail_retail.dart';
import 'pages/inventory/inventory.dart';
import 'pages/inventory/edit_inventory.dart';
import 'pages/inventory/add_material.dart';
import 'model/sale.dart';
import 'model/inventory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        if (settings.name == "/detail") {
          final list = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return DetailRetailPage(
                list: list as Sale,
              );
            },
          );
        } else if (settings.name == "/edit") {
          final data = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return EditInventoryPage(
                data: data as Inventory,
              );
            },
          );
        } else {
          return null;
        }
      },
      routes: {
        '/': (context) => const RetailPage(),
        '/login': (context) => const LoginPage(),
        '/stock': (context) => const StockPage(),
        '/add': (context) => const AddRetailPage(),
        '/inventory': (context) => const InventoryPage(),
        '/addinventory': (context) => const AddInventoryPage(),
        '/export': (context) => const ExportPage(),
      },
    );
  }
}
