import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gupshup/models/chat_room_model.dart';
import 'package:gupshup/models/message_model.dart';
import 'package:gupshup/models/user_model.dart';
import 'package:uuid/uuid.dart';
var uuid = Uuid();
class ChatRoom extends StatefulWidget {
  final UserModels targetUser;
  final ChatRoomModel chatroom;
  final UserModels userModel;
  final User firebaseUser;

  const ChatRoom({Key? key, required this.targetUser,
    required this.chatroom, required this.userModel, required this.firebaseUser}) : super(key: key);
  
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  TextEditingController messageController = TextEditingController();

  void sendMessage() async{
    String msg = messageController.text.trim();
    messageController.clear();
    if(msg != ""){
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: Timestamp.now(),
        seen: false,
        text: msg,
      );

      FirebaseFirestore.instance.collection("chatrooms").
      doc(widget.chatroom.chatroomid).collection("message").
      doc(newMessage.messageId).set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms")
      .doc(widget.chatroom.chatroomid).set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            const SizedBox(width: 10),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column (
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection
                    ("chatrooms").doc(widget.chatroom.chatroomid).collection
                    ("message").orderBy("createdon", descending: true).snapshots(),

                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.active) {
                        if(snapshot.hasData){
                          QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: datasnapshot.docs.length,
                            itemBuilder: (context, index){
                              MessageModel currentMessage = MessageModel.fromMap(
                                datasnapshot.docs[index].data() as Map<String, dynamic>
                              );  
                              return Row(
                                mainAxisAlignment: (currentMessage.sender == widget.userModel.uid) ?
                                MainAxisAlignment.end :
                                MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender == widget.userModel.uid) ?
                                      Colors.grey
                                      : Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  ),
                                ],
                              );                          
                            },
                          );
                        }
                        else if(snapshot.hasError){
                          return Center(
                            child: Text("An error occure"),
                          );
                        }
                        else {
                          return Center(
                          child: Text("Say Hi..."),
                        );
                        }
                      }
                      else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        maxLines: null,
                        controller: messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter message",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: (){
                        sendMessage();
                      }, 
                      icon: Icon(
                        Icons.send, 
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}