import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controller/live_broadcast_controller.dart';

class LiveBroadcast extends StatefulWidget {
  @override
  _LiveBroadcastState createState() => _LiveBroadcastState();
}

class _LiveBroadcastState extends State<LiveBroadcast> {
  final LiveBroadcastController playerController =
      Get.put(LiveBroadcastController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        decoration: appBackgroundGradient(),
        child: Scaffold(
          appBar: appBar(context, 'broadcast'.tr),
          backgroundColor: Colors.transparent,
          body: Stack(children: <Widget>[
            Positioned.fill(
                child: Align(
                    alignment: Alignment.center,
                    child: Obx(() => Column(
                      children: [
                        padding(),
                        createLogoDisplay('logo.png'),
                        padding(),
                        playerTitle(),
                        padding(),
                        playerController.isThereNetwork.value
                            ? playPauseButton(playerController.playing.value)
                            : noNetwork(),
                        nyazLogo(),
                      ],
                    ))
                )
            ),
          ]),
        ));
  }

  Widget playerTitle() {
    return playerController.isThereNetwork.value &&
            playerController.title.value != ""
        ? Container(
            decoration: valueBoxDecorationStyle,
            padding: EdgeInsets.all(10),
            width: 250,
            child: Text(playerController.title.value,
                style: arabicTxtStyle(paramSize: 20.0),
                textAlign: TextAlign.justify))
        : SizedBox.shrink();
  }

  Widget nyazLogo(){
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(bottom: 20),
          child: jaffLogo()),
    );
  }

  Widget playPauseButton(playing) {
    return
      playerController.loading.value
          ? displayLoading(size: 56.0)
      : playing == true
        ? IconButton(
            icon: const Icon(FontAwesomeIcons.pause),
            iconSize: 40,
            tooltip: 'pause'.tr,
            onPressed: () {
              playerController.playing.value = false;
              playerController.player.pause();
            },
          ) // Pause
        : IconButton(
            icon: const Icon(FontAwesomeIcons.play),
            iconSize: 40,
            tooltip: 'play'.tr,
            onPressed: () {
              playerController.playing.value = true;
              playerController.player.play();
            },
          );
  }

  Widget noNetwork() {
    return Icon(
      Icons.wifi_off,
      color: Colors.grey,
      size: 40,
    );
  }

  Widget padding() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
    );
  }
}
