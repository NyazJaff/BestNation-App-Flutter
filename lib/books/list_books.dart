import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/books/pdfscreen.dart';
import 'package:bestnation/models/book_model.dart';
import 'package:bestnation/models/epic_model.dart';
import 'package:bestnation/utilities/flat_file_downloader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:bestnation/utilities/chasing_dots.dart';
import '../Helper/db_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class ListBooks extends StatefulWidget {
  ListBooks({
    Key key,
    this.title,
    this.parentId,
    this.classType,
  }) : super(key: key);

  final String title;
  final String parentId;
  final String classType;

  @override
  _ListBooksState createState() => _ListBooksState();
}

class _ListBooksState extends State<ListBooks> {
  var db = new DatabaseHelper();
  List<Epic> records = [];

  bool loading = true;
  bool isThereNetwork = false;

  @override
  void initState() {
    super.initState();
    pullDataFromNetwork();
  }

  @override
  void dispose() {
    super.dispose();
  }

  pullDataFromNetwork() async {
    await Firebase.initializeApp();
    isThereNetwork = await hasNetwork();
    await _pullListBooks();
    setState(() {});
  }

  _pullListBooks() async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("books_x")
        .where('parentId', isEqualTo: widget.parentId)
        .orderBy('order')
        .get();

    formatFirebaseDocuments(document);
    return records;
  }

  formatFirebaseDocuments(document) async {
    await doFormat(document);
    // records.sort((b, a) => a.firebaseId.compareTo(b.firebaseId)); // Sort Records
    loading = false;
    return records;
  }

  doFormat(document) async {
    await document.docs.forEach((document) async {
      Epic epic = db.formatEpicForSave(document,
          widget.classType); // eg, classType = DatabaseHelper.LECTURES
      // await db.saveEpic(epic);
      if (!isThereNetwork && document['type'] == 'RECORD') {
        await doesUrlFileExits(document['pdfURL']).then((exists) {
          if (exists != null && exists.path != null) {
            records.add(epic);
          }
        });
      } else {
        records.add(epic);
      }

      setState(() {});
    });
  }

  innerNavigate(title, firebaseId) {
    var classToCall = ListBooks(
        title: title,
        parentId: firebaseId,
        classType: widget.classType,
        key: UniqueKey());
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => classToCall));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        decoration: appBackgroundGradient(),
        child: Scaffold(
          appBar: app_bar(context, widget.title),
          backgroundColor: Colors.transparent,
          body: Stack(children: <Widget>[
            appBgImage(),
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),
            loading == false
                ? records.length > 0
                    ? Column(
                        children: [
                          Container(
                              child: epicsList()
                          ),
                        ],
                      ) // Display Record
                    : Container(
              margin: EdgeInsets.only(bottom: 80.0),
                        child: Center(
                            child: Text(
                        "no_records_currently_added!".tr(),
                        style: arabicTxtStyle(),
                        textAlign: TextAlign.center,
                      ))) // No Record Found
                : Container(
                    child: Center(
                        child: SpinKitChasingDots(
                    color: UtilColours.APP_BAR,
                    size: 50.0,
                  ))) // Loading
          ]),
        ));
  }

  openBook(entry) async{
    await doesUrlFileExits(entry.pdfURL).then((exists) async{
      if (exists != null && exists.path != null) {
        Book book = await db.bookByPdfUrl(entry.pdfURL);
        GlobalKey key = GlobalKey();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PDFScreen(
                path: exists.path,
                title: entry.name,
                currentPage: 0,
                bookId: book.id,
                key: key,
              )),
        );
      }
    });
  }

  Widget epicsList() {
    return Expanded(
      child: ListView.separated(
        // scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: records.length,
        itemBuilder: (BuildContext context, int index) {
          var entry = records[index];
          final GlobalKey<ScaffoldState> scaffoldKey =
              new GlobalKey<ScaffoldState>();
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
                              // index == state.currentIndex
                              //     ? Icons.pause
                              //     : Icons.play_arrow,
                              color: Colors.white,
                            )),
                      )
                    : Icon(Icons.menu, color: UtilColours.APP_BAR),
                trailing: entry.type == "RECORD"
                    // ? listMenuItems(entry) : SizedBox.shrink(),
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FlatFileDownloader(
                              fileURL: entry.pdfURL, callBackFunc: saveBookToDatabase(entry))
                        ],
                      )
                    : SizedBox.shrink(),
                onTap: () {
                  if (entry.type == "RECORD") {
                    openBook(entry);
                  }else {
                    innerNavigate(entry.name, entry.firebaseId);
                  }
                }),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }

  saveBookToDatabase(entry) {
     db.saveBook(new Book(
        name: entry.name,
        pdfURL: entry.pdfURL));
  }
}
