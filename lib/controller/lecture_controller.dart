import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:bestnation/Helper/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../Helper/util.dart';
import '../models/epic_model.dart';
import 'audio_player_controller.dart';

class LectureController extends GetxController {
  var args = Get.arguments;
  var db = new DatabaseHelper();
  RxBool displayPlayer = false.obs;
  RxList records = [].obs;
  RxBool loading = true.obs;
  RxBool isThereNetwork = false.obs;

  List<AudioSource> mp3List = [];

  final _productsSearcher = HitsSearcher(applicationID: '9D19WMHJX8',
      apiKey: '88f4b5a0f116ad981e784e1302b2206c',
      indexName: 'lectures');

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      pullDataFromNetwork();
    }
  }

  pullDataFromNetwork() async {
    FirebaseFirestore.instance.settings =
    const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,);
    isThereNetwork.value = await hasNetwork();
    switch (Get.arguments['classType']) {
      case DatabaseHelper.LECTURES:
        await _pullLectures();
        break;
    }
    addEpicToPlayList(records.first);
  }

  _pullLectures() async {
    var cacheSource = Source.cache;
    if (isThereNetwork.value) {
      cacheSource = Source.server;
    }
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("users")
        .where('parentId', isEqualTo: args['parentId'])
        .orderBy('order')
        .get(GetOptions(source: cacheSource));

    await formatFirebaseDocuments(document);
  }

  formatFirebaseDocuments(document) async {
    await doFormat(document);
    // records.sort((b, a) => a.firebaseId.compareTo(b.firebaseId)); // Sort Records
    loading.value = false;
  }

  _createPlayList() async {
    if (displayPlayer.value == true) {
      for (final e in this.records) {
        await addEpicToPlayList(e);
      }
    }
  }

  addEpicToPlayList(entry) async {
    mp3List.clear();
    String dir = await getSystemPath();
    await doesUrlFileExits(entry.mp3URL).then((exists) async{
      if (exists != null) {
        String savedPath =
            "$dir/" + entry.mp3URL.substring(entry.mp3URL.lastIndexOf("/") + 1);
        Uri url = Uri.file(savedPath);
        mp3List.add(ProgressiveAudioSource(url));
      }else {
        Uri url = Uri.parse(entry.mp3URL);
        mp3List.add(AudioSource.uri(url));
      }
    });
  }

  doFormat(document) async {
    this.records.clear();
    await document.docs.forEach((document) async {
      Epic epic = db.formatEpicForSave(document,
          args['classType']); // eg, classType = DatabaseHelper.LECTURES
      if (document['type'] == 'RECORD') {
        displayPlayer.value = true;
        this.records.add(epic);
      } else {
        this.records.add(epic);
      }
    });
    update();
  }

  // Algolia
  algoliaLectureSearch(value) async{
    if(value != "") {
      listenToHitSearch();
      _productsSearcher.query(value);
    }else {
      pullDataFromNetwork();
    }
  }

  listenToHitSearch(){
    _productsSearcher.responses.listen((snapshot) {
      records.clear();
      for(var hit in snapshot.hits ) {
        Epic epic = db.formatAlgoliaHitForSave(hit,
            args['classType']); // eg, classType = DatabaseHelper.TEXT
        records.add(epic);
      }
    });
  }
}


