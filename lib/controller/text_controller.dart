import 'package:bestnation/Helper/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../Helper/util.dart';
import '../models/epic_model.dart';
import 'audio_player_controller.dart';

class TextController extends GetxController {
  var args = Get.arguments;
  var db = new DatabaseHelper();
  RxList records = [].obs;
  RxBool loading = true.obs;
  RxBool isThereNetwork = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      pullDataFromNetwork();
    }
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

  formatFirebaseDocuments(document) async {
    await doFormat(document);
    // records.sort((b, a) => a.firebaseId.compareTo(b.firebaseId)); // Sort Records
    loading.value = false;
  }

  doFormat(document) async {
    await document.docs.forEach((document) async {
      print(document);
      Epic epic = db.formatEpicForSave(document,
          args['classType']); // eg, classType = DatabaseHelper.TEXT
      records.add(epic);
    });
    return records;
  }

}


