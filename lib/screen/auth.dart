import 'dart:io';

import 'package:chatapp/widget/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _fireobj = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  AuthenticationScreen({super.key});
  @override
  State<AuthenticationScreen> createState() {
    return _AuthenticationScreen();
  }
}

class _AuthenticationScreen extends State<AuthenticationScreen> {
  var formkey = GlobalKey<FormState>();
  bool _islogin = true;
  bool _isuploading = false;
  var _email = '';
  var _password = '';
  var _enteredusername = '';
  File? _selectedImage;
  void OnPicImage(File pic) {
    _selectedImage = pic;
  }

  void submit() async {
    final _isvalid = formkey.currentState!.validate();
    if (_isvalid) {
      formkey.currentState!.save();
    } else if (!_isvalid || !_islogin && _selectedImage == null) {
      return;
    }
    try {
      setState(() {
        _isuploading = true;
      });
      if (_islogin) {
        final usercredentials = await _fireobj.signInWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        final usercrediancials = await _fireobj.createUserWithEmailAndPassword(
            email: _email, password: _password);
        final storage_server = FirebaseStorage.instance
            .ref()
            .child('use_images')
            .child('${usercrediancials.user!.uid}.jpg');
        await storage_server.putFile(_selectedImage!);
        final imageurl = await storage_server.getDownloadURL();
        print(imageurl);
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(usercrediancials.user!.uid)
            .set({
          'username': _enteredusername,
          'email': _email,
          'image_url': imageurl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message ?? "Failed")));
      setState(() {
        _isuploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Image.asset("assets/images/chat.png")),
              Column(
                children: [
                  Card(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                            key: formkey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_islogin)
                                  User_Image(
                                    onPicImage: OnPicImage,
                                  ),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: "Email"),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.contains('@')) {
                                      return "Enter valid email";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _email = newValue!;
                                  },
                                ),
                                if (!_islogin)
                                  TextFormField(
                                    decoration:
                                        InputDecoration(labelText: 'UserName'),
                                    enableSuggestions: false,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter valid username!!';
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      _enteredusername = newValue!;
                                    },
                                  ),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: "Password"),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        value.length < 8) {
                                      return "Password should have minimum 8 characters ";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _password = newValue!;
                                  },
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    submit();
                                  },
                                  child: _isuploading
                                      ? const CircularProgressIndicator()
                                      : Text(_islogin ? 'Login' : 'Signup'),
                                ),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _islogin = !_islogin;
                                      });
                                    },
                                    child: Text(_islogin
                                        ? 'Create an account'
                                        : 'already have an account'))
                              ],
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
