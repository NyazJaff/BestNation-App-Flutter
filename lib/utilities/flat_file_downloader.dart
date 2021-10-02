
import 'dart:io';
import 'package:bestnation/Helper/util.dart';
import 'package:bestnation/utilities/progress_button/iconed_button.dart';
import 'package:bestnation/utilities/progress_button/progress_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlatFileDownloader extends StatefulWidget {
  final String fileURL;
  final maxWidth;
  final height;
  final Function callBackFunc;

  FlatFileDownloader({Key key, this.fileURL, this.maxWidth = 40.0, this.height = 40.0, this.callBackFunc}) : super(key: key);

  @override
  _FlatFileDownloaderState createState() => _FlatFileDownloaderState();
}

class _FlatFileDownloaderState extends State<FlatFileDownloader> {

  ButtonState downloadState = ButtonState.idle;
  double percent = 0.0;
  bool hideDownload = false;
  bool loading = true;
  String savedPath = '';
  var dio = Dio();

  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    checkIfFileCreated();
  }

  checkIfFileCreated() async{
    await doesUrlFileExits(widget.fileURL).then((file) => {
      if(file != null && file.path != null && downloadState != ButtonState.delete){
        downloadState = ButtonState.delete
      }
    });
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return hideDownload ? Container() :
    ProgressButton.icon(iconedButtons: {
      ButtonState.idle: IconedButton(
          icon: Icon(Icons.download_rounded ,color: Colors.white),
          color: UtilColours.APP_BAR),
      ButtonState.loading: IconedButton(
          color: UtilColours.APP_BAR),
      ButtonState.fail: IconedButton(
          icon: Icon(Icons.cancel,color: Colors.white),
          color: Colors.red.shade300),
      ButtonState.success: IconedButton(
          icon: Icon(Icons.check_circle,color: Colors.white,),
          color: Colors.green.shade400),
      ButtonState.delete: IconedButton(
          icon: Icon(Icons.delete,color: Colors.white,),
          color: Colors.red.shade300)
    },
        maxWidth: widget.maxWidth,
        minWidth: 60.0,
        height: widget.height,
        progressIndicatorSize: 60.0,
        percent: percent,
        onPressed: () => processDownload(),
        state: downloadState,
        loading: loading);
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
        // hideDownload = true;
        downloadState = ButtonState.delete;
        break;
      case ButtonState.delete:
        print('deleteFile');
        deleteUrlFileIfExits(widget.fileURL);
        downloadState = ButtonState.idle;
        break;
      default:
        break;
    }
    setState(() {});
  }

  Future download2() async {
    // var url = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    savedPath = await localUrlPath(widget.fileURL);
    cancelToken = new CancelToken();

    // dio.options.headers['Host'] = 'abdullah-asad.com';
    dio.options.headers['Accept-Encoding'] = 'identity;q=1, *;q=0';

    try {
      Response response = await dio.get(
        widget.fileURL,
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