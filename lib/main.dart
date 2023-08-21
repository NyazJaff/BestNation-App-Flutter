import 'package:bestnation/controller/lecture_controller.dart';
import 'package:bestnation/utilities/app_translation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

// Pages
import 'Helper/db_helper.dart';
import 'controller/audio_player_controller.dart';
import 'home.dart';
import 'view/lectures.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.create(() => LectureController()); // This so Lectures can call itself
    final AudioPlayerController player = Get.put(AudioPlayerController());

    return GetMaterialApp(
      translations: AppTranslation(),
      locale: Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyHomePage()),
        GetPage(name: "/lectures", page: () => Lectures()),
      ],
      // routes: {
      //   '/': (context) => MyHomePage(),
      //   // '/books': (context) => ListBooks(title:'books'.tr(), parentId: '0',),
      //   // '/texts': (context) => Texts(title:'texts'.tr(), parentId: '0', classType: DatabaseHelper.TEXTS),
      //   // '/live_broadcast': (context) => LiveBroadcast(),
      //   '/lectures': (context) => Lectures(title:'lectures'.tr, parentId: '0', classType: DatabaseHelper.LECTURES),
      //   // '/speeches': (context) => Lectures(title:'speech'.tr(), parentId: '0', classType: DatabaseHelper.SPEECH),
      // },

      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   EasyLocalization.of(context)!.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      //   DefaultCupertinoLocalizations.delegate
      // ],
      // supportedLocales: context.supportedLocales,

      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily:
          Get.locale.toString() == 'ar_SA' ? 'Tajawal' :
          Get.locale.toString()  == 'ar_KU' ? 'Kurdi' :
          'Tajawal',
        ),
      ),
    );
  }


}
