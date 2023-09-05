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
      case DatabaseHelper.LECTURES:
        await _pullLectures();
        break;
    }
    _createPlayList();
  }

  _pullLectures() async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("users")
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

  _createPlayList() async {
    String dir = await getSystemPath();
    if (displayPlayer.value == true) {
      for (final e in this.records) {
        if (e.filePathExists) {
          String savedPath =
              "$dir/" + e.mp3URL.substring(e.mp3URL.lastIndexOf("/") + 1);
          Uri url = Uri.file(savedPath);
          mp3List.add(ProgressiveAudioSource(url));
        } else if (isThereNetwork.value) {
          Uri url = Uri.parse(e.mp3URL);
          mp3List.add(AudioSource.uri(url));
        }
      }
    }
    update();
  }

  doFormat(document) async {
    await document.docs.forEach((document) async {
      Epic epic = db.formatEpicForSave(document,
          args['classType']); // eg, classType = DatabaseHelper.LECTURES
      if (document['type'] == 'RECORD') {
        displayPlayer.value = true;
        await doesUrlFileExits(document['mp3URL']).then((exists) {
          if (exists != null && exists.path != null) {
            epic.filePathExists = true;
            records.add(epic);
          } else if (isThereNetwork.value) {
            records.add(epic);
          }
        });
      } else {
        records.add(epic);
      }
    });
    update();
  }

}


