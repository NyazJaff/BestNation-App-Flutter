
import 'dart:io';
import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/utilities/progress_button/iconed_button.dart';
import 'package:bestnation/utilities/progress_button/progress_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FileDownloader extends StatefulWidget {
  final String fileURL;
  final String doneTitle;
  Function openBook;
  final maxWidth;
  final height;

  FileDownloader({Key key, this.fileURL, this.openBook, this.maxWidth = 180.0, this.height = 50.0, this.doneTitle = 'open' }) : super(key: key);

  @override
  _FileDownloaderState createState() => _FileDownloaderState();
}



class _FileDownloaderState extends State<FileDownloader> {

  ButtonState downloadState = ButtonState.idle;
  double percent = 0.0;
  bool hideDownload = false;
  String savedPath = '';
  var dio = Dio();
  CancelToken cancelToken = CancelToken();

  @override
  Widget build(BuildContext context) {
    return hideDownload ? Container() :
    ProgressButton.icon(iconedButtons: {
      ButtonState.idle: IconedButton(
          text: "download".tr(),
          icon: Icon(Icons.download_rounded ,color: Colors.white),
          color: UtilColours.APP_BAR),
      ButtonState.loading: IconedButton(
          text: "loading".tr(),
          color: UtilColours.APP_BAR),
      ButtonState.fail: IconedButton(
          text: "failed".tr(),
          icon: Icon(Icons.cancel,color: Colors.white),
          color: Colors.red.shade300),
      ButtonState.success: IconedButton(
          text: widget.doneTitle.tr(),
          icon: Icon(Icons.check_circle,color: Colors.white,),
          color: Colors.green.shade400)
    },
        maxWidth: widget.maxWidth,
        minWidth: 60.0,
        height: widget.height,
        progressIndicatorSize: 60.0,
        percent: percent,
        onPressed: () => processDownload(),
        state: downloadState);
  }

  processDownload(){
    switch (downloadState) {
      case ButtonState.idle:
        print('startDownload');
        download2();
        percent = 0.0;
        downloadState = ButtonState.loading;
        break;
      case ButtonState.loading:
        if(!cancelToken.isCancelled){
          cancelToken.cancel();
          print('cancel');
        }
        downloadState = ButtonState.idle;
        percent = 0.0;
        break;
      case ButtonState.success:
        widget.openBook(savedPath);
        hideDownload = true;
        break;
      default:
        break;
    }
    setState(() {});
  }


  Future download2() async {
    // var url = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    var url = widget.fileURL;
    print(url);
    String dir = await getSystemPath();
    savedPath = "$dir/" + widget.fileURL.substring(widget.fileURL.lastIndexOf("/") + 1);
    cancelToken = new CancelToken();

    // dio.options.headers['Host'] = 'abdullah-asad.com';
    dio.options.headers['Accept-Encoding'] = 'identity;q=1, *;q=0';

    try {
      Response response = await dio.get(
        url,
        cancelToken: cancelToken,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      print(response.headers);
      File file = File(savedPath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
      setState(() {
        downloadState = ButtonState.success;
      });
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      setState(() {
        percent = received / total;
      });
    }
  }

}