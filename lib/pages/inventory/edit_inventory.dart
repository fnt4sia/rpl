import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scentco/model/stock_model.dart';
import '../../material/custom.dart';
import '../../model/inventory.dart';

class EditInventoryPage extends StatefulWidget {
  final Inventory data;
  const EditInventoryPage({super.key, required this.data});

  @override
  State<EditInventoryPage> createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  late TextEditingController nameController;
  late int editAmount;
  late int initialEditAmount;
  XFile? imageFile;
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data.name);
    editAmount = int.parse(widget.data.stock);
    initialEditAmount = int.parse(widget.data.stock);
  }

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
        actions: [
          IconButton(
            onPressed: () async {
              await Stock.updateStock(
                DateFormat('d MMMM yyy').format(DateTime.now()),
                widget.data.name,
                initialEditAmount,
                false,
                "Deleted Product",
              );
              Inventory.deleteInventory(widget.data).then((res) {
                if (res) {
                  Inventory.listInventory.clear();
                  Navigator.pushReplacementNamed(context, '/inventory');
                }
              });
            },
            icon: const Icon(
              Icons.delete,
              size: 36,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Edit Product',
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
                        editAmount++;
                      });
                    },
                    child: const Icon(
                      Icons.add,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    '$editAmount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (editAmount > 0) {
                          editAmount--;
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
              const SizedBox(height: 10),
              initialEditAmount != editAmount
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.customText("Description"),
                        const SizedBox(height: 5),
                        CustomWidget.customTextField(
                            'Description', descController, false),
                        const SizedBox(height: 15),
                      ],
                    )
                  : const SizedBox(),
              CustomWidget.customText('Picture'),
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
              const SizedBox(height: 5),
              imageFile == null
                  ? Image.network(widget.data.imageUrl)
                  : Image.file(File(imageFile!.path)),
              const SizedBox(height: 15),
              InkWell(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  if (editAmount != initialEditAmount) {
                    await Stock.updateStock(
                      DateFormat('d MMMM yyy').format(DateTime.now()),
                      widget.data.name,
                      (editAmount - initialEditAmount),
                      editAmount > initialEditAmount,
                      descController.text,
                    );
                  }
                  if (imageFile != null) {
                    FirebaseStorage storage = FirebaseStorage.instance;

                    if (widget.data.imageUrl.isNotEmpty) {
                      Reference oldImageRef =
                          storage.refFromURL(widget.data.imageUrl);
                      await oldImageRef.delete();
                    }

                    Reference ref =
                        storage.ref().child('inventory/${imageFile!.name}');

                    UploadTask uploadTask = ref.putFile(File(imageFile!.path));
                    await uploadTask.whenComplete(() async {
                      final String downloadUrl = await ref.getDownloadURL();
                      widget.data.imageUrl = downloadUrl;

                      widget.data.name = nameController.text;
                      widget.data.stock = editAmount.toString();

                      final response =
                          await Inventory.editInventory(widget.data);
                      if (response) {
                        navigator.pushReplacementNamed('/inventory');
                      }
                    });
                  } else {
                    widget.data.name = nameController.text;
                    widget.data.stock = editAmount.toString();

                    final response = await Inventory.editInventory(widget.data);
                    if (response) {
                      navigator.pushReplacementNamed('/inventory');
                    }
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
