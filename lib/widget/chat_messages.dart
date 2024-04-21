import 'package:chatapp/widget/chatbubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  ChatMessages({super.key});
  final authentaceduser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Messages'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something is wrong'),
          );
        }
        final loadedmessages = snapshot.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 30, right: 30),
          reverse: true,
          itemCount: loadedmessages.length,
          itemBuilder: (context, index) {
            final chatmessagedata = loadedmessages[index].data();
            final nextchatmessage = index + 1 < loadedmessages.length
                ? loadedmessages[index + 1].data()
                : null;
            final currentmessageuserId = chatmessagedata['userId'];
            final nextmessageuserId =
                nextchatmessage != null ? nextchatmessage['userId'] : null;
            final isnextusersame = nextmessageuserId == currentmessageuserId;
            if (isnextusersame) {
              return MessageBubble.next(
                message: chatmessagedata['message'],
                isMe: authentaceduser!.uid == currentmessageuserId,
              );
            }
            else{
              return MessageBubble.first(userImage: chatmessagedata['profile_image'], username: chatmessagedata['username'], message: chatmessagedata['message'], isMe: authentaceduser!.uid == currentmessageuserId);
            }
          },
        );
      },
    );
  }
}
