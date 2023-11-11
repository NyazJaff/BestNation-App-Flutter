import 'package:audio_service/audio_service.dart';
import 'package:bestnation/controller/lecture_controller.dart';
import 'package:bestnation/utilities/app_translation.dart';
import 'package:bestnation/utilities/audio_player_handler.dart';
import 'package:bestnation/view/book/books.dart';
import 'package:bestnation/view/live_broadcast.dart';
import 'package:bestnation/view/texts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

// Pages
import 'controller/audio_player_controller.dart';
import 'controller/books/books_controller.dart';
import 'controller/text_controller.dart';
import 'home.dart';
import 'view/lectures.dart';

late AudioHandler _audioHandler;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.create(() => LectureController()); // This so Lectures can call itself
    Get.create(() => TextController()); // This so Text can call itself
    Get.create(() => BooksController()); // This so Text can call itself
    final AudioPlayerController player = Get.put(AudioPlayerController());

    player.setAudioHandler(_audioHandler);

    return GetMaterialApp(
      translations: AppTranslation(),
      locale: Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyHomePage()),
        GetPage(name: "/lectures", page: () => Lectures()),
        GetPage(name: "/texts", page: () => Texts()),
        GetPage(name: "/books", page: () => Books()),
        GetPage(name: "/live_broadcast", page: () => LiveBroadcast()),
      ],

      theme: ThemeData(
        appBarTheme: Theme.of(context)
        .appBarTheme
        .copyWith(systemOverlayStyle: SystemUiOverlayStyle.dark), // set clocks and battery icons to dark
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
