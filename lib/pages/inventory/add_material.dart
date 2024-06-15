import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scentco/model/inventory.dart';
import 'package:scentco/model/stock_model.dart';
import '../../material/custom.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final TextEditingController nameController = TextEditingController();
  String? category;
  String? errorMessage;
  XFile? imageFile;
  int stock = 0;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Add Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 15),
              CustomWidget.customText('Product Name'),
              const SizedBox(height: 5),
              CustomWidget.customTextField(
                  'Product Name', nameController, false),
              const SizedBox(height: 15),
              CustomWidget.customText('Stock'),
              const SizedBox(height: 5),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        stock++;
                      });
                    },
                    child: const Icon(
                      Icons.add,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 25,
                    child: TextField(
                      controller: TextEditingController()..text = '$stock',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          stock = int.parse(value);
                        });
                      },
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (stock > 0) {
                          stock--;
                        }
                      });
                    },
                    child: const Icon(
                      Icons.remove,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CustomWidget.customText('Category'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 215, 215, 215),
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                child: DropdownButton(
                  hint: Text(
                    category ?? 'Select Category',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color.fromARGB(255, 215, 215, 215),
                  onChanged: (String? value) {
                    setState(() {
                      category = value!;
                    });
                  },
                  items: <String>['Product', 'Material', 'Other']
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
                ),
              ),
              const SizedBox(height: 15),
              CustomWidget.customText('Image'),
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
                          imageFile == null
                              ? 'Upload Your Image'
                              : imageFile!.name,
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
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickImage != null) {
                        setState(() {
                          imageFile = pickImage;
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
              const SizedBox(height: 10),
              imageFile == null
                  ? const SizedBox()
                  : Image.file(File(imageFile!.path)),
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
                        if (nameController.text.isEmpty ||
                            category == null ||
                            imageFile == null) {
                          setState(() {
                            errorMessage = "Please Fill The Form";
                          });
                        } else {
                          setState(() {
                            isProcessing = true;
                          });
                          final navigator = Navigator.of(context);

                          Stock.updateStock(
                            DateFormat('d MMMM yyy').format(DateTime.now()),
                            nameController.text,
                            stock,
                            true,
                            "New Product",
                          );

                          FirebaseStorage storage = FirebaseStorage.instance;
                          Reference ref = storage
                              .ref()
                              .child('inventory/${imageFile!.name}');

                          UploadTask uploadTask =
                              ref.putFile(File(imageFile!.path));
                          uploadTask.then((p0) async {
                            final String downloadUrl =
                                await ref.getDownloadURL();
                            final response = await Inventory.addInventory(
                                nameController.text,
                                category!,
                                stock,
                                downloadUrl);
                            if (response) {
                              navigator.pushReplacementNamed('/inventory');
                            }
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
}
