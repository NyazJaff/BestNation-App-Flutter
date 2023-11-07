import 'dart:async';
import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/controller/books/pdf_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../Helper/db_helper.dart';
import 'package:bestnation/Helper/util.dart';

class PdfScreen extends StatefulWidget {
  PdfScreen({super.key});

  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final PdfScreenController pdfController = Get.put(PdfScreenController());
  Completer<PDFViewController> _controller = Completer<PDFViewController>();
  late PDFViewController _pdfViewController;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(context, pdfController.args['title']),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                  child: PDFView(
                filePath: pdfController.args['path'],
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                onRender: (_pages) {
                  // setState(() {
                  //   pages = _pages;
                  //   isReady = true;
                  // });
                  // if(utilIsAndroid(context)){
                  //   _pdfViewController.setPage(widget.currentPage);
                  // }
                },
                onError: (error) {
                  setState(() {
                    errorMessage = error.toString();
                  });
                  print(error.toString());
                },
                onPageError: (page, error) {
                  setState(() {
                    errorMessage = '$page: ${error.toString()}';
                  });
                  print('$page: ${error.toString()}');
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                  _pdfViewController = pdfViewController;
                },
                // onPageChanged: (int page, int total) async {
                //   db.checkIfPageMarkedBookmark(widget.bookId, await _pdfViewController.getCurrentPage()).then((value) {
                //     setState(() => this.pageBookmarked = value);
                //   });
                // },
              ))
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: Builder(
            builder: (cntx) => new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      Share.shareXFiles([XFile(pdfController.args['path'])],
                          text: pdfController.args['path'],
                          subject: pdfController.args['path']);
                    }),
                // IconButton(icon: pageBookmarked ? Icon(Icons.bookmark) :Icon(Icons.bookmark_border) , onPressed: () async{
                //   if(!pageBookmarked){
                //     db.saveCommentOrBookmark(new CommentAndBookmark(
                //         bookId: widget.bookId,
                //         pageIndex: await _pdfViewController.getCurrentPage(),
                //         type: DatabaseHelper.BOOKMARK));
                //   }else{
                //     db.deleteCommentOrBookmark(
                //         widget.bookId,
                //         await _pdfViewController.getCurrentPage(),
                //         DatabaseHelper.BOOKMARK);
                //   }
                //   setState(() {
                //     pageBookmarked = !pageBookmarked;
                //   });
                //
                //   Scaffold.of(cntx).showSnackBar(SnackBar(
                //     content: Text(pageBookmarked? "bookmarked!".tr() : "removed_bookmark!".tr()),
                //     duration: Duration(seconds: 1),
                //   ));
                //
                // },),//bookmark
                // IconButton(icon: Icon(Icons.add_comment, color: Colors.black), onPressed: () { commentPopup(cntx);},),
                // IconButton(icon: Icon(Icons.view_list), onPressed: () {

//                  showGeneralDialog(
//                      barrierColor: Colors.black.withOpacity(0.5),
//                      transitionBuilder: (context, a1, a2, widget) {
//                        return Transform.scale(
//                          scale: a1.value,
//                          child: Opacity(
//                              opacity: a1.value,
//                              child: BookMarksAndComments(
//                                title:  "nnn",
//                                pdfViewController: _pdfViewController,
//
//                              )
//                          ),
//                        );
//                      },
//                      transitionDuration: Duration(milliseconds: 250),
//                      barrierDismissible: true,
//                      barrierLabel: '',
//                      context: context,
//                      pageBuilder: (context, animation1, animation2) {});

                // showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return
                //         BookmarksAndComments(
                //             title:   pdfController.args['path'],
                //             pdfViewController: _pdfViewController,
                //             bookId: widget.bookId
                //         );
                //     });
                // },),
              ],
            ),
          )),
    );
  }
}
