import 'package:bestnation/Helper/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../../Helper/util.dart';
import '../../models/epic_model.dart';

class PdfScreenController extends GetxController {
  var args = Get.arguments;
  var db = new DatabaseHelper();
  RxBool loading = true.obs;
  RxBool isThereNetwork = false.obs;
  late Epic epic;

  @override
  void onReady() {
  }


  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      // pullDataFromNetwork();
    }
  }

  pullDataFromNetwork() async {
    await Firebase.initializeApp();
    isThereNetwork.value = await hasNetwork();
    await pullSingleBook('test');
  }



  pullSingleBook(id) async{
    loading.value = true;
    await Firebase.initializeApp();
    final docRef = FirebaseFirestore.instance.collection("texts").doc(id);
    await docRef.get().then((DocumentSnapshot doc) {
      db.formatEpicForSave(doc, args['classType']);
    },
      onError: (e) => print("Error getting document: $e"),
    );
    loading.value = false;
  }

  formatFirebaseDocuments(document) async {
    await doFormat(document);
    loading.value = false;
  }

  doFormat(document) async {
    await document.docs.forEach((document) async {
      epic = db.formatEpicForSave(document,
          args['classType']); // eg, classType = DatabaseHelper.TEXT
    });
  }
}


