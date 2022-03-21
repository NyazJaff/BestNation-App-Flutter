import 'package:bestnation/Helper/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'chasing_dots.dart';
import 'dart:math' as math;

final textAndIconColour =     Color(0xFF545756);
final textAndIconHintColour = Color(0xFF969998);
final logoYellow =            Color(0xFFFFCA0A);

final appBackgroundFirst =    Color(0xFFc4c4e6);
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

Widget addImage(path, {size: 200.0}){
  return  Container(
      width: size,
      child:
      Image(
          image:
          AssetImage(path)
      )
  );
}

BoxDecoration appBackgroundGradient(){
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [
            0.1,
            0.2,
            0.3,
            0.9
          ],
          colors: [
            Color(0xfffcfcff),
            Color(0xffececfe),
            Color(0xffebebfe),
            Color(0xffc9cafc)
          ]));
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

BoxDecoration linearGradientBackground({radius: 100.0}){
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius:  10,
        offset: Offset(0, 5), // changes position of shadow
      ),
    ],
    gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        stops: [
          0.2,
          0.3,
          0.4,
          0.9
        ],
        colors: [
          Color(0xff00d6c0),
          Color(0xff00c9c2),
          Color(0xff00bfc3),
          Color(0xff00a7c6)
        ]),
    borderRadius: BorderRadius.circular(radius),
    // border: Border.all(width: 0, color: Colors.white)
  );
}

BoxDecoration selectedListTileDec({colour: 0xffe0e0ef}) {
  return BoxDecoration(
    gradient: LinearGradient(
        colors: [Color(colour)],
        stops: [0.1]),
    border: Border.all(
      color: appBackgroundFirst,
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

Widget createLogoDisplay(image) {
  return Container(
    width: 200,
    height: 130,
    padding: EdgeInsets.all(10),
    decoration: linearGradientBackground(radius: 10.0),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/brand/' + image),
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

final kHintTextStyle = TextStyle(
  color: textAndIconHintColour,
  fontFamily: 'OpenSans',
);


TextStyle kLabelStyle({fontSize : 14.0}){
  return TextStyle(
    fontSize: fontSize,
    color: textAndIconColour,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );
}

final valueBoxDecorationStyle = BoxDecoration(
  color: Color(0xFFF6F6F6FF),
  borderRadius: BorderRadius.circular(15.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

final valueHintBoxDecorationStyle = TextStyle(
  color: textAndIconHintColour,
  fontSize: 33,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

Widget jaffLogo(){
  return Align(
    alignment: Alignment(0.0, 0.98),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: 75,
        height: 45,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/brand/dev N.Jaff.png'),
          ),
        ),
        child: FlatButton(
          padding: EdgeInsets.all(0.0),
          onPressed: () async {
            await InAppBrowser.openWithSystemBrowser(
                url: "https://nyazjaff.co.uk");
          },
          child: null,
        ),
      ),
    ),
  );
}