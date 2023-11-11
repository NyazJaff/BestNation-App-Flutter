import 'package:audio_service/audio_service.dart';
import 'package:bestnation/controller/lecture_controller.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:just_audio/just_audio.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utilities/audio_player_handler.dart';

late AudioHandler _audioHandler;
class AudioPlayerController extends GetxController {
  AudioPlayer player = AudioPlayer();
  RxBool playing = false.obs;
  RxBool showBottomPlayer = false.obs;
  RxString bottomPlayerTitle = "".obs;
  RxBool loading = true.obs;
  RxInt currentIndex = 0.obs;
  RxDouble speed = 1.0.obs;
  var loopMode = LoopMode.all.obs;
  var duration = 0.0.obs;
  var position = 0.0.obs;
  var title = "";

  late AudioHandler _audioHandler;

  @override
  Future<void> onReady() async {
    controllerListeners();
  }

  setAudioHandler(handler){
    _audioHandler = handler;
  }

  @override
  void onClose() {
    // player.pause();
  }

  @override
  void onInit() async {
    super.onInit();
    // checkPermission();
  }


  controllerListeners() {
    player.durationStream.listen((durationStream) {
      duration.value = durationStream!.inSeconds.toDouble();
    });

    player.speedStream.listen((event) {
      speed.value = event;
    });

    player.positionStream.listen((positionStream) {
      position.value = positionStream.inSeconds.toDouble();
    });

    player.playingStream.listen((playingStream) {
      playing.value = playingStream;
    });

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

  labelSecondsToMinutes(seconds) {
    Duration dd = Duration(seconds: seconds);
    final HH = (dd.inHours).toString().padLeft(2, '0');
    final mm = (dd.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (dd.inSeconds % 60).toString().padLeft(2, '0');
    return '$HH:$mm:$ss';
  }

  createPlayer(entry) async {
    final _item = MediaItem(
      id: entry.mp3URL,
      title: entry.name ,
      artUri: Uri.file('assets/brand/lunch_icon.jpg'),
    );
    _audioHandler.playMediaItem(_item);
    // await player.setAudioSource(ConcatenatingAudioSource(children: mp3List),
    //     initialIndex: index, initialPosition: Duration.zero);
  }

  changeDuration(seconds) {
    var duration = Duration(seconds: seconds);
    player.seek(duration);
  }

  hasNext() {
    return player.hasNext;
  }

  hasPrevious() {
    return player.hasPrevious;
  }

  checkPermission() async {
    var perm = await Permission.storage.request();
    if (perm.isGranted) {
    } else {
      checkPermission();
    }
  }
}
