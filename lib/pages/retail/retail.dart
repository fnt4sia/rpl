import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scentco/model/inventory.dart';
import 'package:scentco/model/stock_model.dart';
import '../../material/custom.dart';
import '../../model/sale.dart';

class RetailPage extends StatefulWidget {
  const RetailPage({super.key});

  @override
  State<RetailPage> createState() => _RetailPageState();
}

class _RetailPageState extends State<RetailPage> {
  String valueSort = 'ID';
  String? valueFilter;
  DateTime? firstDate;
  DateTime? secondDate;

  TextEditingController searchName = TextEditingController();
  TextEditingController searchNoResi = TextEditingController();

  bool isLoadingSale = true;
  late List retailListSale;

  @override
  void initState() {
    super.initState();
    Sale.getSale().then((_) {
      setState(() {
        retailListSale = Sale.listSale;
        sortList(valueSort);
        isLoadingSale = false;
      });
    });
  }

  void sortList(String sortBy) {
    if (sortBy == "ID") {
      retailListSale.sort((a, b) => a.compareTo(b.id));
    } else if (sortBy == "Completed") {
      retailListSale.sort(
          (a, b) => (a.completed == b.completed ? 0 : (a.completed ? 1 : -1)));
    } else if (sortBy == "Via") {
      retailListSale.sort((a, b) => a.via.compareTo(b.via));
    } else {
      retailListSale.sort((a, b) => DateFormat('d MMMM yyyy')
          .parse(a.date)
          .compareTo(DateFormat('d MMMM yyyy').parse(b.date)));
    }
  }

  void filterList() {
    retailListSale = [];
    if (valueFilter != null) {
      for (var i = 0; i < Sale.listSale.length; i++) {
        if (Sale.listSale[i].via.contains(valueFilter!)) {
          retailListSale.add(Sale.listSale[i]);
        }
      }
    }
    if (searchName.text.isNotEmpty) {
      for (var i = 0; i < Sale.listSale.length; i++) {
        if (Sale.listSale[i].penerima.contains(searchName.text)) {
          retailListSale.add(Sale.listSale[i]);
        }
      }
    }
    if (searchNoResi.text.isNotEmpty) {
      for (var i = 0; i < Sale.listSale.length; i++) {
        if (Sale.listSale[i].noResi.contains(searchNoResi.text)) {
          retailListSale.add(Sale.listSale[i]);
        }
      }
    }
    if (valueFilter == null &&
        searchName.text.isEmpty &&
        searchNoResi.text.isEmpty) {
      retailListSale = Sale.listSale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoadingSale
        ? const SizedBox()
        : PopScope(
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
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      const Text(
                        'Retail Sales',
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
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            "Sort By",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton(
                            underline: Container(),
                            items: <String>['ID', 'Via', 'Completed', 'Date']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                valueSort = value!;
                                sortList(valueSort);
                              });
                            },
                            value: valueSort,
                            hint: Text(valueSort),
                          ),
                          const Spacer(),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              customBottomSheet(context);
                            },
                            child: const Icon(Icons.filter_alt),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: (firstDate != null && secondDate != null)
                            ? (firstDate!.isBefore(secondDate!))
                                ? retailListSale
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
                                    .map((data) => retailDetail(data))
                                    .toList()
                                : []
                            : retailListSale.map((data) {
                                return retailDetail(data);
                              }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xFF161A30),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  await Inventory.getInventory();
                  nav.pushNamed('/add');
                },
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          );
  }

  Widget retailDetail(list) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: list);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Sale'),
              content: const Text('Are you sure you want to delete this sale?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    var navigator = Navigator.of(context);

                    await updateStock(list);
                    await Sale.deleteSale(list);
                    await Sale.getSale();
                    setState(() {
                      filterList();
                      sortList(valueSort);
                    });
                    navigator.pop();
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 4,
        ),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Color.fromARGB(255, 169, 169, 169),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    list.id,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        list.via,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    list.date,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await Sale.checkBox(list);
                      await Sale.getSale();

                      retailListSale = Sale.listSale;

                      setState(() {
                        filterList();
                        sortList(valueSort);
                      });
                    },
                    child: list.completed
                        ? const Icon(Icons.check_box)
                        : const Icon(Icons.check_box_outline_blank),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> customBottomSheet(context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          onProviderChange: (String? valueFilterChange) {
            setState(() {
              valueFilter = valueFilterChange;
            });
          },
          onNameChange: (TextEditingController searchNameChange) {
            setState(() {
              searchName = searchNameChange;
            });
          },
          onNoResiChange: (TextEditingController searchNoResi) {
            setState(() {
              searchNoResi = searchNoResi;
            });
          },
          activateFilter: () {
            filterList();
          },
        );
      },
    );
  }

  Future<void> updateStock(dataSale) async {
    await Inventory.getInventory();
    for (var products in dataSale.product['fields'].entries) {
      for (var inventory in Inventory.listInventory) {
        if (products.key == inventory.name) {
          Inventory tempInventory = inventory;
          tempInventory.stock = (int.parse(tempInventory.stock) +
                  int.parse(products.value['integerValue']))
              .toString();
          await Inventory.editInventory(tempInventory);
          break;
        }
      }
    }

    await Stock.getStock(false);
    for (var product in dataSale.product['fields'].entries) {
      for (var stock in Stock.listStock) {
        if (product.key == stock.product &&
            stock.date == dataSale.date &&
            stock.desc == "Penjualan ${dataSale.via}" &&
            product.value['integerValue'].toString() ==
                stock.quantity.toString()) {
          await stock.deleteStock();
          break;
        }
      }
    }
  }
}

class BottomSheetWidget extends StatefulWidget {
  final Function(String?) onProviderChange;
  final Function(TextEditingController) onNameChange;
  final Function(TextEditingController) onNoResiChange;
  final Function activateFilter;
  const BottomSheetWidget({
    required this.onProviderChange,
    required this.onNameChange,
    required this.onNoResiChange,
    required this.activateFilter,
    super.key,
  });

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final TextEditingController searchName = TextEditingController();
  final TextEditingController searchNoResi = TextEditingController();
  String? valueFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        child: ListView(
          children: [
            CustomWidget.customText("Name"),
            const SizedBox(height: 5),
            TextField(
              controller: searchName,
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
                labelText: "Search By Name",
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
            ),
            const SizedBox(height: 10),
            CustomWidget.customText("Provider"),
            const SizedBox(height: 5),
            DropdownButton(
              isExpanded: true,
              underline: Container(),
              items: <String>['Tokopedia', 'Shopee', 'TikTok']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  valueFilter = value!;
                });
              },
              value: valueFilter,
              hint: Text(valueFilter ?? "Choose Provider"),
            ),
            const SizedBox(height: 10),
            CustomWidget.customText("No Resi"),
            const SizedBox(height: 5),
            TextField(
              controller: searchNoResi,
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
                labelText: "Search By No Resi",
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                widget.onNameChange(searchName);
                widget.onProviderChange(valueFilter);
                widget.onNoResiChange(searchNoResi);
                widget.activateFilter();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Apply Filter",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
