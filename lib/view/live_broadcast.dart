import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/utilities/layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:easy_localization/easy_localization.dart';

class LiveBroadcast extends StatefulWidget {
  @override
  _LiveBroadcastState createState() => _LiveBroadcastState();
}

class _LiveBroadcastState extends State<LiveBroadcast> {

  InAppWebViewController webView;
  String url = "";
  double progress = 0;

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
        backgroundColor: Colors.transparent,
          appBar: app_bar(context, 'broadcast'.tr()),
          body: SafeArea(
            child: Container(
                child: Column(children: <Widget>[
                  progress < 1.0
                      ? Container(
                        padding: EdgeInsets.all(10.0),
                        child: LinearProgressIndicator(
                            value: progress,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),),
                      )
                      : Container(),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration:
                      BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                      child: InAppWebView(
                        initialUrl: "http://node-16.zeno.fm/2mu5gr0gtv8uv?rj-ttl=5&rj-tok=AAABesEMYl0AY-_dZqS356torA",
                        initialHeaders: {},
                        initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                              debuggingEnabled: true,
                            )
                        ),
                        onWebViewCreated: (InAppWebViewController controller) {
                          webView = controller;
                        },
                        onLoadStart: (InAppWebViewController controller, String url) {
                          setState(() {
                            this.url = url;
                          });
                        },
                        onLoadStop: (InAppWebViewController controller, String url) async {
                          setState(() {
                            this.url = url;
                          });
                        },
                        onProgressChanged: (InAppWebViewController controller, int progress) {
                          setState(() {
                            this.progress = progress / 100;
                          });
                        },
                      ),
                    ),
                  ),
                ])),
          )
      ),
    );
  }
}
