import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/view/texts_body.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:get/get.dart';

import '../controller/text_controller.dart';

class Texts extends StatefulWidget {
  Texts({super.key});

  @override
  _TextsState createState() => _TextsState();
}

class _TextsState extends State<Texts> {
  final TextController textController = Get.find();
  final _searchTextController = TextEditingController();

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
          appBar: appBar(context, textController.args['title']),
          backgroundColor: Colors.transparent,
          body: Obx(() => Stack(children: <Widget>[
                Positioned.fill(
                    child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            searchBox(),
                            SizedBox(height: 10),
                            createLogoDisplay('text-view-heading.png'),
                            SizedBox(height: 15),
                            textController.loading.value == false
                                ? textController.records.length > 0
                                    ? Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.6,
                                            child: SingleChildScrollView(
                                                child: textsList()),
                                          )
                                        ],
                                      ) // Display Record
                                    : displayNoRecordFound() // No Record Found
                                : displayLoading()
                          ],
                        ))),
              ])),
        ));
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
                  textController.algoliaTextSearch(value);
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

  Widget textsList() {
    return Container(
        width: 300,
        child: Column(
          children: [
            for (final entry in textController.records)
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
                        onTap: () async {
                          if (entry.type == "RECORD") {
                            var record = await textController.pullSingleText(entry.firebaseId);
                            var classToCall = TextsBody(
                                title: entry.name,
                                body: record.body,
                                key: UniqueKey());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => classToCall));
                          } else {
                            innerNavigate(entry);
                          }
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              )
          ],
        ));
  }

  innerNavigate(entry) {
    Get.to(
          () => Texts(),
      arguments: {
        'title': entry.name.toString(),
        'parentId': entry.firebaseId,
        'classType': textController.args['classType']
      },
      preventDuplicates: false,
    );
  }
}
