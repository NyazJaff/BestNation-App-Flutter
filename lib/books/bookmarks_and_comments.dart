import 'package:bestnation/utilities/layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/Helper/util.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:bestnation/models/comments_model.dart';
import 'package:bestnation/Helper/db_helper.dart';
import 'package:bestnation/utilities/chasing_dots.dart';
import 'package:easy_localization/easy_localization.dart';

class BookmarksAndComments extends StatefulWidget{
  BookmarksAndComments({
    Key key,
    this.title,
    this.bookId,
    this.pdfViewController

  }) : super(key: key);

  final String title;
  final int bookId;
  final PDFViewController pdfViewController;

  @override
  _BookmarksAndCommentsState createState() => _BookmarksAndCommentsState();
}

class _BookmarksAndCommentsState extends State<BookmarksAndComments> {
//  List<CommentAndBookmark> bookmarks;
  List<Comment> comments;
  var db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  removeBookmark(id, index, pageIndex, type){
    db.deleteCommentOrBookmarkById(id).then((value) {
    });
    setState(() {});
  }

  removeComment(id, index, pageIndex, type){
    db.deleteCommentOrBookmarkById(id);
    setState(() {});
  }

  bookmarkDeleteBG(){
    return Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 15.0),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            )
          ],
        )
    );
  }

//  bookmarkViewBG(){
//    return Container(
//        alignment: Alignment.centerRight,
//        padding: EdgeInsets.only(left: 15.0),
//        color: Colors.blue,
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.start,
//          children: <Widget>[
//            Padding(
//              padding: EdgeInsets.only(right: 15),
//              child: Icon(FontAwesomeIcons.chevronCircleRight,
//                color: Colors.white,
//              ),
//            ),
//            Text(
//              "View",
//              style: TextStyle(color: Colors.white),
//            )
//          ],
//        )
//    );
//  }

  Widget bookmarkList(){
    return FutureBuilder(
        future: db.getBookmarksOrComments(widget.bookId,DatabaseHelper.BOOKMARK),
        builder: (_, bookmarks) {
          if (bookmarks.connectionState == ConnectionState.waiting) {
            return Center(
                child: SpinKitChasingDots(
                  color: UtilColours.APP_BAR,
                  size: 50.0,
                )
            );
          } else {
            return bookmarks.data!.length > 0 ? ListView.builder(
                itemCount: bookmarks.data?.length,
                itemBuilder: (BuildContext context, int index){
                  var bookmark = bookmarks.data[index];
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction){
                      removeBookmark(bookmark.id, index, bookmark.pageIndex, DatabaseHelper.BOOKMARK );
                    },
                    background: bookmarkDeleteBG(),
//            secondaryBackground: bookmarkDeleteBG(),
                    child: Card(
                      child: ListTile(
                          title: Text((bookmark.pageIndex + 1).toString(), style: arabicTxtStyle(),),
                          leading: new Icon(Icons.bookmark, color: UtilColours.APP_BAR,),
                          trailing: new IconButton(icon: Icon(Icons.delete), onPressed: (){
                            removeBookmark(bookmark.id, index, bookmark.pageIndex, DatabaseHelper.BOOKMARK );
                          }),
                          onTap: () {
                            widget.pdfViewController.setPage(bookmark.pageIndex);
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                      ),
                    ),
                  );
                }) : noRecordFound('no_bookmarks!'.tr());
          }
        });
  }

  Widget noRecordFound(message){
    return Container(
        child: Center(
            child: Text(
              message,
              style:arabicTxtStyle(),
              textAlign: TextAlign.center,
            )
        )
    );
  }

  Widget commentList(){
    return FutureBuilder(
        future: db.getBookmarksOrComments(widget.bookId,DatabaseHelper.COMMENT),
        builder: (_, comments) {
          if (comments.connectionState == ConnectionState.waiting) {
            return Center(
                child: SpinKitChasingDots(
                  color: UtilColours.APP_BAR,
                  size: 50.0,
                )
            );
          } else {
            return comments.data.length > 0 ? ListView.builder(
                itemCount: comments.data.length,
                itemBuilder: (BuildContext context, int index){
                  var comment = comments.data[index];
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction){
                      removeComment(comment.id, index, comment.pageIndex, DatabaseHelper.COMMENT);
                    },
                    background: bookmarkDeleteBG(),
//            secondaryBackground: bookmarkDeleteBG(),
                    child: Card(
                      child: ListTile(
                          title: Text(comment.comment.toString(), style: arabicTxtStyle(paramSize: 18.0)),
                          leading: new Icon(Icons.comment, color: UtilColours.APP_BAR,),
                          subtitle:  Container(
                            child: Column(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
//                                Container(
//                                  child:   Text("Book: " + comment.bookName.toString(), style: arabicTxtStyle(paramSize: 18.0),),
//                                ),
                                Container(
                                  child:   Text("Page: " + (comment.pageIndex + 1).toString(), style: arabicTxtStyle(paramSize: 18.0)),
                                ),

                              ],
                            ),),

                          trailing: new IconButton(icon: Icon(Icons.delete), onPressed: (){
                            removeComment(comment.id, index,comment.pageIndex, DatabaseHelper.COMMENT );
                          }),
                          onTap: () {
                            widget.pdfViewController.setPage(comment.pageIndex);
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                      ),
                    ),
                  );
                }) : noRecordFound('no_comments'.tr());
          }
        });
  }


