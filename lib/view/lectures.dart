import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/models/epic_model.dart';
import 'package:bestnation/utilities/flat_file_downloader.dart';
import 'package:bestnation/view/mp3_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:bestnation/utilities/chasing_dots.dart';
import 'package:just_audio/just_audio.dart';
import '../Helper/db_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class Lectures extends StatefulWidget {
  Lectures({
    Key key,
    this.title,
    this.parentId,
    this.classType,
  }) : super(key: key);

  final String title;
  final String parentId;
  final String classType;

  @override
  _LecturesState createState() => _LecturesState();
}

class _LecturesState extends State<Lectures> {
  var db = new DatabaseHelper();
  List<Epic> records = [];

  bool loading = true;
  bool _displayPlayer = false;
  AudioPlayer _player;
  List<AudioSource> mp3List = [];
  bool isThereNetwork = false;

  ConcatenatingAudioSource _playlist;

  @override
  void initState() {
    super.initState();
    pullDataFromNetwork();

    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  _createPlayList() async {
    String dir = await getSystemPath();
    if (_displayPlayer == true) {
      for (final e in this.records) {
        if(e.filePathExists){
          String savedPath =
              "$dir/" + e.mp3URL.substring(e.mp3URL.lastIndexOf("/") + 1);
          Uri url = Uri.file(savedPath);
          mp3List.add(ProgressiveAudioSource(url));
        }else if (isThereNetwork) {
          Uri url = Uri.parse(e.mp3URL);
          mp3List.add(AudioSource.uri(url));
        };
      }
    }

    return ConcatenatingAudioSource(children: mp3List);
  }

  _init() async {
    try {
      _playlist = await _createPlayList();
      await _player.setAudioSource(_playlist);
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured when initialising mp3 player $e");
    }
  }

  pullDataFromNetwork() async {
    await Firebase.initializeApp();
    isThereNetwork = await hasNetwork();
    switch (widget.classType) {
      case DatabaseHelper.LECTURES:
        await _pullLectures();
        break;
      case DatabaseHelper.SPEECH:
        await _pullSpeech();
        break;
    }

    if (_displayPlayer == true) {
      _init();
    }
    setState(() {});
  }

  _pullSpeech() async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("Lecture")
        .where('parentId', isEqualTo: widget.parentId)
        .where('fragmentName', isEqualTo: 'speech')
        .get();

    formatFirebaseDocuments(document);
    return records;
  }

  _pullLectures() async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("users")
        .where('parentId', isEqualTo: widget.parentId)
        .orderBy('order')
        .get();

