import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/utils/constants.dart';

class ChatScreen extends StatefulWidget {
  static String id = "chat_screen_route";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String message;
  User user;
  FirebaseFirestore firestore;
  final inputTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getUser();
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                final messages = snapshot.data.docs;
                List<Widget> messagesWidgets = [];
                for (var m in messages) {
                  String sender = m.data()['sender'];
                  String message = m.data()['message'];
                  messagesWidgets.add(MessageBubble(
                    sender: sender,
                    text: message,
                    isMe: user.email == sender,
                  ));
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    children: messagesWidgets,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: inputTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      sendMessage(user.email, message);
                      inputTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String sender, String message) {
    firestore
        .collection("messages")
        .add({"sender": sender, "message": message});
  }

  void getUser() async {
    user = await FirebaseAuth.instance.currentUser;
  }
}
