import 'package:bestnation/Helper/util.dart';
import 'package:flutter/material.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import '../Helper/db_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';


class TextsBody extends StatefulWidget {
  TextsBody({
    Key key,
    this.title,
    this.body,
  }) : super(key: key);

  final String title;
  final String body;
  @override
  _TextsBodyState createState() => _TextsBodyState();
}

class _TextsBodyState extends State<TextsBody> {
  var db = new DatabaseHelper();

  bool loading = true;
  @override
  void initState() {
    super.initState();
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
          appBar: app_bar(context, widget.title),
          backgroundColor: Colors.transparent,
          body: Stack (
              children: <Widget>[
                Positioned.fill(
                  child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Container(
                                padding: EdgeInsets.all(20),
                                height: MediaQuery.of(context).size.height * 0.7,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                color: Color(0xffececfe),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                                
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [

                                      Row(
                                        children: [
                                          // Container(
                                          //   padding: EdgeInsets.only(bottom:30),
                                          //     child: Icon(Icons.remove)),
                                          SizedBox(width: 10,),
                                          Flexible(
                                            child: Text(
                                                widget.title,
                                                style: arabicTxtStyle(paramBold: true),
                                                textAlign: TextAlign.right,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5,),
                                      SelectableText(
                                        widget.body,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                            fontSize: 21 ,
                                            // fontWeight: FontWeight.bold,
                                            color: UtilColours.APP_BAR,
                                            fontFamily: "UthmanTahaNaskh",
                                            fontStyle: FontStyle.normal,
                                            // letterSpacing: 5,
                                            // height: 1.5
                                        ),

                                      ),
                                    ]
                                  ),
                                )),
                          ),
                          addImage("assets/brand/arrow.png"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                  onPressed: () => {Share.share(widget.body)},
                                  icon: Icon(Icons.share, color: UtilColours.APP_BAR,),
                                  label: Text('مشاركة',  style: arabicTxtStyle())),
                              TextButton.icon(
                                  onPressed: () => {Clipboard.setData(new ClipboardData(text: widget.body))},
                                  icon: Icon(Icons.copy, color: UtilColours.APP_BAR,),
                                  label: Text('نسخ', style: arabicTxtStyle(),)),
                            ],
                          )
                        ],
                      )
                  )
                ),

              ]
          ),
        )
    );
  }

}
