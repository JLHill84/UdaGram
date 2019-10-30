import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController _postTextController = TextEditingController(text: '');
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String userUID;
  String userDisplayName;
  File _image;
  _post() async {
    if (_postTextController.text.trim().length == 0) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Needs moar text'),
      ));
      return;
    }
    DocumentReference ref;
    try {
      ref = await _firestore.collection('posts').add({
        'text': _postTextController.text.trim(),
        'owner_name': userDisplayName,
        'owner': userUID,
        'created': DateTime.now(),
        'likes': {},
        'likes_count': 0,
        'comments_count': 0
      });

      if (_image != null) {
        _key.currentState.removeCurrentSnackBar();
        _key.currentState.showSnackBar(SnackBar(
          content: Text('Uploading image...'),
        ));

        String _url = await _uploadImageAndGetURL(ref.documentID, _image);
        await ref.updateData({'image': _url});
        _key.currentState.removeCurrentSnackBar();
        _key.currentState.showSnackBar(SnackBar(
          content: Text('Posting!'),
        ));
      }

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

  Future<String> _uploadImageAndGetURL(String fileName, File file) async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageUploadTask _task = _storage.ref().child(fileName).putFile(
          file,
          StorageMetadata(contentType: 'image/png'),
        );

    final String _downloadURL =
        await (await _task.onComplete).ref.getDownloadURL();
    return _downloadURL;
  }

  @override
  void initState() {
    super.initState();

    _firebaseAuth.currentUser().then((FirebaseUser user) {
      userUID = user.uid;
      userDisplayName = user.displayName;
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
            ),
            _image == null
                ? Container()
                : Stack(
                    children: <Widget>[
                      Container(
                        child: Image.file(_image),
                        width: 300,
                        height: 300,
                      ),
                      Positioned(
                        // top: 40,
                        // right: -12,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          color: Colors.black,
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
