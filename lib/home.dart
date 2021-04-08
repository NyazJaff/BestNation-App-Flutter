import 'package:bestnation/utilities/layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'Helper/util.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Widget createLogoDisplay(){
    return Container(
      width: 130,
      height: 130,
      padding: EdgeInsets.all(10),
      decoration: linearGradientBackground(),
      child: Container(
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/brand/logo.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }
  Widget createTitle(text){
    return Container(
        child:Text(
          text,
          style:arabicTxtStyle(paramSize: 16),
          textAlign: TextAlign.center,
        )
    );

  }
  Widget createMainButton(text, icon, navigate){
    return Container(
      width: 280,
      height:70,
      child: GestureDetector(
        onTap: () => {
          Navigator.pushNamed(context, navigate)
        },
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 0,
              child: Container(
                width: 250,
                height: 50,
                child: CustomPaint(
                  painter: CurvePainter(),
                ),
              ),
            ),
            Positioned(
                left: 220,
                top: 8,
                child: Container(
                  width: 55,
                  height: 55,
                  padding: EdgeInsets.all(10),
                  decoration: linearGradientBackground(),
                  child: Container(
                    decoration:  BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/brand/$icon.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                )
            ),
            Positioned(
              top: 25,
              left: -5,
              child: Container(
                  width: 220,
                  height: 50,
                  child:Text(
                    text,
                    style:arabicTxtStyle(paramBold: true),
                    textAlign: TextAlign.right,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget addPadding(context){
    return Padding(padding: EdgeInsets.only(top: util_winHeightSize(context) > 700 ? util_winHeightSize(context)  * 0.2 : util_winHeightSize(context) *  0.04));
  }
  Widget devNJaff(){
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
                  url: "http://nyazjaff.co.uk");
            },
            child: null,
          ),
        ),
      ),
    );
  }

  Widget socialMediaLinks(which, url){
    return  Padding(
      padding: EdgeInsets.all(6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/brand/$which.png'),
            ),
          ),
          child: FlatButton(
            padding: EdgeInsets.all(0.0),
            onPressed: () async {
              await InAppBrowser.openWithSystemBrowser(
                  url: url);
            },
            child: null,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
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
                ])),
        child: Stack(
          children: [
            SingleChildScrollView(
                child: AnimationLimiter(
                  child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 800),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                          children: <Widget>[
                            SizedBox(height: 50),
                            createLogoDisplay(),
                            SizedBox(height: 20),
                            createTitle('{خير أمة}'),
                            createTitle('{شبكة علمية دعوية على منهج أهل السنة والجماعة}'),
                            SizedBox(height: 20),
                            addImage("assets/brand/arrow.png"),
                            Container (
                              child: Align (
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        createMainButton('العلماء وطلاب العلم', 'person_icon', '/lectures'),
                                        createMainButton('الفوائد المنتقاة', 'text_icon', '/texts'),
                                        createMainButton('الإذاعة', 'book_with_pen_icon', '/live_broadcast'),
                                        createMainButton('الكتب', 'book_icon', '/books')
                                      ],
                                    ),
                                  )
                              ),
                            ),
                            addImage("assets/brand/arrow.png"),
                            SizedBox(height: 20),
                            createTitle('• تابعنا على مواقع التواصل وفقك الله لطاعته:'),
                            Container(
                              child: Align(
                                alignment: FractionalOffset(0, 0.8),
                                child: Container(
                                  child: Row (
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      socialMediaLinks("youtube",   'https://www.youtube.com/channel/UCm2EffIVtfZp1QdoTf0RjXA'),
                                      socialMediaLinks("tiktok",  'https://vm.tiktok.com/ZSJMF3g2Y/'),
                                      socialMediaLinks("twitter",   'https://twitter.com/bestnationnw'),
                                      socialMediaLinks("instagram", 'https://www.instagram.com/bestnationnw/'),
                                      socialMediaLinks("facebook",  'https://www.facebook.com/bestnationnw/'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            addImage("assets/brand/home_verses.png", size: 320.0),
                            SizedBox(height: 20),
                            SizedBox(height:30),
                            devNJaff(),
                            SizedBox(height:15),
                          ]
                      )
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    var rect = Offset.zero & size;
    var gradient = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        stops: [
          0.1,
          0.9,
          0.9,
        ],
        colors: [
          Color(0xfff0f0ff),
          Color(0xffe0e0fd),
          Color(0xffe0e0fd),
        ]);
    // paint.color = Color(0xffd4d3fd);
    var paint = Paint()..shader = gradient.createShader(rect);
    // paint.style = PaintingStyle.stroke;

    var path = Path();
    path.moveTo(size.width * 0.30, 0);
    path.quadraticBezierTo(0, 0, 0, size.height);
    path.quadraticBezierTo(0, size.height  , size.width , size.height);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.17, size.width, 0);
    path.lineTo(size.width * 0.30, 0);
    canvas.drawShadow(path, Colors.black, 04, false);


    canvas.drawPath(path, paint);
    // canvas.drawShadow(path, Colors.black, 11.0, true);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}