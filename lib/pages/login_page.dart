import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/models/ui_helper.dart';
import 'package:gupshup/models/user_model.dart';
import 'package:gupshup/pages/homapage.dart';
import 'package:gupshup/pages/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passowordcontroller = TextEditingController();

  void check(){
    String email = emailcontroller.text.trim();
    String password = passowordcontroller.text.trim();
    if(email == "" || password == ""){
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the feild");
    }
    else {
      logIn(email,password);
    }
  }

  void logIn (String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      // Close thne Loading dialog
      Navigator.pop(context);
      
      UIHelper.showAlertDialog(context, "An Error Occored", ex.code.toString());
    }

    if(credential != null){
      String uid = credential.user!.uid;
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("user").doc(uid).get();
      UserModels userModel = UserModels.fromMap(userData.data() as Map<String, dynamic>);
      log("Log in successful");
      //
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return HomePage(userModel: userModel, firebasrUser: credential!.user!);
              }
            )
          );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("GuPshuP", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.secondary),),
                  SizedBox(height: 20,),
                  TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                    ),
                  ),
                  SizedBox(height:5),
                  TextField(
                    controller: passowordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      
                      labelText: "Password",
                    ),
                  ),
                  SizedBox(height: 40,),

                  CupertinoButton(
                    onPressed: (){
                      check();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Log In"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Dont't have an account?", style: TextStyle(),),
            CupertinoButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) {
                    return SignUp();
                  })
                );
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}