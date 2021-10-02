import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:just_audio/just_audio.dart';

import 'mp3_player.dart';

class LiveBroadcast extends StatefulWidget {
  @override
  _LiveBroadcastState createState() => _LiveBroadcastState();
}

class _LiveBroadcastState extends State<LiveBroadcast> {
  String url = "";
  String title = "";
  List<AudioSource> mp3List = [];
  bool isThereNetwork = false;
  AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pullConfig();
  }

  _pullConfig() async {
    isThereNetwork = await hasNetwork();
    await Firebase.initializeApp();
    Stream config = FirebaseFirestore.instance.collection('config').doc('LIVE_STREAM').snapshots();
    config.listen((value) {
      title = value.data()['title'];
      url = value.data()['url'];
      _init();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  _init() async {
      try {
        print(url);
        await _player.setUrl(url);
        _player.play();
      } catch (e) {
        // catch load errors: 404, invalid url ...
        print("An error occured when initialising mp3 player $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        decoration: appBackgroundGradient(),
        child: Scaffold(
          appBar: appBar(context, 'broadcast'.tr()),
          backgroundColor: Colors.transparent,
          body: Stack(children: <Widget>[
            Positioned.fill(
                child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                        createLogoDisplay('logo.png'),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                        ControlButtons(_player, false),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                        isThereNetwork && title != "" ? Container(
                            decoration: valueBoxDecorationStyle, 
                            padding: EdgeInsets.all(10),
                            width: 250,
                            child: Text(
                                title,
                                style: arabicTxtStyle(paramSize: 20.0),
                                textAlign: TextAlign.justify
                            )
                        ) : SizedBox.shrink()
                      ],
                    ))),
          ]),
        ));
  }
}
