import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/pages/login_page.dart';

class UIHelper {

  static void showLoadingDialog(BuildContext context, String title) {
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) {
      return loadingDialog;
    }
    
    );
  }

  static void showAlertDialog(BuildContext context, String title, String content) {

    AlertDialog alertDialog =AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"),
        ),
      ],
    );

    showDialog(context: context, builder: (context){
      return alertDialog;
    });
  }

  static void showAlertDialogLogout(BuildContext context, String title,) {

    AlertDialog alertDialog =AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
           onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder:  (context) {
                    return LoginPage();
                  }
                )
              );
            }, 
          // onPressed: () {
          //   Navigator.pop(context);
          // },
          child: Text("Ok"),
        ),
      ],
    );

    showDialog(context: context, builder: (context){
      return alertDialog;
    });
  }


}