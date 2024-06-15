import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scentco/material/custom.dart';
import 'package:scentco/model/inventory.dart';
import 'package:scentco/model/stock_model.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  DateTime? firstDate;
  DateTime? secondDate;
  String? searchDesc;
  Map<String, bool> listProduct = {};

  @override
  void initState() {
    Stock.getStock(true).then((_) {
      Inventory.getInventory().then((_) {
        for (var e in Inventory.listInventory) {
          listProduct[e.name] = true;
        }
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        drawer: CustomWidget.hamburgerMenu(context),
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  size: 36,
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text(
                  'Stock Recap',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'From',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 7),
                    InkWell(
                      onTap: () async {
                        DateTime? pickFirstDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickFirstDate != null) {
                          setState(() {
                            firstDate = pickFirstDate;
                          });
                        }
                      },
                      child: const Icon(
                        Icons.date_range,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Until',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 7),
                    InkWell(
                      onTap: () async {
                        DateTime? pickSecondDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickSecondDate != null) {
                          setState(() {
                            secondDate = pickSecondDate;
                          });
                        }
                      },
                      child: const Icon(
                        Icons.date_range,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomSheet(
                              onApply: (TextEditingController descController,
                                  Map<String, bool> tempListProduct) {
                                setState(() {
                                  searchDesc = descController.text;
                                  listProduct = tempListProduct;
                                });
                              },
                              listProduct: listProduct,
                            );
                          },
                        );
                      },
                      child: const Icon(
                        Icons.filter_alt,
                        size: 32,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Column(
                  children: !(firstDate != null && secondDate != null)
                      ? Stock.finalStock.map((data) {
                          return stockPerDate(data);
                        }).toList()
                      : Stock.finalStock
                          .where((element) =>
                              (DateFormat('d MMMM yyyy')
                                      .parse(element.date)
                                      .isAfter(firstDate!) &&
                                  DateFormat('d MMMM yyyy')
                                      .parse(element.date)
                                      .isBefore(secondDate!)) ||
                              DateFormat('d MMMM yyyy')
                                  .parse(element.date)
                                  .isAtSameMomentAs(firstDate!) ||
                              DateFormat('d MMMM yyyy')
                                  .parse(element.date)
                                  .isAtSameMomentAs(secondDate!))
                          .map((data) => stockPerDate(data))
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget stockPerDate(data) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                data['date'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Column(
            children: data['stock'] != null
                ? (data['stock'] as List<dynamic>).map(
                    (detailData) {
                      if (listProduct[detailData['product']] ?? true) {
                        if (searchDesc == null ||
                            searchDesc!.isEmpty ||
                            detailData['desc'].contains(searchDesc)) {
                          return stockDetail(detailData);
                        } else {
                          return const SizedBox();
                        }
                      } else {
                        return const SizedBox();
                      }
                    },
                  ).toList()
                : [],
          )
        ],
      ),
    );
  }

  Widget stockDetail(data) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      data['product'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: data['isAdd'] ? Colors.green : Colors.red,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    data['desc'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: data['isAdd'] ? Colors.green : Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Text(
                data['quantity'].toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: data['isAdd'] ? Colors.green : Colors.red,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomSheet extends StatefulWidget {
  final void Function(TextEditingController descController,
      Map<String, bool> tempListProduct) onApply;
  final Map<String, bool> listProduct;

  const CustomSheet(
      {required this.onApply, required this.listProduct, super.key});

  @override
  State<CustomSheet> createState() => _CustomSheetState();
}

class _CustomSheetState extends State<CustomSheet> {
  final TextEditingController searchDesc = TextEditingController();
  bool isAdd = false;
  late Map<String, bool> tempListProduct = widget.listProduct;

  void updateProduct(String product) {
    setState(() {
      widget.listProduct[product] = !widget.listProduct[product]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      child: ListView(
        children: [
          CustomWidget.customText("Description"),
          const SizedBox(height: 5),
          TextField(
            controller: searchDesc,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              labelText: "Search By Desc",
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          const SizedBox(height: 10),
          CustomWidget.customText("Product"),
          const SizedBox(height: 5),
          Column(
              children: Inventory.listInventory
                  .map((e) => rowBox(e.name, (productName) {
                        updateProduct(productName);
                      }, widget.listProduct[e.name] ?? false))
                  .toList()),
          const SizedBox(height: 15),
          InkWell(
            onTap: () {
              widget.onApply(searchDesc, tempListProduct);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Apply",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget rowBox(
      String product, void Function(String) changeValue, bool checked) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            changeValue(product);
          },
          child: Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          product,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
