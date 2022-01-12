import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/models/user_model.dart';
import 'package:gupshup/pages/homapage.dart';
import 'package:gupshup/pages/login_page.dart';
import 'package:uuid/uuid.dart';
import 'models/firebase_helper.dart';

var uuid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null){
    UserModels? thisModel = await FirebaseHelper.getUserMoleBuId(currentUser.uid);
    if(thisModel != null){
      runApp(MyAppLoggedIn(userModel: thisModel, firebaseUser: currentUser,));
      // runApp (MyApp());
    }
    else{
      runApp( MyApp());
    }
  }else {
    runApp( MyApp());
  }
}


//// not logged in
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gupshup',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

///  already logged in
class MyAppLoggedIn extends StatelessWidget {
  final UserModels userModel;
  final User firebaseUser;
  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "gupshup",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(userModel: userModel,  firebasrUser: firebaseUser,),
    );
  }
}
