import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/controller/books/pdf_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:get/get.dart';
import '../../Helper/db_helper.dart';
import '../../controller/books/books_controller.dart';
import '../components/flat_downlod.dart';

class PdfScreen extends StatefulWidget {
  PdfScreen({super.key});

  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final PdfScreenController pdfController = Get.put(PdfScreenController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Text(pdfController.loading.value.toString()),);
  }
}
