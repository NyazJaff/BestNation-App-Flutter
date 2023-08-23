
import 'package:get/get.dart';
import 'package:dio/dio.dart' as Dio;
import 'dart:io';


import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../utilities/progress-state-button/progress_button.dart';
import '../Helper/util.dart';


class FlatDownloadController extends GetxController {
  final String tag;
  FlatDownloadController (this.tag);

  Rx<ButtonState> downloadState = ButtonState.idle.obs;
  var dio = Dio.Dio();
  Dio.CancelToken cancelToken = Dio.CancelToken();
  String savedPath = '';
  RxDouble percent = 0.0.obs;
  bool hideDownload = false;

  @override
  void onInit() {
    super.onInit();
    checkIfFileCreated();
  }

  @override
  void onClose() {
    super.onClose();

  }

  void onPressedIconWithMinWidthStateText() {
    switch (downloadState.value) {
      case ButtonState.idle:
        start();
        break;
      case ButtonState.loading:
        cancel();
        break;
      case ButtonState.success:
        downloadState.value = ButtonState.delete;
        break;
      case ButtonState.fail:
        downloadState.value = ButtonState.idle;
        break;
      case ButtonState.delete:
        delete();
        break;
    }
  }

  start() async{
    var url = tag;
    String dir = await getSystemPath();
    savedPath = "$dir/" + url.substring(url.lastIndexOf("/") + 1);
    // dio.options.headers['Host'] = 'abdullah-asad.com';
    // dio.options.headers['Accept-Encoding'] = 'identity;q=1, *;q=0';
    downloadState.value = ButtonState.loading;
    try {
      await dio.download(url, savedPath,
          cancelToken: cancelToken,
          onReceiveProgress: (received,total) {
          print((received / total).toDouble().toString());
          percent.value = (received / total).toDouble();
      });
      downloadState.value = ButtonState.success;
    } catch (e) {
      print(e);
    }
  }

  cancel(){
    if(!cancelToken.isCancelled){
      cancelToken.cancel();
      cancelToken = new Dio.CancelToken();
    }
    downloadState.value = ButtonState.idle;
  }

  delete(){
    deleteUrlFileIfExits(tag);
    downloadState.value = ButtonState.idle;
  }

  checkIfFileCreated() async{
    await doesUrlFileExits(tag).then((file) => {
      if(file != null && downloadState.value != ButtonState.delete){
        downloadState.value = ButtonState.delete
      }
    });
  }
}