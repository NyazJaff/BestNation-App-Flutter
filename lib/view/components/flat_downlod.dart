import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../Helper/util.dart';
import '../../controller/flat_download_controller.dart';
import '../../utilities/progress-state-button/iconed_button.dart';
import '../../utilities/progress-state-button/progress_button.dart';

class FlatDownload extends StatelessWidget {
  final String tag;

  FlatDownload({super.key, required this.tag}) : super(){
    Get.put(FlatDownloadController(tag), tag: tag, permanent: true);
  }

  get flatDownloadController => Get.find<FlatDownloadController>(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ProgressButton.icon(
      iconedButtons: {
        ButtonState.idle: IconedButton(
            icon: Icon(Icons.download, color: Colors.white),
            color: UtilColours.APP_BAR),
        ButtonState.loading: IconedButton(color: UtilColours.APP_BAR),
        ButtonState.fail: IconedButton(
            icon: Icon(Icons.cancel, color: Colors.white),
            color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400),
        ButtonState.delete: IconedButton(
            icon: Icon(
              FontAwesomeIcons.trash,
              color: Colors.white,
              size: 15,
            ),
            color: Colors.red.shade300)
      },
      tag: tag,
      maxWidth: 45.0,
      height: 45.0,
      onPressed: flatDownloadController.onPressedIconWithMinWidthStateText, // TODO what should happen on click
      state: flatDownloadController.downloadState.value,
      minWidthStates: [],
    ));
  }
}

