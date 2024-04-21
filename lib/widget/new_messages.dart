import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});
  @override
  State<NewMessages> createState() {
    return _NewMessages();
  }
}

class _NewMessages extends State<NewMessages> {
  var _messagecontroler = TextEditingController();
  void SendMessage() async {
    final enteredmessage = _messagecontroler.text;
    if (enteredmessage.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    final userdata = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(user!.uid)
        .get();//get data from firestore
    print(userdata.data()!['username']);
    FirebaseFirestore.instance.collection('chat').add({
      'message': enteredmessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userdata.data()!['username'],
      'profile_imafe': userdata.data()!['image_url'],
    });

    _messagecontroler.clear();
    FocusScope.of(context).unfocus();//will close keyboard
  }

  @override
  void dispose() {
    _messagecontroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 2,
        bottom: 15,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messagecontroler,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Send....'),
            ),
          ),
          IconButton(
            onPressed: SendMessage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }
}
