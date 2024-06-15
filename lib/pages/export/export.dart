import 'package:flutter/material.dart';
import 'package:scentco/controller/excel.dart';
import 'package:scentco/material/custom.dart';
import 'package:scentco/model/inventory.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController penerimaController = TextEditingController();

  bool isStock = false;
  bool isSale = false;
  DateTime? firstDate;
  DateTime? secondDate;
  String category = "Both";
  Map<String, bool> listProductStock = {};
  Map<String, bool> listProvider = {
    'Tokopedia': true,
    'Shopee': true,
    'TikTok Shop': true,
  };
  bool isLoading = true;

  @override
  void initState() {
    Inventory.getInventory().then((_) {
      setState(() {
        for (var element in Inventory.listInventory) {
          listProductStock[element.name] = true;
        }
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
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
                        'Export Data',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text(
                            'Recap Stock',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isStock = !isStock;
                              });
                            },
                            child: Icon(
                              isStock
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Recap Sales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isSale = !isSale;
                              });
                            },
                            child: Icon(
                              isSale
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 24,
                            ),
                          )
                        ],
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
                      isStock
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recap Stock Filter',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Type',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 215, 215, 215),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6))),
                                  child: DropdownButton(
                                    hint: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    isExpanded: true,
                                    dropdownColor: const Color.fromARGB(
                                        255, 215, 215, 215),
                                    onChanged: (String? value) {
                                      setState(() {
                                        category = value!;
                                      });
                                    },
                                    items: <String>['Both', 'Masuk', 'Keluar']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
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
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Product',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Column(
                                  children: listProductStock.keys
                                      .map((String key) => productCheckBox(key))
                                      .toList(),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 20),
                      isSale
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recap Sales Filter',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Penerima',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: penerimaController,
                                  decoration: InputDecoration(
                                    labelText: 'Penerima',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Provider',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Column(
                                  children: listProvider.keys
                                      .map(
                                          (String key) => providerCheckBox(key))
                                      .toList(),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          if (firstDate == null || secondDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill the date'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          await ExcelController(
                            isRecapStock: isStock,
                            isRecapSales: isSale,
                            dateFirst: firstDate!,
                            dateLast: secondDate!,
                            stockDescription: descriptionController.text,
                            stockType: category,
                            listProductStock: listProductStock,
                            penerima: penerimaController.text,
                            listProvider: listProvider,
                          ).createExcel();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Export Success'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Export',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget productCheckBox(String name) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              listProductStock[name] = !listProductStock[name]!;
            });
          },
          child: Icon(
            listProductStock[name]!
                ? Icons.check_box
                : Icons.check_box_outline_blank,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget providerCheckBox(String name) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              listProvider[name] = !listProvider[name]!;
            });
          },
          child: Icon(
            listProvider[name]!
                ? Icons.check_box
                : Icons.check_box_outline_blank,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
