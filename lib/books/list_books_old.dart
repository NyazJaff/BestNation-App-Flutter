// import 'dart:io';
// import 'package:bestnation/Helper/db_helper.dart';
// import 'package:bestnation/Helper/util.dart';
// import 'package:bestnation/models/book_model.dart';
// import 'package:bestnation/utilities/chasing_dots.dart';
// import 'package:dio/dio.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:bestnation/books/book_detail.dart';
// import 'package:bestnation/books/pdfscreen.dart';
// import 'package:bestnation/utilities/layout_helper.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:bestnation/utilities/file_downloader.dart';
//
// class ListBooks extends StatefulWidget {
//
//   final String parentId;
//   final String title;
//
//   ListBooks({
//     Key key,
//     this.title,
//     this.parentId,
//   }) : super(key: key);
//
//   @override
//   _ListBooksState createState() => _ListBooksState();
// }
//
// class _ListBooksState extends State<ListBooks> {
//
//   var db = new DatabaseHelper();
//   var loading = true;
//
//   @override
//   void initState() {
//     // db.deleteBook();
//     pullBooks();
//     super.initState();
//   }
//
//   pullBooks() async {
//     await Firebase.initializeApp();
//     int largestId = await db.largestBookId();
//     QuerySnapshot document = await FirebaseFirestore.instance
//         .collection("books")
//         .where('parentId', isEqualTo: widget.parentId)
//         // .where('id', isGreaterThan: largestId)
//         .get();
//
//     if(largestId == 0){
//       document.docs.forEach((document) async {
//         await db.saveBook(new Book(
//             id: document.data()['id'],
//             name: document.data()['name'],
//             description: document.data()['name'],
//             imageURL: document.data()['imageURL'],
//             pdfURL: document.data()['pdfURL']));
//         // createFileOfUrl(document.data()['imageURL']).then((value) {
//         //   // setState(() {});
//         // });
//       });
//     }
//     setState(() {
//       loading = false;
//     });
//   }
//
//   navigateToDetail(DocumentSnapshot post) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => BookDetail(
//               post: post,
//             )));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: double.infinity,
//         decoration: appBackgroundGradient(),
//         child: Scaffold(
//             appBar: app_bar(context, widget.title),
//             backgroundColor: Colors.transparent,
//             body: Stack(children: <Widget>[
//               appBgImage(),
//               Container(
//                 child: loading == true
//                     ? Center(
//                     child: SpinKitChasingDots(
//                       color: UtilColours.APP_BAR,
//                       size: 50.0,
//                     ))
//                     : FutureBuilder(
//                     future: db.books(),
//                     builder: (_, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(
//                             child: SpinKitChasingDots(
//                               color: UtilColours.APP_BAR,
//                               size: 50.0,
//                             ));
//                       } else {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 5.0),
//                           child: CustomScrollView(
//                             slivers: <Widget>[
//                               AnimationLimiter(
//                                 child: SliverGrid(
//                                   gridDelegate:
//                                   SliverGridDelegateWithMaxCrossAxisExtent(
//                                       maxCrossAxisExtent: 300.0,
//                                       mainAxisSpacing: 0,
//                                       crossAxisSpacing: 0.0,
//                                       childAspectRatio: 0.80),
//                                   delegate: SliverChildBuilderDelegate(
//                                         (_, int index) {
//                                       return AnimationConfiguration.staggeredList(
//                                         position: index,
//                                         duration: const Duration(milliseconds: 375),
//                                         child: SlideAnimation(
//                                           horizontalOffset: 50.0,
//                                           verticalOffset: 50.0,
//                                           child: FadeInAnimation(
//                                             child: Container(
//                                               child: BookListAdapter(
// //                                            thumbnail:  Image.file(
// //                                                File("$dir/" + snapshot.data[index].data["imageURL"].substring(snapshot.data[index].data["imageURL"].lastIndexOf("/") + 1))
// //                                            ),
//                                                   imageURL: snapshot.data[index].imageURL,
//                                                   pdfURL: snapshot.data[index].pdfURL,
//                                                   name: snapshot.data[index].name,
//                                                   description:
//                                                   snapshot.data[index].description,
//                                                   book: snapshot.data[index]),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     childCount: snapshot.data.length,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                     }),
//               )
//             ])));
//   }
// }
//
// class BookListAdapter extends StatefulWidget {
//   BookListAdapter(
//       {Key key,
//         this.imageURL,
//         this.pdfURL,
//         this.name,
//         this.description,
//         this.book})
//       : super(key: key);
//
//   final String imageURL;
//   final String pdfURL;
//   final String name;
//   final String description;
//   final Book book;
//
//   @override
//   _BookListAdapterState createState() => _BookListAdapterState();
// }
//
// class _BookListAdapterState extends State<BookListAdapter> {
//
//   bool boolLoadThumb = true;
//   String thumbPath = '';
//   double opacityLevel = 0.0;
//
//   @override
//   void initState() {
//     downloadThum();
//     super.initState();
//   }
//
//   pdfFileDownload() {
//     showToast(context, "downloading!".tr());
//     createFileOfUrl(widget.pdfURL).then((f) {
//       if (f.path != null) {
//         showToast(context, 'file_is_downloaded_ready_to_open'.tr());
//         setState(() {});
//       }
//     });
//   }
//
// //  Used to find the file on users device
// //   getFilePathBasedOnUrl(url) {
// //   }
//   downloadThum() async{
//     String dir = await getSystemPath();
//     var path = "$dir/" + widget.imageURL.substring(widget.imageURL.lastIndexOf("/") + 1);
//     if (File(path).existsSync() == false) {
//       await createFileOfUrl(widget.imageURL);
//     }
//
//     setState(() {
//       thumbPath = path;
//       boolLoadThumb = false;
//     });
//   }
//
//   openBook(path){
//     GlobalKey key = GlobalKey();
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => PDFScreen(
//             path: path,
//             title: widget.name,
//             currentPage: 10,
//             bookId: widget.book.id,
//             key: key,
//           )),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
//       child: SizedBox(
//           child: !boolLoadThumb ? InkWell(
//             child: Container(
//                 decoration: new BoxDecoration(
//                   image: new DecorationImage(
//                     image: FileImage(File(thumbPath)),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Align(
//                   alignment: Alignment(0.0, 0.8),
//                   child: FutureBuilder(
//                     builder: (context, exists) {
//                       if (exists.connectionState == ConnectionState.done &&
//                           exists.data == null) {
//                         return FileDownloader(fileURL: widget.pdfURL, openBook: openBook);
//                         // return RaisedButton.icon(
//                         //   onPressed: () {
//                         //     pdfFileDownload();
//                         //   },
//                         //   icon: Icon(Icons.file_download, color: UtilColours.APP_BAR),
//                         //   label: Text("Download"),
//                         //   color: UtilColours.APP_BAR_NAV_BUTTON,
//                         // );
//                       }
//                       return Container();
//                     },
//                     future: doesUrlFileExits(widget.pdfURL),
//                   ),
//                 )),
//             onTap: () {
//               doesUrlFileExits(widget.pdfURL).then((exists) {
//                 if (exists != null && exists.path != null) {
//                   openBook(exists.path);
//                 } else {
//                   bookInfoPopup(context);
//                 }
//               });
//             },
//           ) : displayLoading(size: 25.0) ),
//     );
//   }
//
//   bookInfoPopup(ctx) {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(32.0))),
//             contentPadding: EdgeInsets.only(top: 10.0),
//             content: Container(
//                 width: 300.0,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         mainAxisSize: MainAxisSize.min,
//                         children: <Widget>[],
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(top: 20.0, bottom: 20),
//                         child: Container(
// //                      width: MediaQuery.of(context).size.width * 0.55,
// //                        width: 20,
//                           height: MediaQuery.of(context).size.height * 0.22,
//                           child: Align(
//                             child: Image(
//                               image: FileImage(File(thumbPath)),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         alignment: Alignment.center,
//                         child: Text(widget.name,
//                             textAlign: TextAlign.center,
//                             style: arabicTxtStyle()),
//                       ),
//                       SizedBox(
//                         height: 5.0,
//                       ),
//                       Divider(
//                         color: Colors.grey,
//                         height: 4.0,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(top: 10.0),
//                         child: Container(
//                           alignment: Alignment.center,
//                           child: Text(
//                               widget.description != null
//                                   ? widget.description
//                                   : "",
//                               textAlign: TextAlign.center,
//                               style: arabicTxtStyle(paramSize: 15)),
//                         ),
//                       ),
//                       // InkWell(
//                       //   child: Container(
//                       //     padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
//                       //     decoration: BoxDecoration(
//                       //       color: UtilColours.SAVE_BUTTON,
//                       //       borderRadius: BorderRadius.only(
//                       //           bottomLeft: Radius.circular(20.0),
//                       //           bottomRight: Radius.circular(20.0)),
//                       //     ),
//                       //     child: Text(
//                       //       "Download شواطي",
//                       //       style: arabicTxtStyle(
//                       //           paramSize: 17, paramColour: Colors.white),
//                       //       textAlign: TextAlign.center,
//                       //     ),
//                       //   ),
//                       //   onTap: () async {
//                       //     Navigator.of(context, rootNavigator: true).pop();
//                       //     pdfFileDownload();
//                       //   },
//                       // ),
//                     ],
//                   ),
//                 )),
//           );
//         });
//   }
// }
//
//
//
//
