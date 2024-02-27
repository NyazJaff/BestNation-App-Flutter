import 'package:bestnation/Helper/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import '../../Helper/util.dart';
import '../../models/epic_model.dart';


class BooksController extends GetxController {
  var args = Get.arguments;
  var db = new DatabaseHelper();
  RxList records = [].obs;
  RxBool loading = true.obs;
  RxBool isThereNetwork = false.obs;
  var _productsSearcher = null;

  @override
  void onReady() {
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      pullDataFromNetwork();
    }
  }

  listenToHitSearch(){
    _productsSearcher.responses.listen((snapshot) {
      records.clear();
      for(var hit in snapshot.hits ) {
        print(hit['name']);
        print(hit['parentId']);
        Epic epic = db.formatAlgoliaHitForSave(hit,
            args['classType']); // eg, classType = DatabaseHelper.TEXT
        records.add(epic);
      }
    });
  }

  productsSearcher(){
    if(_productsSearcher != null) {
      return _productsSearcher;
    }
    _productsSearcher = HitsSearcher(applicationID: '9D19WMHJX8',
        apiKey: '88f4b5a0f116ad981e784e1302b2206c',
        indexName: 'books');
    return _productsSearcher;
  }

  algoliaBooksSearch(value,  {force = false}) async{
    if(value.length > 3 || force) {
      productsSearcher();
      listenToHitSearch();
      _productsSearcher.query(value);
    }else if(value == "") {
      pullDataFromNetwork();
    }
  }

  pullDataFromNetwork() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,);
    isThereNetwork.value = await hasNetwork();
    await _pullBooks();
  }

  _pullBooks() async {
    var cacheSource = Source.cache;
    if (isThereNetwork.value) {
      cacheSource = Source.server;
    }

    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("books_x")
        .where('parentId', isEqualTo: args['parentId'])
        .orderBy('order')
        .get(GetOptions(source: cacheSource));

    formatFirebaseDocuments(document);
    return records;
  }

  pullSingleBook(id) async{
    loading.value = true;
    Epic epic = Epic();
    await Firebase.initializeApp();
    final docRef = FirebaseFirestore.instance.collection("texts").doc(id);
    await docRef.get().then((DocumentSnapshot doc) {
      epic = db.formatEpicForSave(doc, args['classType']);
      print(epic.body);
    },
      onError: (e) => print("Error getting document: $e"),
    );
    loading.value = false;
    return epic;
  }

  formatFirebaseDocuments(document) async {
    await doFormat(document);
    loading.value = false;
  }

  doFormat(document) async {
    records.clear();
    await document.docs.forEach((document) async {
      Epic epic = db.formatEpicForSave(document,
          args['classType']); // eg, classType = DatabaseHelper.TEXT
      records.add(epic);
    });
    return records;
  }
}


