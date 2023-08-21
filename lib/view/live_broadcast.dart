import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:get/get.dart';

class LiveBroadcast extends StatefulWidget {
  @override
  _LiveBroadcastState createState() => _LiveBroadcastState();
}

class _LiveBroadcastState extends State<LiveBroadcast> {
  String url = "";
  String title = "";
  bool isThereNetwork = false;

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
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                        createLogoDisplay('logo.png'),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                        isThereNetwork
                            ? Icon(Icons.wifi_off, color: Colors.grey, size: 40,) // TODO
                            :  Icon(Icons.wifi_off, color: Colors.grey, size: 40,),
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
                        ) : SizedBox.shrink(),
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.only(bottom: 20),
                              child: jaffLogo()),
                        ),
                      ],
                    ))),
          ]),
        ));
  }
}
