import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

double util_winHeightSize(BuildContext context){
  return MediaQuery.of(context).size.height;
}

app_bar(BuildContext context, title){
  return  AppBar(
    leading: new IconButton(
      icon: new Icon(Icons.arrow_back, color: UtilColours.APP_BAR),
      onPressed: () => Navigator.of(context).pop(),
    ),
    backgroundColor: Colors.transparent,
//          backgroundColor: Color(0x44000000),
    elevation: 0,
    title: Text(title,  style: TextStyle(
        color: UtilColours.APP_BAR,
        fontFamily: "Tajawal"
    )),
  );
}

class UtilColours {
  static const Color PRIMARY_BROWN = Color(0xffc6ac6e);
  static const Color SAVE_BUTTON = Color(0xff00bfa5);

  static const Color PROGRESS = Color(0xff00bfa5);
  static const Color APP_BAR = Color(0xff38606A);
  static const Color APP_BAR_NAV_BUTTON = Color(0xffE1D7D5);
}

bool utilIsAndroid(context){
  bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
  return isAndroid;
}

getCurrentOrientation(){
  final orientation = WidgetsBinding.instance.window.physicalSize
      .aspectRatio > 1 ? Orientation.landscape : Orientation.portrait;
  return orientation;
}

showToast(context, message){
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2),
  ));
}

String encodeArabicURL(url){
  String encodedURL = url;
  final allArabicChar = RegExp('[\u0621-\u064A]+');

  if(allArabicChar.hasMatch(url)){
    encodedURL = Uri.encodeFull(url);
  }
  return encodedURL;
}

getSystemPath() async {
  return (await getApplicationDocumentsDirectory()).path;
}

localUrlPath(url) async {
  String dir = await getSystemPath();
  return "$dir/" + url.substring(url.lastIndexOf("/") + 1);
}

Future<File> doesUrlFileExits(url) async{
  String path = await localUrlPath(url);
  if(File(await path).existsSync() == true){
    return File(path);
  }
  return null;
}

deleteUrlFileIfExits(url) async{
  String path = await localUrlPath(url);
  if(File(path).existsSync() == true){
    return File(path).delete();
  }
  return false;
}

hasNetwork() async {
  bool network = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      network = true;
    }
  } on SocketException catch (error) {
    print(error);
  }
  return network;
}

shareTextFormatter(text) {
  return text + "\n\n\n   (تطبيق خير أمة) \n • لتحميل التطبيق : https://www.bestnationapp.com/" ;
}