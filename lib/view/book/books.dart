import 'package:bestnation/Helper/util.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:get/get.dart';
import '../../Helper/db_helper.dart';
import '../../controller/books/books_controller.dart';
import '../components/flat_downlod.dart';

class Books extends StatefulWidget {
  Books({super.key});

  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  final BooksController booksController = Get.find();
  final _searchBooksController = TextEditingController();

  var db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        decoration: appBackgroundGradient(),
        child: Scaffold(
          appBar: appBar(context, booksController.args['title']),
          backgroundColor: Colors.transparent,
          body: Obx(() => Stack(children: <Widget>[
                appBgImage(),
                new Padding(
                  padding: const EdgeInsets.all(10.0),
                ),
                booksController.loading.value == true
                    ? displayLoading()
                    : booksList() // No Record Found
                // Loading
              ])),
        ));
  }

  Widget searchBox() {
    return Container(
        decoration: valueBoxDecorationStyle,
        width: 250,
        height: 50,
        child: Center(
          child: ListTile(
              title: TextField(
                controller: _searchBooksController,
                onChanged: (String value) {
                  booksController.algoliaBooksSearch(value);
                },
                style: TextStyle(
                    color: textAndIconColour,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'search'.tr,
                    hintStyle: valueHintBoxDecorationStyle),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                iconSize: 30,
                tooltip: 'stop'.tr,
                onPressed: () {},
              )),
        ));
  }

  Widget booksList() {
    return Column(children: [
      searchBox(),
      SizedBox(height: 15),
      booksController.records.length > 0
          ? Container(
              child: Expanded(
              child: ListView.separated(
                // scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: booksController.records.length,
                itemBuilder: (BuildContext context, int index) {
                  var entry = booksController.records[index];
                  return displayEachEntry(entry, index);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
            ))
          : displayNoRecordFound(),
    ]);
  }

  Widget displayEachEntry(entry, index) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: ListTile(
          visualDensity: VisualDensity(horizontal: -4, vertical: 0),
          title: Text(entry.name.toString(),
              style: arabicTxtStyle(paramSize: 18.0)),
          leading: entry.type == "RECORD"
              ? Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: linearGradientBackground(),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      )),
                )
              : Icon(Icons.menu, color: UtilColours.APP_BAR),
          trailing: entry.type == "RECORD"
              // ? listMenuItems(entry) : SizedBox.shrink(),
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatDownload(tag: entry.pdfURL),
                  ],
                )
              : SizedBox.shrink(),
          onTap: () {
            if (entry.type == "RECORD") {
              openBook(entry);
            }else {
              innerNavigate(entry);
            }
          }),
    );
  }

  innerNavigate(entry) {
    Get.to(
      () => Books(),
      arguments: {
        'title': entry.name.toString(),
        'parentId': entry.firebaseId,
        'classType': booksController.args['classType']
      },
      preventDuplicates: false,
    );
  }

  openBook(entry) async{
    await doesUrlFileExits(entry.pdfURL).then((exists) async{
      if (exists != null) {

      }
    });
  }
}
