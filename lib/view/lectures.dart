import 'package:bestnation/controller/lecture_controller.dart';
import 'package:bestnation/view/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:bestnation/Helper/util.dart';
import 'package:get/get.dart';
import '../Helper/db_helper.dart';
import '../controller/audio_player_controller.dart';
import '../utilities/chasing_dots.dart';
import 'components/flat_downlod.dart';

class Lectures extends StatefulWidget {
  const Lectures({super.key});

  @override
  State<Lectures> createState() => _LecturesState();
}

class _LecturesState extends State<Lectures> {
  final LectureController lectureController = Get.find();
  final AudioPlayerController playerController =
      Get.put(AudioPlayerController());

  @override
  void dispose() {
    if (Get.previousRoute != "/lectures") {
      // playerController.player.pause();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        decoration: appBackgroundGradient(),
        child: Scaffold(
          appBar: appBar(context, lectureController.args['title']),
          backgroundColor: Colors.transparent,
          body: Obx(() => Stack(children: <Widget>[
                appBgImage(),
                new Padding(
                  padding: const EdgeInsets.all(10.0),
                ),
                lectureController.loading.value == true
                    ? displayLoading()
                    : lectureController.records.length > 0
                        ? epicsList()
                        : displayNoRecordFound() // No Record Found
                // Loading
              ])),
        ));
  }

  Widget displayNoRecordFound() {
    return Container(
        child: Center(
            child: Text(
      "no_records_currently_added!".tr,
      style: arabicTxtStyle(),
      textAlign: TextAlign.center,
    )));
  }



  Widget audioPlayer() {
    return AudioPlayer(audioList: lectureController.mp3List);
  }

  Widget epicsList() {
    return Column(children: [
      lectureController.displayPlayer.value == true
          ? audioPlayer()
          : Container(),
      Container(
          child: Expanded(
        child: ListView.separated(
          // scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: lectureController.records.length,
          itemBuilder: (BuildContext context, int index) {
            var entry = lectureController.records[index];
            return displayEachEntry(entry, index);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        ),
      )),
    ]);
  }

  Widget displayEachEntry(entry, index) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          decoration: playerController.currentIndex == index && entry.type == "RECORD"
              ? selectedListTileDec()
              : null,
          child: ListTile(
              title: displayRecordTitle(entry),
              leading: entry.type == "RECORD"
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: linearGradientBackground(),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          )),
                    )
                  : Icon(Icons.menu, color: UtilColours.APP_BAR),
              trailing: entry.type == "RECORD"
                  // ? listMenuItems(entry) : SizedBox.shrink(),
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FlatDownload(tag: entry.mp3URL),
                        // FlatFileDownloader(fileURL: entry.mp3URL)
                      ],
                    )
                  : SizedBox.shrink(),
              onTap: () {
                if (entry.type == "RECORD") {
                  playerController.createPlayer(
                      lectureController.mp3List, index);
                  playerController.player.play();
                } else {
                  innerNavigate(entry);
                }
              }),
        ));
  }

  Widget displayRecordTitle(entry) {
    return Text(entry.name.toString(), style: arabicTxtStyle(paramSize: 18.0));
  }

  innerNavigate(entry) {
    Get.to(
      () => Lectures(),
      arguments: {
        'title': entry.name.toString(),
        'parentId': entry.firebaseId,
        'classType': lectureController.args['classType']
      },
      preventDuplicates: false,
    );

    // Get.toNamed(
    //   "/lectures",
    //   arguments: {
    //     'title': entry.name.toString(),
    //     'parentId': entry.firebaseId,
    //     'classType': lectureController.args['classType']
    //   },
    //   preventDuplicates: false,
    // );
  }
}
