import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../material/custom.dart';
import '../../model/inventory.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String active = 'Product';

  @override
  void initState() {
    super.initState();
    Inventory.getInventory().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Inventory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  buttonSelect('Product', active == "Product", () {
                    setState(() {
                      active = "Product";
                    });
                  }),
                  const SizedBox(width: 10),
                  buttonSelect('Material', active == "Material", () {
                    setState(() {
                      active = "Material";
                    });
                  }),
                  const SizedBox(width: 10),
                  buttonSelect('Other', active == "Other", () {
                    setState(() {
                      active = "Other";
                    });
                  }),
                ],
              ),
              const SizedBox(height: 15),
              Column(
                  children: Inventory.listInventory
                      .where((item) => item.category == active)
                      .toList()
                      .map((e) => itemContainer(e))
                      .toList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF161A30),
        onPressed: () async {
          Navigator.of(context).pushNamed('/addinventory');
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buttonSelect(String category, bool active, Function press) {
    return InkWell(
      onTap: () {
        press();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF161A30),
          ),
          color: active ? const Color(0xFF161A30) : Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF161A30),
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget itemContainer(Inventory item) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 230, 230, 230),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.fill,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Stock : ${item.stock}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 15),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/edit', arguments: item);
                },
                child: const Icon(
                  Icons.edit,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
