import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../Helper/util.dart';
import '../controller/audio_player_controller.dart';
import '../utilities/layout_helper.dart';

class AudioPlayer extends StatefulWidget {
  final List<AudioSource> audioList;

  const AudioPlayer({super.key, required this.audioList});

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  double current_value = 0;
  final AudioPlayerController playerController =
      Get.put(AudioPlayerController());

  @override
  void initState() {
    super.initState();
    playerController.createPlayer(widget.audioList, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            controlButtons(),
            slider(),
            durationLabel(),
          ],
        ));
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
                    tooltip: 'Pause',
                    onPressed: () {
                      playerController.player.pause();
                      playerController.playing.value = false;
                    },
                  ) // Pause
                : IconButton(
                    icon: const Icon(FontAwesomeIcons.play),
                    iconSize: 40,
                    tooltip: 'Play',
                    onPressed: () {
                      playerController.player.play();
                    },
                  ),
        key: ValueKey<int>(playerController.loading.value ? 1 : 2),
      ),
    );
  }

  Widget nextButton() {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.backwardStep),
      color:
          playerController.hasNext() && playerController.loading.value == false
              ? Colors.black
              : Colors.grey,
      tooltip: 'Next',
      onPressed: () {
        playerController.player.seekToNext();
      },
    );
  }

  Widget previousButton() {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.forwardStep),
      color:
          playerController.currentIndex.value == 0 ? Colors.grey : Colors.black,
      tooltip: 'Previous',
      onPressed: () {
        playerController.player.seekToPrevious();
      },
    );
  }

  Widget controlButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      previousButton(), // Previous
      playPauseButton(),
      nextButton(), // N
      adjustSpeed() // ext// Faster
    ]);
  }

  Widget adjustSpeed() {

    return IconButton(
      icon: const Icon(FontAwesomeIcons.gauge),
      color:
      playerController.hasNext() && playerController.loading.value == false
          ? Colors.black
          : Colors.grey,
      tooltip: 'Next',
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 15),
                  Text('adjust_speed'.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0)),
                  SizedBox(height: 15),
                  Text('1.5',
                      style: TextStyle(
                          fontFamily: 'Fixed',
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      valueIndicatorColor: Colors.blue, // This is what you are asking for
                      inactiveTrackColor: Color(0xFF8D8E98), // Custom Gray Color
                      activeTrackColor: Colors.red,
                      thumbColor: UtilColours.PROGRESS,
                      // overlayColor: Color(0x29EB1555),  // Custom Thumb overlay Color
                      // thumbShape:
                      // RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      // overlayShape:
                      // RoundSliderOverlayShape(overlayRadius: 20.0),
                    ),
                    child: Slider(
                      divisions: 10,
                      min: 0.5,
                      max: 1.5,
                      value:  1.0,
                      onChanged: (seconds) {

                      },
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget slider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 5.0,
        thumbColor: Color(0xff00d6c0),
        inactiveTrackColor: Color(0xFF8D8E98),
        activeTickMarkColor: Color(0xff00d6c0),
        valueIndicatorColor: Color(0xff00d6c0),
        activeTrackColor: Color(0xff00d6c0),
        inactiveTickMarkColor: Colors.white,
        overlayColor: Color(0xff00d6c0).withOpacity(0.2),
        tickMarkShape: RoundSliderTickMarkShape(),
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      ),
      child: Slider(
        min: 0.0,
        max: playerController.duration.toDouble(),
        value: playerController.position.toDouble(),
        divisions: 100,
        label: playerController
            .labelSecondsToMinutes(playerController.position.value.toInt()),
        onChanged: (seconds) {
          playerController.changeDuration(seconds.toInt());
        },
      ),
    );
  }

  Widget durationLabel() {
    return Container(
      padding: EdgeInsets.only(left: 30.0, right: 20.0),
      // margin: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(playerController
              .labelSecondsToMinutes(playerController.duration.value.toInt())),
          Text(playerController
              .labelSecondsToMinutes(playerController.position.value.toInt())),
        ],
      ),
    );
  }
}
