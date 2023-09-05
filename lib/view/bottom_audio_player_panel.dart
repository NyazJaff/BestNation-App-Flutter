import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../controller/audio_player_controller.dart';
import '../Helper/util.dart';
import '../controller/lecture_controller.dart';
import '../utilities/layout_helper.dart';

class BottomAudioPlayerPanel extends StatefulWidget {
  const BottomAudioPlayerPanel({super.key});

  @override
  State<BottomAudioPlayerPanel> createState() => _BottomAudioPlayerPanelState();
}

class _BottomAudioPlayerPanelState extends State<BottomAudioPlayerPanel> {
  final AudioPlayerController playerController =
      Get.put(AudioPlayerController());
  final LectureController lectureController = Get.find();

  @override
  Widget build(BuildContext context) {
    String? routeName = '';
    var route = ModalRoute.of(context);
    if(route!=null){
      routeName = route.settings.name;
    }
    return Obx(() => playerController.showBottomPlayer.value == true
        && ((lectureController.records.length > 0 && lectureController.records[0].type != "RECORD") || routeName == '/')
        ? Stack(
      children: [
        card(),
        // displayCliphic(),
        tile(),
      ],
    )
        : Container());
  }

  Widget tile() {
    return ListTile(
      visualDensity: VisualDensity(vertical: 4),
      title: createTitle(playerController.title),
      subtitle: duration(),
      leading: IconButton(
        icon: const Icon(
          Icons.stop_circle,
          color: Colors.black,
        ),
        iconSize: 30,
        tooltip: 'stop'.tr,
        onPressed: () {
          playerController.player.stop();
          playerController.showBottomPlayer.value = false;

        },
      ),
      trailing: playerController.playing.value == true
          ? IconButton(
        icon: const Icon(
          FontAwesomeIcons.pause,
          color: Colors.white70,
        ),
        iconSize: 40,
        tooltip: 'pause'.tr,
        onPressed: () {
          playerController.player.pause();
          playerController.playing.value = false;
        },
      ) // Pause
          : IconButton(
        icon:
        const Icon(FontAwesomeIcons.play, color: Colors.white70),
        iconSize: 40,
        tooltip: 'play'.tr,
        onPressed: () {
          playerController.player.play();
        },
      ),
    );
  }

  Widget duration() {
    return Text(
        playerController
            .labelSecondsToMinutes(playerController.position.value.toInt()),
        style: TextStyle(fontSize: 15.0));
  }

  Widget createTitle(text) {
    return Container(
        child: Text(
      text,
      style: arabicTxtStyle(paramSize: 20, paramBold: true),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    ));
  }

  Widget displayCliphic() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          opacity: 0.1,
          scale: 1,
          image: AssetImage('assets/brand/text-view-heading.png'),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: 70,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        onPressed: () async {},
        child: null,
      ),
    );
  }

  Widget card() {
    return Container(
      decoration: linearGradientBackground(radius: 0.0),
      width: MediaQuery.of(context).size.width,
      height: 70,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        onPressed: () async {},
        child: null,
      ),
    );
  }

  Widget playPauseButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Container(
        child: playerController.loading.value
            ? displayLoading(size: 56.0)
            : playerController.playing.value == true
                ? IconButton(
                    icon: const Icon(FontAwesomeIcons.pause),
                    iconSize: 40,
                    tooltip: 'pause'.tr,
                    onPressed: () {
                      playerController.player.pause();
                      playerController.playing.value = false;
                    },
                  ) // Pause
                : IconButton(
                    icon: const Icon(FontAwesomeIcons.play),
                    iconSize: 40,
                    tooltip: 'play'.tr,
                    onPressed: () {
                      playerController.player.play();
                    },
                  ), // Play
        key: ValueKey<int>(playerController.loading.value ? 1 : 2),
      ),
    );
  }
}
