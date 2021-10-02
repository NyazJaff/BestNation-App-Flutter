import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/class/Input.dart';
import 'package:bestnation/models/epic_model.dart';
import 'package:bestnation/view/mp3_player.dart';
import 'package:bestnation/view/texts_body.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:bestnation/utilities/chasing_dots.dart';
import 'package:just_audio/just_audio.dart';
import '../Helper/db_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class Texts extends StatefulWidget {
  Texts({
    Key key,
    this.title,
    this.parentId,
    this.classType,
  }) : super(key: key);

  final String title;
  final String parentId;
  final String classType;

  @override
  _TextsState createState() => _TextsState();
}

class _TextsState extends State<Texts> {
  var db = new DatabaseHelper();
  List<Epic> records = [];
  bool loading = true;
  TextEditingController nameSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    pullDataFromNetwork();
  }

  @override
  void dispose() {
    super.dispose();
  }

  pullDataFromNetwork() async {
    await Firebase.initializeApp();
    switch (widget.classType) {
      case DatabaseHelper.TEXTS:
        await _pullTexts();
        break;
    }

    setState(() {});
  }

  _pullTexts() async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("texts")
        .where('parentId', isEqualTo: widget.parentId)
        .orderBy('order')
        .get();

    formatFirebaseDocuments(document);
    return records;
  }

  formatFirebaseDocuments(document) {
    records = [];
    document.docs.forEach((document) async {
      Epic epic = db.formatEpicForSave(document,
          widget.classType); // eg, classType = DatabaseHelper.LECTURES
      // await db.saveEpic(epic);
      records.add(epic);
    });
    // records.sort((a, b) => a.firebaseId.compareTo(b.firebaseId)); // Sort Records
    loading = false;
    return records;
  }

  innerNavigate(title, firebaseId) {
    var classToCall = Texts(
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
            Positioned.fill(
                child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                        createLogoDisplay('text-view-heading.png'),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                        loading == false
                            ? records.length > 0
                                ? Column(
                                    children: [
                                      // Container(
                                      //   width: 300,
                                      //   child: Input(
                                      //     onNameChangeCallback: onNameChangeCallback,
                                      //     controller:  nameSearch,
                                      //     hint:        '',
                                      //     leadingIcon: Icons.search,
                                      //   ),
                                      // ),
                                      // SizedBox(height: 20.0),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: SingleChildScrollView(
                                            child: textsList()),
                                      )
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
                              )))
                      ],
                    ))),
          ]),
        ));
  }

  Widget textsList() {
    return Container(
        // decoration: selectedListTileDec(colour: 0xffc8cae6),
        width: 300,
        child: Column(
          children: [
            for (final entry in records)
              Column(
                key: ValueKey(entry),
                //set mainAxisSize to min to avoid items disappearing on reorder
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: selectedListTileDec(colour: 0xffc8cae6),
                    child: ListTile(
                        // leading: Icon(Icons.menu),
                        title: Text(
                          entry.name,
                          style: arabicTxtStyle(
                              paramBold: true, paramColour: Color(0xff363f68)),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          if (entry.type == "RECORD") {
                            var classToCall = TextsBody(
                                title: entry.name,
                                body: entry.body,
                                key: UniqueKey());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => classToCall));
                          } else {
                            innerNavigate(entry.name, entry.firebaseId);
                          }
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              )
          ],
        )

        // ListView.separated(
        //   // scrollDirection: Axis.vertical,
        //   shrinkWrap: true,
        //   itemCount: records.length,
        //   itemBuilder: (BuildContext context, int index){
        //     var entry = records[index];
        //     return ListTile(
        //         title: Text(
        //           'فوائد من كتاب التوحيد',
        //           style:arabicTxtStyle(paramBold: true, paramColour: Color(0xff363f68) ),
        //           textAlign: TextAlign.center,
        //         ),
        //         // subtitle:  Container(
        //         //   child: Column(
        //         //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //         //     children: <Widget>[
        //         //       Container(child: Text("Page: ".toString(), style: arabicTxtStyle(paramSize: 18.0)),),
        //         //     ])),
        //         // trailing: new IconButton(icon: Icon(Icons.delete), onPressed: (){}),
        //         onTap: () {
        //           if(entry.type == "RECORD"){
        //
        //           }else{
        //             print(entry);
        //             innerNavigate(entry.name, entry.firebaseId);
        //           }
        //         }
        //     );
        //   }, separatorBuilder: (BuildContext context, int index) {
        //   return Divider();
        // },),
        );
  }
}
