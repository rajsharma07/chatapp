import 'package:chatapp/widget/chat_messages.dart';
import 'package:chatapp/widget/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void pushnotification()async{
    final fcm = FirebaseMessaging.instance;
    final notificationsetting = await fcm.requestPermission();
    final token = await fcm.getToken();//returns address of device to which notification is to be sent
    fcm.subscribeToTopic('chat');//create a room to chat
  }
@override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Our Char App'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ChatMessages()), 
          NewMessages()
          ],
      ),
    );
  }
}
