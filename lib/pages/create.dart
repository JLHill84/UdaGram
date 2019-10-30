import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController _postTextController = TextEditingController(text: '');
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String user_uid;
  String user_display_name;
  File _image;
  _post() async {
    if (_postTextController.text.trim().length == 0) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Needs moar text'),
      ));
      return;
    }
    try {
      _firestore.collection('posts').add({
        'text': _postTextController.text.trim(),
        'owner_name': user_display_name,
        'owner': user_uid,
        'created': DateTime.now(),
        'likes': {},
        'likes_count': 0,
        'comments_count': 0
      });

      _key.currentState.showSnackBar(SnackBar(
        content: Text('Posted!'),
      ));

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (ex) {
      print(ex);
      _key.currentState.showSnackBar(SnackBar(
        content: Text(ex.toString()),
      ));
    }
  }

  _showModalBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  File image = await ImagePicker.pickImage(
                      source: ImageSource.camera,
                      maxHeight: 480,
                      maxWidth: 480);
                  setState(() {
                    _image = image;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('Photo Album'),
                onTap: () async {
                  File image = await ImagePicker.pickImage(
                      source: ImageSource.gallery,
                      maxHeight: 480,
                      maxWidth: 480);
                  setState(() {
                    _image = image;
                  });
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    _firebaseAuth.currentUser().then((FirebaseUser user) {
      user_uid = user.uid;
      user_display_name = user.displayName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Make a new post!'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.deepOrange.withOpacity(0.2))),
              child: TextField(
                controller: _postTextController,
                maxLines: 5,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        splashColor: Colors.deepOrange,
                        color: Colors.deepOrange,
                        onPressed: () {
                          _showModalBottomSheet();
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: Text(
                                'Add picture',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 16,
                            )
                          ],
                        ),
                      )),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        splashColor: Colors.deepOrange,
                        color: Colors.deepOrange,
                        onPressed: () {
                          _post();
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: Text(
                                'Create post',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 16,
                            )
                          ],
                        ),
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
