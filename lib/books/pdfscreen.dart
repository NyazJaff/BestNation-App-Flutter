import 'dart:async';
import 'package:bestnation/Helper/db_helper.dart';
import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/models/comments_and_bookmarks_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:bestnation/books/bookmarks_and_comments.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:share/share.dart';
import 'package:easy_localization/easy_localization.dart';

class PDFScreen extends StatefulWidget {
  final String path;
  final String title;
  final int bookId;
  int currentPage;

  PDFScreen({Key key, this.path, this.title, this.currentPage, this.bookId}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver  {
  Completer<PDFViewController> _controller = Completer<PDFViewController>();
  PDFViewController _pdfViewController;
  var db = new DatabaseHelper();
  var isKeyboardOpen = false;
  int pages = 0;
  bool isReady = false;
  bool pageBookmarked  = false;
  String errorMessage = '';
  Orientation currentOrientation = null;

  @override
  void initState() {
    print(widget.path);
    super.initState();
    WidgetsBinding.instance.addObserver(this); //used for keyboard detection
    this.currentOrientation = getCurrentOrientation();

    // WidgetsBinding.instance.addPostFrameCallback((_){
    // });

  }

  @override
  void didChangeMetrics() {

    // if(!utilIsAndroid(context)){
    //   setState(() {
    //     _controller = new Completer<PDFViewController>();
    //   });
    // }
    if(utilIsAndroid(context)) {
      if (this.currentOrientation != getCurrentOrientation()) {
        refreshWindow();
        // setState(() {
        //   this.currentOrientation = getCurrentOrientation();
        //   _controller = new Completer<PDFViewController>();
        // });
      }
    }
//     if(utilIsAndroid(context)){
//       final value = MediaQuery.of(context).viewInsets.bottom;
//       print(value);
//       if (value > 0) {
//         if (isKeyboardOpen) {
//           // _onKeyboardChanged(false);
//         }
//         isKeyboardOpen = false;
//       } else {
//         isKeyboardOpen = true;
// //        _onKeyboardChanged(true);
//       }
//     }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: appBar(context, widget.title),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                  child:PDFView(
                    filePath: widget.path,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageFling: true,
                    onRender: (_pages) {
                      setState(() {
                        pages = _pages;
                        isReady = true;
                      });
                      if(utilIsAndroid(context)){
                        _pdfViewController.setPage(widget.currentPage);
                      }
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
                    onPageChanged: (int page, int total) async {
                      db.checkIfPageMarkedBookmark(widget.bookId, await _pdfViewController.getCurrentPage()).then((value) {
                        setState(() => this.pageBookmarked = value);
                      });
                    },
                  )
              )
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: Builder(
            builder: (cntx) =>new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(icon: Icon(Icons.share), onPressed: () {
                  Share.shareFiles([widget.path], text: widget.title, subject: widget.title);
                }),
                IconButton(icon: pageBookmarked ? Icon(Icons.bookmark) :Icon(Icons.bookmark_border) , onPressed: () async{
                  if(!pageBookmarked){
                    db.saveCommentOrBookmark(new CommentAndBookmark(
                        bookId: widget.bookId,
                        pageIndex: await _pdfViewController.getCurrentPage(),
                        type: DatabaseHelper.BOOKMARK));
                  }else{
                    db.deleteCommentOrBookmark(
                        widget.bookId,
                        await _pdfViewController.getCurrentPage(),
                        DatabaseHelper.BOOKMARK);
                  }
                  setState(() {
                    pageBookmarked = !pageBookmarked;
                  });

                  ScaffoldMessenger.of(cntx).showSnackBar(SnackBar(
                    content: Text(pageBookmarked? "bookmarked!".tr() : "removed_bookmark!".tr()),
                    duration: Duration(seconds: 1),
                  ));

                },),//bookmark
                IconButton(icon: Icon(Icons.add_comment, color: Colors.black), onPressed: () { commentPopup(cntx);},),
                IconButton(icon: Icon(Icons.view_list), onPressed: () {

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

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return
                          BookmarksAndComments(
                            title:  widget.title,
                            pdfViewController: _pdfViewController,
                            bookId: widget.bookId
                          );
                      });
                },),
              ],
            ),
          )
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  refreshWindow () async {
    GlobalKey key = GlobalKey();
    final currentPageParam = await _pdfViewController.getCurrentPage();

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PDFScreen(bookId: widget.bookId, path: widget.path, title: widget.title, currentPage: currentPageParam, key: key,)),
    );
  }

  commentPopup(ctx) {
    final commentTxt = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
                width: 300.0,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'add_comment_to_this_page'.tr(),
                              style:arabicTxtStyle(),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextField(
                          controller: commentTxt,
                          decoration: InputDecoration(
                            hintText: "",
                            border: InputBorder.none,

                          ),
                          maxLines: 8,
                        ),
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: UtilColours.SAVE_BUTTON,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0)),
                          ),
                          child: Text(
                            "save".tr(),
                            style: arabicTxtStyle(paramColour: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () async {

                          if(commentTxt.text != "" ){
                            db.saveCommentOrBookmark(new CommentAndBookmark(
                                bookId: widget.bookId,
                                pageIndex: await _pdfViewController.getCurrentPage(),
                                comment: commentTxt.text,
                                type: DatabaseHelper.COMMENT));

                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text('saved'.tr() + commentTxt.text),
                              duration: Duration(seconds: 2),
                            ));
                          }
                          // await Future.delayed(const Duration(seconds: 2), (){
                            Navigator.of(context, rootNavigator: true).pop(commentTxt.text);
                          // });

                        },
                      ),

                    ],
                  ),
                )
            ),
          );
        });
  }
}