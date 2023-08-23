import 'package:bestnation/controller/flat_download_controller.dart';
import 'package:bestnation/view/components/flat_downlod.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FlatDownloadController(FlatDownload(tag: "https://files.zadapps.info/binbaz.org.sa/sawtyaat/shroh_alkotob/fat7_majed/fat7_majed 01.mp3") as String), fenix: true);
  }
}