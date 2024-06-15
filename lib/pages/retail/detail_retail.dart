import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../../material/custom.dart';
import '../../model/sale.dart';

class DetailRetailPage extends StatefulWidget {
  final Sale list;
  const DetailRetailPage({super.key, required this.list});

  @override
  State<DetailRetailPage> createState() => _DetailRetailPageState();
}

class _DetailRetailPageState extends State<DetailRetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              CustomWidget.customText('Sales ID'),
              const SizedBox(height: 5),
              textDisplay(widget.list.id),
              const SizedBox(height: 10),
              CustomWidget.customText('Products'),
              Column(children: [
                for (var data in widget.list.product['fields'].entries)
                  rowDisplay(data.key, data.value['integerValue'])
              ]),
              const SizedBox(height: 10),
              CustomWidget.customText('Date'),
              const SizedBox(height: 5),
              textDisplay(widget.list.date),
              const SizedBox(height: 10),
              CustomWidget.customText('Via'),
              const SizedBox(height: 5),
              textDisplay(widget.list.via),
              const SizedBox(height: 10),
              CustomWidget.customText("Penerima"),
              const SizedBox(height: 5),
              textDisplay(widget.list.penerima),
              const SizedBox(height: 5),
              CustomWidget.customText("No. Resi"),
              const SizedBox(height: 5),
              textDisplay(widget.list.noResi),
              CustomWidget.customText('Receipt'),
              const SizedBox(height: 5),
              InkWell(
                onDoubleTap: () async {},
                child: widget.list.fileExtension == "pdf"
                    ? SizedBox(
                        height: 300,
                        child: const PDF().cachedFromUrl(widget.list.imageUrl),
                      )
                    : Image.network(widget.list.imageUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget rowDisplay(String name, String product) {
    if (product != '0') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          textDisplay(name),
          textDisplay(product),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget textDisplay(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