//  Widget commentList(){
//    return ListView.builder(
//        itemCount: comments.length,
//        padding: EdgeInsets.all(20.0),
//        itemBuilder: (BuildContext context, int index){
//          return Dismissible(
//            key: UniqueKey(),
//            onDismissed: (direction){
//              var comment = comments[index];
//              removeBookmark(index);
//            },
//            background: bookmarkDeleteBG(),
////            secondaryBackground: bookmarkDeleteBG(),
//            child: Card(
//              child: ListTile(
//                  title: Text(comments[index].page.toString()),
//                  leading: new Icon(Icons.bookmark, color: UtilColours.APP_BAR,),
//                  trailing: new Icon(Icons.delete),
//                  onTap: () {
//                    widget.pdfViewController.setPage(comments[index].page);
//                    Navigator.pop(context);
//                  }
//              ),
//            ),
//          );
//        });
//  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp (
        debugShowCheckedModeBanner: false,
        home:  DefaultTabController (
          length: 2,
          child: Container(
            height: double.infinity,
            decoration: appBackgroundGradient(),
            child: new Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back, color: UtilColours.APP_BAR),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: Colors.transparent,
//          backgroundColor: Color(0x44000000),
                elevation: 0,
                title: Text(widget.title,  style: arabicTxtStyle(paramColour: UtilColours.APP_BAR)),
                bottom: new TabBar(
                    isScrollable: true,
                    tabs: <Widget>[
                      Tab(
                        child: Container(
                          child: Text(
                            'bookmark'.tr(),
                            style: arabicTxtStyle(paramColour: UtilColours.APP_BAR, paramSize: 18.0),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Text(
                            'comment'.tr(),
                            style: arabicTxtStyle(paramColour: UtilColours.APP_BAR, paramSize: 18.0),
                          ),
                        ),
                      )
                    ]
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  Container(
                    child:  bookmarkList(),
//                    Column(
//                       children: <Widget>[
//                         IconButton(icon: Icon(Icons.view_list), onPressed: () {
//                           widget.pdfViewController.setPage(5);
//                           Navigator.pop(context);
//                         },),
//                       ],
//                    )
                  ),
                  Container(
                    child: commentList(),
                  )

                ],
              ),
            ),
          ),
        ),
        theme: ThemeData(primaryColor: Colors.deepOrange)
    );
  }
}


//class Bookmark extends StatefulWidget {
//  const Bookmark( { Key key}) : super(key:key);
//
//  @override
//  _BookmarkState createState() => _BookmarkState();
//}
//
//class _BookmarkState extends State<Bookmark> {
//  int colorVal = 0xffff5722;
//
//  @override
//  void initState(){
//    super.initState();
//  }
//
//  TabController _tabController;
//  @override
//  Widget build(BuildContext context) {
//    return
//      DefaultTabController (
//        length: 2,
//        child: Scaffold(
//          body: TabBarView(
//            controller: _tabController,
//            children: <Widget>[
//              Container(
//                  child: Text("ddd")
//              ),
//              Container(
//                  child: Text("ddd")
//              )
//
//            ],
//          ),
//        ),
//      );
//  }
//}
//
//
//class Comment extends StatefulWidget {
//  const Comment( { Key key}) : super(key:key);
//
//  @override
//  _CommentState createState() => _CommentState();
//}
//
//class _CommentState extends State<Comment> {
//  int colorVal = 0xffff5722;
//
//  @override
//  void initState(){
//    super.initState();
//  }
//
//  TabController _tabController;
//  @override
//  Widget build(BuildContext context) {
//    return
//      DefaultTabController (
//        length: 2,
//        child: Scaffold(
//          body: TabBarView(
//            controller: _tabController,
//            children: <Widget>[
//              Container(
//                  child: Text("ddd")
//              ),
//              Container(
//                  child: Text("ddd")
//              )
//            ],
//          ),
//        ),
//      );
//  }
//}