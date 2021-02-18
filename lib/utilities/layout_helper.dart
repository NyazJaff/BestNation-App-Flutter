import 'package:bestnation/Helper/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chasing_dots.dart';
import 'dart:math' as math;

final textAndIconColour =     Color(0xFF545756);
final textAndIconHintColour = Color(0xFF969998);
final logoYellow =            Color(0xFFFFCA0A);

final appBackgroundFirst =    Color(0xFFf7f7f7);
final appBackgroundSecond =   Color(0xFFededed);


TextStyle arabicTxtStyle({paramColour: UtilColours.APP_BAR, double paramSize: 20.0, paramBold: false}){
  return TextStyle(
      fontSize: paramSize,
      color: paramColour,
      fontFamily: "Tajawal",
      fontWeight: paramBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: FontStyle.normal,
      letterSpacing: 2,
      height: 1.5
  );
}

Widget withRTL(widget){
  return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(math.pi),
      child: widget
  );
}

Widget displayLoading({size: 50.0}){
  return Center(
      child: SpinKitChasingDots(
        color: UtilColours.APP_BAR,
        size: size,
      ));
}

Widget appBgImage(){
  return Container(
    // decoration: BoxDecoration(
    //   image: DecorationImage(
    //     image: AssetImage("assets/brand/bg_tran.png"),
    //     fit: BoxFit.cover,
    //   ),
    // ),
  );
}

final simpleDecorationStyle = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

Widget emptyAppBar(){
  return PreferredSize(
      preferredSize: Size.fromHeight(0.0), // here the desired height
      child: AppBar(
        brightness: Brightness.light,
        backgroundColor: logoYellow,
      )
  );
}

BoxDecoration selectedListTileDec() {
  return BoxDecoration(
    border: Border.all(
      color: UtilColours.APP_BAR,
    ),
    borderRadius: BorderRadius.circular(20.0),
  );
}

Widget buildBackground(){
  return Container(
    height:  double.infinity,
    width: double.infinity,
    decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appBackgroundFirst,
              appBackgroundFirst,
              appBackgroundFirst,
              appBackgroundSecond
            ],
            stops: [0.1,0.4,0.7, 0.9]
        )
    ),
  );
}