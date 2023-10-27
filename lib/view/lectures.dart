import 'package:bestnation/controller/lecture_controller.dart';
import 'package:bestnation/view/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:bestnation/Helper/util.dart';
import 'package:get/get.dart';
import '../Helper/db_helper.dart';
import '../controller/audio_player_controller.dart';
import '../utilities/chasing_dots.dart';
import 'bottom_audio_player_panel.dart';
import 'components/flat_downlod.dart';

class Lectures extends StatefulWidget {
  const Lectures({super.key});

  @override
  State<Lectures> createState() => _LecturesState();
}

class _LecturesState extends State<Lectures> {
  final LectureController lectureController = Get.find();
  final _searchTextController = TextEditingController();
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
    if(playerController.playing.value == false){
      playerController.title = lectureController.args['title'];
    }

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
                    : epicsList()  // No Record Found
                // Loading
              ])),
        ));
  }

  Widget audioPlayer() {
    return AudioPlayer(audioList: lectureController.mp3List);
  }

  Widget epicsList() {
    return Column(children: [
      lectureController.displayPlayer.value == true
          ? audioPlayer()
          : searchBox(),
      SizedBox(height: 15),
      lectureController.records.length > 0
          ? Container(
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
          ))
          : displayNoRecordFound(),
      BottomAudioPlayerPanel(),
    ]);
  }

  Widget displayEachEntry(entry, index) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          decoration:
              playerController.currentIndex == index && entry.type == "RECORD"
                  ? selectedListTileDec()
                  : null,
          child: ListTile(
              title: displayRecordTitle(entry),
              leading: entry.type == "RECORD"
                  ? listTileEntryPlayButton(entry, index)
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
              onTap: () async {
                if (entry.type == "RECORD") {

                  playerController.currentIndex.value = index;
                  await lectureController.addEpicToPlayList(entry);
                  await playerController.createPlayer(
                      lectureController.mp3List, 0);
                  playerController.player.play();
                  playerController.showBottomPlayer.value = true;
                  playerController.bottomPlayerTitle.value = entry.name;
                } else {
                  innerNavigate(entry);
                }
              }),
        ));
  }

  Widget listTileEntryPlayButton(entry, index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
          width: 40,
          height: 40,
          decoration: linearGradientBackground(),
          child: Icon(
            playerController.currentIndex == index &&
                    entry.type == "RECORD" &&
                    playerController.playing.value == true
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.white,
          )),
    );
  }

  Widget displayRecordTitle(entry) {
    return Text(entry.name.toString(), style: arabicTxtStyle(paramSize: 18.0));
  }

  Widget searchBox() {
    return Container(
        decoration: valueBoxDecorationStyle,
        width: 250,
        height: 50,
        child: Center(
          child: ListTile(
              title: TextField(
                controller: _searchTextController,
                onChanged: (String value) {
                  lectureController.algoliaLectureSearch(value);
                },
                style: TextStyle(
                    color: textAndIconColour,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'search'.tr,
                    hintStyle: valueHintBoxDecorationStyle),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                iconSize: 30,
                tooltip: 'stop'.tr,
                onPressed: () {},
              )),
        ));
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
  }
}
