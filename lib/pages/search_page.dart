import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/models/chat_room_model.dart';
import 'package:gupshup/models/user_model.dart';
import 'package:gupshup/pages/chatroom.dart';
import 'package:uuid/uuid.dart';
var uuid = Uuid();
class SearchPage extends StatefulWidget {
  final UserModels userModel;
  final User firebaseUser;
  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchcontroller = TextEditingController();



  Future<ChatRoomModel?> getChatRommModel(UserModels  targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).
    where("participants.${targetUser.uid}", isEqualTo: true).get();

    if(snapshot.docs.length > 0){
      //chat room already created!!
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;

      
    }
    else {
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );
      await FirebaseFirestore.instance.collection("chatrooms").
        doc(newChatroom.chatroomid).set(newChatroom.toMap());
      chatRoom = newChatroom;
      print("chatroom created");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 30,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchcontroller,
              ),
              SizedBox(height: 40),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Search"),
              ),
              SizedBox(height: 20),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("user")
                      .where("email", isEqualTo: searchcontroller.text)
                      .where("email", isNotEqualTo: widget.userModel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;
                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;
                          UserModels searchedModel =
                              UserModels.fromMap(userMap);
                          return ListTile(
                            onTap: () async {
                              ChatRoomModel? chatRoomModel= await getChatRommModel(searchedModel);

                              if( chatRoomModel != null){
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatRoom(
                                  targetUser: searchedModel,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser,
                                  chatroom: chatRoomModel,
                                );
                              }));
                              }
                            
                              
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                searchedModel.profilepic!,
                              ),
                              backgroundColor: Colors.grey,
                            ),
                            title: Text(searchedModel.fullname!),
                            subtitle: Text(searchedModel.email!),
                          );
                        } else {
                          return Text("No data Found");
                        }
                      } else if (snapshot.hasError) {
                        return Text("An Error Occured!!!!");
                      } else {
                        return Text("No data Found");
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
