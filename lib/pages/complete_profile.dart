import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/models/ui_helper.dart';
import 'package:gupshup/models/user_model.dart';
import 'package:gupshup/pages/homapage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModels userModel;
  final User firebasrUser;
  const CompleteProfile({Key? key, required this.userModel, required this.firebasrUser}) : super(key: key);

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile =await ImagePicker().pickImage(source: source);
    if (pickedFile != null){
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async{
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if(croppedFile != null){
      setState(() {
        imageFile = croppedFile;
      });
    }
  }


  void  showPhotoOption(){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Upload ProfilePicture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"),
            ),
            ListTile(
               onTap: (){
                 Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a photo"),
            ),
          ]
        ),
      );
    });
  }

  void checkval(){
    String fullname = fullNameController.text.trim();

    if(fullname == ""){
      UIHelper.showAlertDialog(context, "An error occured", "Please fill the name or upload image");
    }else {
      upLoadData();
    }
  }

  void upLoadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image..");

    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepictures").
    child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance.collection("user").doc(widget.userModel.uid).set(widget.userModel.toMap())
    .then((value) {
      print("Data uploaded");
      Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return HomePage(userModel: widget.userModel, firebasrUser: widget.firebasrUser);
              }
            )
          );
    });
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: ListView(
            children: [
              SizedBox(height: 40),
              CupertinoButton(
                onPressed: () {
                  showPhotoOption();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: (imageFile != null) ? FileImage(imageFile!)
                  : null,
                  child: (imageFile == null) ? Icon(Icons.person, size: 60) : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              SizedBox(height: 40),
              CupertinoButton(
                onPressed: () {
                  checkval();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
