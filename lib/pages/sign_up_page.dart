import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/models/ui_helper.dart';
import 'package:gupshup/models/user_model.dart';
import 'package:gupshup/pages/complete_profile.dart';


class SignUp extends StatefulWidget {
  const SignUp({ Key? key }) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passowordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();

  void check(){
    String email = emailcontroller.text.trim();
    String password = passowordcontroller.text.trim();
    String cpassword = cpasswordcontroller.text.trim();
    if(email == "" || password == "" || cpassword == ""){
      
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the feild");
    }else if(password != cpassword){
       UIHelper.showAlertDialog(context, "Password Mismatch", "The passwords you entered do nat match!");
    }else {
      signUp(email,password);
    }
  }

  void signUp(String email, String password) async{
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Creating new account");
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      //dialog pop loading
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "An error occured", ex.code.toString());
    }

    if( credential != null ){ 
      String uid = credential.user!.uid;
      UserModels newuser = UserModels(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance.collection("user").doc(uid).set(newuser.toMap())
      .then((value) {
        print("new user created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CompleteProfile(userModel: newuser, firebasrUser: credential!.user!);
            }
          )
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
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
                  SizedBox(height:5),
                  TextField(
                    controller: cpasswordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      
                      labelText: "Password",
                    ),
                  ),
                  SizedBox(height: 40),
                  CupertinoButton(
                    onPressed: (){
                      check();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Sign Up"),
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
            
            Text("Already have an account?",),
            CupertinoButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("Log In"),
            ),
          ],
        ),
      ),
    );
  }
}