    formatFirebaseDocuments(document);
    return records;
  }

  formatFirebaseDocuments(document) async {
    await doFormat(document);
    // records.sort((b, a) => a.firebaseId.compareTo(b.firebaseId)); // Sort Records
    loading = false;
    return records;
  }

  doFormat(document) async {
    await document.docs.forEach((document) async {
      if (document['type'] == 'RECORD') {
        _displayPlayer = true;
        setState(() {
        });
      }
      Epic epic = db.formatEpicForSave(document,
          widget.classType); // eg, classType = DatabaseHelper.LECTURES
      // await db.saveEpic(epic);
      if (document['type'] == 'RECORD') {
        await doesUrlFileExits(document['mp3URL']).then((exists) {
          if (exists != null && exists.path != null) {

            epic.filePathExists = true;
            records.add(epic);
          }else if(isThereNetwork){
            records.add(epic);
          }
        });
      } else {
        records.add(epic);
      }

      setState(() {});
    });
  }

  innerNavigate(title, firebaseId) {
    var classToCall = Lectures(
        title: title,
        parentId: firebaseId,
        classType: widget.classType,
        key: UniqueKey());
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => classToCall));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        decoration: appBackgroundGradient(),
        child: Scaffold(
          appBar: app_bar(context, widget.title),
          backgroundColor: Colors.transparent,
          body: Stack(children: <Widget>[
            appBgImage(),
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),
            loading == false
                ? records.length > 0
                    ? Column(
                        children: [
                          _displayPlayer == true
                              ? ControlButtons(_player, true)
                              : Container(),
                          _displayPlayer == true
                              ? StreamBuilder<Duration>(
                                  stream: _player.durationStream,
                                  builder: (context, snapshot) {
                                    final duration =
                                        snapshot.data ?? Duration.zero;
                                    return StreamBuilder<Duration>(
                                      stream: _player.positionStream,
                                      builder: (context, snapshot) {
                                        var position =
                                            snapshot.data ?? Duration.zero;
                                        if (position > duration) {
                                          position = duration;
                                        }
                                        return SliderTheme(
                                          data:
                                              SliderTheme.of(context).copyWith(
                                            valueIndicatorColor: Colors.blue,
                                            // This is what you are asking for
                                            inactiveTrackColor:
                                                Color(0xFF8D8E98),
                                            // Custom Gray Color
                                            activeTrackColor:
                                                UtilColours.PROGRESS,
                                            thumbColor: UtilColours.PROGRESS,
                                            // overlayColor: Color(0x29EB1555),  // Custom Thumb overlay Color
                                            // thumbShape:
                                            // RoundSliderThumbShape(enabledThumbRadius: 12.0),
                                            // overlayShape:
                                            // RoundSliderOverlayShape(overlayRadius: 20.0),
                                          ),
                                          child: SeekBar(
                                            duration: duration,
                                            position: position,
                                            onChangeEnd: (newPosition) {
                                              _player.seek(newPosition);
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Container(),
                          // Mp3Player(title: 'asa', key: UniqueKey(),),
                          Container(
                              child: _displayPlayer == true
                                  ? StreamBuilder<SequenceState>(
                                      stream: _player.sequenceStateStream,
                                      builder: (context, snapshot) {
                                        final state = snapshot.data;
                                        if (state != null) {
                                          return epicsList(state);
                                        } else {
                                          return Container();
                                        }
                                      },
                                    )
                                  : epicsList(null)),
                        ],
                      ) // Display Record
                    : Container(
                        child: Center(
                            child: Text(
                        "no_records_currently_added!".tr(),
                        style: arabicTxtStyle(),
                        textAlign: TextAlign.center,
                      ))) // No Record Found
                : Container(
                    child: Center(
                        child: SpinKitChasingDots(
                    color: UtilColours.APP_BAR,
                    size: 50.0,
                  ))) // Loading
          ]),
        ));
  }

  // Widget listMenuItems(entry) {
  //   return PopupMenuButton(itemBuilder: (context) {
  //     return [
  //       PopupMenuItem(
  //         value: 'download',
  //         child: Column(
  //           children: <Widget>[
  //             // FileDownloader(fileURL: entry.mp3URL, openBook: () => {}, doneTitle: '', maxWidth: 80.0,),
  //             TextButton.icon(
  //                 onPressed: () => {
  //                       Share.share(shareTextFormatter(
  //                           entry.name + "\n\n\n" + entry.mp3URL))
  //                     },
  //                 icon: Icon(Icons.share, color: UtilColours.APP_BAR),
  //                 label: Text('تحميل', style: arabicTxtStyle(paramSize: 15))),
  //             SizedBox(
  //               width: 85.0,
  //               child: FutureBuilder(
  //                 builder: (context, exists) {
  //                   if (exists.connectionState == ConnectionState.done &&
  //                       exists.data == null) {
  //                     return FileDownloader(
  //                       fileURL: entry.mp3URL,
  //                       openBook: (val) => {},
  //                       doneTitle: '',
  //                     );
  //                   }
  //                   return Container();
  //                 },
  //                 future: doesUrlFileExits(entry.mp3URL),
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ];
  //   }, onSelected: (String value) {
  //     print('You Click on po up menu item');
  //   });
  // }

  Widget epicsList(state) {
    return Expanded(
      child: ListView.separated(
        // scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: records.length,
        itemBuilder: (BuildContext context, int index) {
          var entry = records[index];
          final GlobalKey<ScaffoldState> scaffoldKey =
              new GlobalKey<ScaffoldState>();
          return Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            // padding: const EdgeInsets.all(10.0),
            decoration: _displayPlayer == true &&
                    state != null &&
                    index == state.currentIndex
                ? selectedListTileDec()
                : BoxDecoration(), //       <--- BoxDecoration here
            child: ListTile(
                title: Text(entry.name.toString(),
                    style: arabicTxtStyle(paramSize: 18.0)),
                leading: entry.type == "RECORD"
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Container(
                            width: 40,
                            height: 40,
                            decoration: linearGradientBackground(),
                            child: Icon(
                              index == state.currentIndex
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            )),
                      )
                    : Icon(Icons.menu, color: UtilColours.APP_BAR),
                trailing: entry.type == "RECORD"
                    // ? listMenuItems(entry) : SizedBox.shrink(),
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // FileDownloader(fileURL: entry.mp3URL, openBook: () => {}, doneTitle: '', maxWidth: 80.0,),
                          FlatFileDownloader(
                              fileURL: entry.mp3URL)
                          // IconButton(
                          //     onPressed: () => {
                          //       Share.share(shareTextFormatter(
                          //           entry.name + "\n\n\n" + entry.mp3URL))
                          //     },
                          //     icon: Icon(Icons.share, color: UtilColours.APP_BAR),
                          //     ),
                        ],
                      )
                    : SizedBox.shrink(),
                // FileDownloader(fileURL: entry.mp3URL, openBook: ()=>{}, maxWidth: 90.0,) : SizedBox.shrink(),
                onTap: () {
                  if (entry.type == "RECORD") {
                    // if (_player.playing) {
                    //   _player.pause();
                    // }else{
                    //
                    // }
                    _player.seek(Duration.zero, index: index);
                    _player.play();
                  } else {
                    innerNavigate(entry.name, entry.firebaseId);
                  }
                }),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }
}
