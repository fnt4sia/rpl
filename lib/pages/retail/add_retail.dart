import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:scentco/controller/ocr.dart';
import 'package:scentco/model/inventory.dart';
import 'package:scentco/model/stock_model.dart';
import '../../material/custom.dart';
import '../../model/sale.dart';

class AddRetailPage extends StatefulWidget {
  const AddRetailPage({super.key});

  @override
  State<AddRetailPage> createState() => _AddRetailPageState();
}

class _AddRetailPageState extends State<AddRetailPage> {
  DateTime? pickedDate = DateTime.now();
  String via = "Tokopedia";
  String? errorMessage;
  PlatformFile? receiptFile;
  final Map<String, dynamic> listProduct = {};
  bool isProcessing = false;
  String? noResi;
  String? penerima;
  String? urlOcr;
  bool loadingOCR = false;

  void add(String key) {
    final product =
        Inventory.listInventory.firstWhere((element) => element.name == key);
    if (listProduct[key]['integerValue'] < int.parse(product.stock)) {
      setState(() {
        listProduct[key]['integerValue'] = listProduct[key]['integerValue'] + 1;
      });
    }
  }

  void remove(String key) {
    if (listProduct[key]['integerValue']! > 0) {
      setState(() {
        listProduct[key]['integerValue'] = listProduct[key]['integerValue'] - 1;
      });
    }
  }

  num totalAmount() {
    num sum = 0;
    for (var element in listProduct.values) {
      sum += element['integerValue'];
    }
    return sum;
  }

  @override
  void initState() {
    Inventory.listInventory
        .where((e) => e.category == "Product" && int.parse(e.stock) > 0)
        .forEach((e) => listProduct[e.name] = {'integerValue': 0});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final num amount = totalAmount();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 36,
          ),
        ),
      ),
      body: loadingOCR
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    CustomWidget.customText('Products'),
                    const SizedBox(height: 5),
                    Column(
                      children: listProduct.entries
                          .map((e) => customRowAdd(
                              e.key, e.value['integerValue'], add, remove))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomWidget.customText('Amount'),
                        CustomWidget.customText('$amount Items'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomWidget.customText('Provider'),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 215, 215, 215),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: via,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              underline: Container(
                                height: 2,
                                color: Colors.transparent,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  via = newValue!;
                                });
                              },
                              items: <String>[
                                'Tokopedia',
                                'Shopee',
                                'TikTok',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomWidget.customText('Date'),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 215, 215, 215),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Center(
                            child: Text(
                              DateFormat('d MMMM yyy').format(pickedDate!),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: pickedDate!,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  pickedDate = value;
                                });
                              }
                            });
                          },
                          icon: const Icon(
                            Icons.calendar_today,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    noResi != null
                        ? Row(
                            children: [
                              const Text(
                                'No. Resi   :',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                noResi!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    penerima != null
                        ? Row(
                            children: [
                              const Text(
                                'Penerima :',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                penerima!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(height: 10),
                    CustomWidget.customText('Receipt'),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 215, 215, 215),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Center(
                            child: FittedBox(
                              child: Text(
                                receiptFile == null
                                    ? 'Upload Your Image'
                                    : receiptFile!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () async {
                            final FilePickerResult? picker =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'png',
                                'jpg',
                                'pdf',
                              ],
                            );

                            if (picker != null) {
                              setState(() async {
                                setState(() {
                                  loadingOCR = true;
                                  receiptFile = picker.files.first;
                                });
                                FirebaseStorage storage =
                                    FirebaseStorage.instance;
                                Reference ref = storage
                                    .ref()
                                    .child('ocr/${receiptFile!.name}');
                                UploadTask uploadTask =
                                    ref.putFile(File(receiptFile!.path!));
                                await uploadTask.then((p0) async {
                                  urlOcr = await ref.getDownloadURL();
                                  ResiOCR resiOCR = ResiOCR(provider: via);
                                  final Map<String, String> ocrResponse =
                                      await resiOCR.ocr(urlOcr!);
                                  setState(() {
                                    noResi = ocrResponse['noResi'];
                                    penerima = ocrResponse['penerima'];
                                  });
                                });
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.black,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            child: const Text(
                              'Upload',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    receiptFile == null
                        ? const SizedBox()
                        : (receiptFile!.extension == "pdf"
                            ? SizedBox(
                                height: 300,
                                child: const PDF().fromPath(receiptFile!.path!),
                              )
                            : Image.file(
                                File(receiptFile!.path!),
                              )),
                    const SizedBox(height: 5),
                    errorMessage == null
                        ? const SizedBox()
                        : Center(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: isProcessing
                          ? () {}
                          : () async {
                              if (receiptFile == null) {
                                setState(() {
                                  errorMessage = "Please Fill The Form";
                                });
                              } else {
                                setState(() {
                                  isProcessing = true;
                                });
                                final navigator = Navigator.of(context);
                                final String time = (DateFormat('d MMMM yyy')
                                    .format(pickedDate!));

                                FirebaseStorage storage =
                                    FirebaseStorage.instance;
                                Reference ref = storage
                                    .ref()
                                    .child('sale/${receiptFile!.name}');

                                UploadTask uploadTask =
                                    ref.putFile(File(receiptFile!.path!));
                                await uploadTask.then((p0) async {
                                  final String downloadUrl =
                                      await ref.getDownloadURL();
                                  final response = await Sale.addSale(
                                    listProduct,
                                    via,
                                    time,
                                    downloadUrl,
                                    receiptFile!.extension!,
                                    noResi!,
                                    penerima!,
                                  );
                                  if (response) {
                                    listProduct.forEach((key, value) async {
                                      if (value['integerValue'] > 0) {
                                        await Stock.updateStock(
                                          time,
                                          key,
                                          value['integerValue'],
                                          false,
                                          "Penjualan $via",
                                        );
                                      }
                                    });
                                    navigator.pushReplacementNamed('/');
                                  }
                                });
                                setState(() {
                                  isProcessing = false;
                                });
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF161A30),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              12,
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget customRowAdd(
      String productName, int sumProduct, Function add, Function remove) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              productName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    add(productName);
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$sumProduct',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    remove(productName);
                  },
                  icon: const Icon(
                    Icons.remove,
                    size: 26,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
