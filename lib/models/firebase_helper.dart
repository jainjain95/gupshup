import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gupshup/models/user_model.dart';

class FirebaseHelper {

  static Future<UserModels?> getUserMoleBuId(String uid) async{

    UserModels? userModel;
    DocumentSnapshot docsnap = await FirebaseFirestore.instance.collection("user").doc(uid).get();
    if( docsnap != null){
      userModel = UserModels.fromMap(docsnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}