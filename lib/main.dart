// import 'package:bestnation/view/lectures.dart';
// import 'package:bestnation/view/live_broadcast.dart';
// import 'package:bestnation/view/texts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';

// import 'Helper/db_helper.dart';
// import 'books/list_books.dart';
import 'home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization (
    child: new MyApp(),
    supportedLocales: [
      Locale('en', 'UK'),
      Locale('ar', 'SA'),
      Locale('ar', 'KU')
    ],
    path: 'assets/langs',
    fallbackLocale: Locale('ar', 'SA'),
    startLocale: Locale('ar', 'SA'),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        // '/books': (context) => ListBooks(title:'books'.tr(), parentId: '0',),
        // '/texts': (context) => Texts(title:'texts'.tr(), parentId: '0', classType: DatabaseHelper.TEXTS),
        // '/live_broadcast': (context) => LiveBroadcast(),
        // '/lectures': (context) => Lectures(title:'lectures'.tr(), parentId: '0', classType: DatabaseHelper.LECTURES),
        // '/speeches': (context) => Lectures(title:'speech'.tr(), parentId: '0', classType: DatabaseHelper.SPEECH),
      },

      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily:
          locale.toString() == 'ar_SA' ? 'Tajawal' :
          locale.toString() == 'ar_KU' ? 'Kurdi' :
          'Tajawal',
        ),
      ),
    );
  }


}
