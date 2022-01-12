import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/models/chat_room_model.dart';
import 'package:gupshup/models/firebase_helper.dart';
import 'package:gupshup/models/ui_helper.dart';
import 'package:gupshup/models/user_model.dart';
import 'package:gupshup/pages/chatroom.dart';
import 'package:gupshup/pages/login_page.dart';
import 'package:gupshup/pages/search_page.dart';

class HomePage extends StatefulWidget {
  final UserModels userModel;
  final User firebasrUser;
  const HomePage(
      {Key? key, required this.userModel, required this.firebasrUser})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat"),
        actions: [
          IconButton (
            onPressed: () {
              UIHelper.showAlertDialogLogout(context, "Log Out");
            },
            
            // onPressed: () async {
            //   await FirebaseAuth.instance.signOut();
            //   Navigator.popUntil(context, (route) => route.isFirst);
            //   Navigator.pushReplacement(
            //     context, 
            //     MaterialPageRoute(
            //       builder:  (context) {
            //         return LoginPage();
            //       }
            //     )
            //   );
            // }, 
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .where("participants.${widget.userModel.uid}",
                      isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot chatRoomSnapshoot =
                        snapshot.data as QuerySnapshot;
                    // return Text("data hai");
                    return ListView.builder(
                        itemCount: chatRoomSnapshoot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshoot.docs[index].data()
                                  as Map<String, dynamic>);
                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;

                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(widget.userModel.uid);

                          return FutureBuilder(
                              future: FirebaseHelper.getUserMoleBuId(
                                  participantKeys[0]),
                              builder: (context, userData) {
                                if (userData.connectionState ==
                                    ConnectionState.done) {
                                  if (userData.data != null) {
                                    UserModels targetUser =
                                        userData.data as UserModels;
                                    return ListTile(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ChatRoom(
                                                chatroom: chatRoomModel,
                                                firebaseUser: widget.firebasrUser,
                                                userModel: widget.userModel,
                                                targetUser: targetUser,

                                              );
                                            }
                                          )
                                        );
                                      },
                                      leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              targetUser.profilepic.toString()),
                                      ),
                                      title: Text(targetUser.fullname.toString()),
                                      subtitle: (chatRoomModel.lastMessage.toString()  != "" ) ? 
                                        Text(chatRoomModel.lastMessage
                                            .toString())
                                            : Text("Start your conversation",
                                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                            )
                                    );        
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Container();
                                }
                              });
                        });


                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return Center(child: Text("No Chats"));
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebasrUser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
