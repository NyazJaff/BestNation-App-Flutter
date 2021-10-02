import 'dart:io';
import 'package:bestnation/models/book_model.dart';
import 'package:bestnation/models/comments_and_bookmarks_model.dart';
import 'package:bestnation/models/epic_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static const String COMMENT = "COMMENT";
  static const String BOOKMARK = "BOOKMARK";
  static const String QUESTION_AND_ANSWER = "QUESTION_AND_ANSWER";
  static const String LECTURES = "LECTURE"; //currently not saving to db
  static const String TEXTS = "TEXT"; //currently not saving to db
  static const String SPEECH = "SPEECH"; //currently not saving to db

  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper()=>_instance;
  static Database _db;

  Future<Database>get db async{
    if(_db != null){
      return _db;
    }
    _db = await initDb();
    return _db;
  }
  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "abdullahAlSaad.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE Book ("
        "id INTEGER PRIMARY KEY, "
        "name TEXT, "
        "description TEXT, "
        "pdfURL TEXT, "
        "imageURL TEXT"
        ")");
    print("Table Book is created");

    await db.execute("CREATE TABLE CommentAndBookmark ("
        "id INTEGER PRIMARY KEY, "
        "bookId INTEGER, "
        "pageIndex INTEGER, "
        "comment TEXT, "
        "type TEXT, "
        "CONSTRAINT kf_book "
        "FOREIGN KEY (bookId) "
        "REFERENCES Book(id)"
        ")");
    print("Table CommentAndBookmark is created");

    await db.execute("CREATE TABLE Epic ("
        "id INTEGER PRIMARY KEY, "
        "parentId INTEGER, "
        "firebaseId INTEGER, "
        "name TEXT, "
        "title TEXT, "
        "body TEXT, "
        "question TEXT, "
        "answer TEXT, "
        "mp3URL TEXT, "
        "pdfURL TEXT, "
        "createdTime TEXT, "
        "type TEXT, "
        "category TEXT "
        ")");
    print("Table Epic is created");
  }

  Epic formatEpicForSave(DocumentSnapshot documents, String category) {
    var document = documents.data();
    return new Epic(
      parentId: document['parentId'] != null ? document['parentId'] : "",
      firebaseId: documents.id != null ? documents.id : "",
      name: document['name'] != null ? document['name'] : document['tile'] != null ?  document['tile'] : '',
      body: document['body'] != null ? document['body'] : '',
      title: document['tile'] != null ? document['tile'] : '',
      question: document['question'] != null ? document['question'] : "",
      answer: document['answer'] != null ? document['answer'] : "",
      createdTime: document['createdTime'] != null ? document['createdTime'] : "",
      mp3URL: document['mp3URL'] != null ? document['mp3URL'] : "",
      pdfURL: document['pdfURL'] != null ? document['pdfURL'] : "",
      type: document['type'] != null ? document['type'] : "",
      category: category,
    );
  }

  Epic formatEpicForReturn(Map<String, dynamic> map){
    return new Epic(
      id: map['id'],
      parentId: map['parentId'],
      firebaseId: map['firebaseId'],
      name: map['name'],
      title: map['title'],
      question: map['question'],
      answer: map['answer'],
      mp3URL: map['mp3URL'],
      pdfURL: map['pdfURL'],
      createdTime: map['createdTime'],
      type: map['type'],
//        category: maps[i]['category'],
    );
  }

  saveEpic(Epic epic) async {
    var dbClient = await db;
    int res = await dbClient.insert(("Epic"), epic.toMap());
  }

  largestEpicFirebaseId(category) async {
    var dbClient = await db;
    List<Map> result =  await dbClient.rawQuery(
        "SELECT MAX(firebaseId) as firebaseId from Epic where category=? ", [category]
    );
    int largestId = 0;
    result.forEach((element) {
      if(element['firebaseId'] != null){
        largestId = element['firebaseId'];
      }
    });
    return largestId;
  }

  Future<List<Epic>> getQandA(int parentId){
    return epics(extraQuery:"WHERE category = '$QUESTION_AND_ANSWER' AND parentId = $parentId ");
  }

  Future<List<Epic>> epics({String extraQuery : ""}) async {
    // Get a reference to the database.
    var dbClient = await db;
    try {
      String query = "SELECT * FROM Epic " + extraQuery ;
      // Query the table for all The Epics.
      final List<Map<String, dynamic>> maps = await dbClient.rawQuery(query);
      // Convert the List<Map<String, dynamic> into a List<Epic>.
      return List.generate(maps.length, (i) {
        return formatEpicForReturn(maps[i]);
      });
    } on Exception catch (_) {
      print(_);
      return [];
    }
  }

  Future<int> deleteEpic() async {
    var dbClient = await db;
    int res = await dbClient.delete("Epic");
    return res;
  }

  Future<Book> bookByPdfUrl(pdfURL) async {
    var dbClient = await db;

    List<Map> result =  await dbClient.rawQuery("SELECT * from Book where pdfURL = ? limit 1", [pdfURL]);
    return formatBookForReturn(result[0]);
  }

  largestBookId() async {
    var dbClient = await db;
    List<Map> result =  await dbClient.rawQuery("SELECT MAX(id) as id from Book");
    int largestId = 0;
    result.forEach((element) {
      if(element['id'] != null){
        largestId = element['id'];
      }
    });
    return largestId;
  }

  Future<int> saveBook(Book book) async {
    var dbClient = await db;
    int res = await dbClient.insert(("Book"), book.toMap());
    return res;
  }

  Future<int> deleteBook() async {
    var dbClient = await db;
    int res = await dbClient.delete("Book");
    return res;
  }

  Future<List<Book>> books() async {
    // Get a reference to the database.
    var dbClient = await db;

    // Query the table for all The Books.
    final List<Map<String, dynamic>> maps = await dbClient.query('book');

    // Convert the List<Map<String, dynamic> into a List<Book>.
    return List.generate(maps.length, (i) {
      return formatBookForReturn(maps[i]);
    });
  }

  Book formatBookForReturn(Map<String, dynamic> map){
    return Book(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageURL: map['imageURL'],
      pdfURL: map['pdfURL'],
    );
  }

  Future<int> saveCommentOrBookmark(CommentAndBookmark object) async {
    var dbClient = await db;
    int res = await dbClient.insert(("CommentAndBookmark"), object.toMap());
    return res;
  }

  Future<int> deleteAllCommentOrBookmark() async {
    var dbClient = await db;
    int res = await dbClient.delete("CommentAndBookmark");
    return res;
  }

  Future<List<CommentAndBookmark>> getBookmarksOrComments(int bookId, String type) async {
    var dbClient = await db;
    List<Map> maps =  await dbClient.rawQuery("SELECT * from CommentAndBookmark where bookId=? and type=? order by pageIndex DESC", [bookId, type]);
    return List.generate(maps.length, (i) {
      return CommentAndBookmark(
        id: maps[i]['id'],
        bookId: maps[i]['bookId'],
        pageIndex: maps[i]['pageIndex'],
        comment: maps[i]['comment'],
        type: maps[i]['type'],
      );
    });
  }

  Future<bool> checkIfPageMarkedBookmark(int bookId, int pageIndex) async{
    var dbClient = await db;
    List<Map> result =  await dbClient.rawQuery("SELECT * from CommentAndBookmark where bookId=? and pageIndex=? and type=?", [bookId, pageIndex, BOOKMARK]);
    if (result.length > 0){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteCommentOrBookmarkById(int id) async{
    var dbClient = await db;
    var deleted = false;

    dbClient.rawDelete('DELETE FROM CommentAndBookmark where id=?', [id]).then((value) {
      deleted = true;
    });
    return deleted;
  }

//  updatePageBookmarkStatus(int bookId, int pageIndex, status )
  Future<bool> deleteCommentOrBookmark(int bookId, int pageIndex, String type) async{
    var dbClient = await db;
    var deleted = false;

    dbClient.rawDelete('DELETE FROM CommentAndBookmark where bookId=? and pageIndex=? and type=?', [bookId, pageIndex, type]).then((value) {
      deleted = true;
    });
    return deleted;
  }
}