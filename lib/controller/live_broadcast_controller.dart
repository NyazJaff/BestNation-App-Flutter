import 'package:bestnation/controller/lecture_controller.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio/just_audio.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bestnation/Helper/util.dart';

class LiveBroadcastController extends GetxController {
  AudioPlayer player = AudioPlayer();
  RxString title = "".obs;
  RxString url = "".obs;
  RxBool playing = false.obs;
  RxBool loading = true.obs;
  RxBool isThereNetwork = false.obs;

  @override
  void onInit() async {
    super.onInit();
    checkPermission();
  }

  @override
  void onReady() {
    controllerListeners();
    _pullConfig();
  }

  @override
  void onClose() {
    player.dispose();
  }

  _pullConfig() async {
    isThereNetwork.value = await hasNetwork();
    await Firebase.initializeApp();
    Stream config = FirebaseFirestore.instance
        .collection('config')
        .doc('LIVE_STREAM')
        .snapshots();
    config.listen((value) {
      title.value = value.data()['title'];
      url.value = value.data()['url'];
      _init();
    });
  }

  _init() async {
    try {
      print(url);
      await player.setUrl(url.value);
      player.play();
      playing.value = true;
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured when initialising mp3 player $e");
    }
  }

  controllerListeners(){
    player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          loading.value = true;
          print('idle');
        case ProcessingState.loading:
          print('loading');
          loading.value = true;
        case ProcessingState.buffering:
          print('buffering');
          loading.value = true;
        case ProcessingState.ready:
          print('ready');
          loading.value = false;
          player.currentIndexStream.listen((currentIndexStream) {
            if (currentIndexStream != null) {
              // currentIndex.value = currentIndexStream; # because we not running in a placelist mode anymore
            }
          });
        case ProcessingState.completed:
          loading.value = false;
          print('completed');
      }
    });
  }

  checkPermission() async {
    var perm = await Permission.storage.request();
    if (perm.isGranted) {
    } else {
      checkPermission();
    }
  }
}
