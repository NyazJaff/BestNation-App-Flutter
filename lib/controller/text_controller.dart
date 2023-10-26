import 'package:bestnation/Helper/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../Helper/util.dart';
import '../models/epic_model.dart';
import '../utilities/search_metadata.dart';
import 'audio_player_controller.dart';
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';


class TextController extends GetxController {
  var args = Get.arguments;
  var db = new DatabaseHelper();
  RxList records = [].obs;
  RxBool loading = true.obs;
  RxBool isThereNetwork = false.obs;

  final _productsSearcher = HitsSearcher(applicationID: '9D19WMHJX8',
      apiKey: '88f4b5a0f116ad981e784e1302b2206c',
      indexName: 'texts');


  @override
  void onReady() {
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

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      pullDataFromNetwork();
    }
  }


  fullSearchData(value) async {
    if(value != "") {
      listenToHitSearch();
      _productsSearcher.query(value);
    }else {
      pullDataFromNetwork();
    }
    // print(await _productsSearcher.responses.map(SearchMetadata.fromResponse));
  }

  pullDataFromNetwork() async {
    await Firebase.initializeApp();
    isThereNetwork.value = await hasNetwork();
    switch (Get.arguments['classType']) {
      case DatabaseHelper.TEXTS:
        await _pullTexts();
        break;
    }
  }

  _pullTexts() async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("texts")
        .where('parentId', isEqualTo: args['parentId'])
        .orderBy('order')
        .get();

    formatFirebaseDocuments(document);
    return records;
  }

  pullSingleText(id) async{
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
    // records.sort((b, a) => a.firebaseId.compareTo(b.firebaseId)); // Sort Records
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


