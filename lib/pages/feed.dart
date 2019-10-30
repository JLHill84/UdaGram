import 'package:flutter/material.dart';
import 'package:udagram/pages/create.dart';
import 'package:udagram/widgets/compose_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Widget> _posts = [];
  List<DocumentSnapshot> _postDocuments = [];

  Future _getFeedFuture;

  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ScrollController _scrollController = ScrollController();
  bool _loadingMorePosts = false;
  bool _canLoadMorePosts = true;

  DocumentSnapshot _lastDocument;

  _navigateToCreatePage() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext ctx) {
      return CreatePage();
    }));
    _getFeedFuture = _getFeed();
  }

  Future _getFeed() async {
    _posts = [];
    Query _query = _firestore
        .collection('posts')
        .orderBy('created', descending: true)
        .limit(10);

    QuerySnapshot _querySnapshot = await _query.getDocuments();

    print(_querySnapshot.documents.length);

    _postDocuments = _querySnapshot.documents;
    _lastDocument = _postDocuments[_postDocuments.length - 1];

    for (int i = 0; i < _postDocuments.length; i++) {
      Widget w = _makeCard(_postDocuments[i]);
      _posts.add(w);
    }
    return _postDocuments;
  }

  Future _getMoreFeed() async {
    if (_loadingMorePosts == true) {
      return null;
    }

    if (_canLoadMorePosts == false) {
      return null;
    }

    Query _query = _firestore
        .collection('posts')
        .orderBy('created', descending: true)
        .limit(10)
        .startAfter([_lastDocument.data['created']]);

    QuerySnapshot _querySnapshot = await _query.getDocuments();

    print(_querySnapshot.documents.length);

    _postDocuments = _querySnapshot.documents;

    for (int i = 0; i < _postDocuments.length; i++) {
      Widget w = _makeCard(_postDocuments[i]);
      _posts.add(w);
    }
    return _postDocuments;
  }

  _getItems() {
    List<Widget> _items = [];

    Widget _composeBox = GestureDetector(
      child: ComposeBox(),
      onTap: _navigateToCreatePage,
    );

    _items.add(_composeBox);

    Widget seperator = Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        'Recent Posts',
        style: TextStyle(color: Colors.black54),
      ),
    );

    _items.add(seperator);

    Widget feed = FutureBuilder(
      future: _getFeedFuture,
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 16,
              ),
              Text('Loading...'),
            ],
          );
        } else if (snapshot.data.length == 0) {
          return Text('No data to show you');
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _posts,
          );
        }
      },
    );
    _items.add(feed);

    return _items;
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (maxScroll - currentScroll < delta) {
        _getMoreFeed();
      }
    });

    _getFeedFuture = _getFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.rss_feed),
        title: Text('UdaFeed'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: _getItems(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePage,
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget _makeCard(DocumentSnapshot postDocument) {
  return Card(
    margin: const EdgeInsets.all(8),
    elevation: 5,
    child: Column(
      children: <Widget>[
        ListTile(
          title: Text(postDocument.data['owner']),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.watch_later,
                size: 14,
              ),
              SizedBox(
                width: 4,
              ),
              Text(Moment.now()
                  .from((postDocument.data['created'] as Timestamp).toDate())),
            ],
          ),
        ),
        postDocument.data['image'] == null
            ? Container()
            : FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: postDocument.data['image'],
                fit: BoxFit.cover,
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(16),
                child: Text(postDocument.data['text'])),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  '3 Likes',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  '2 Comments',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  'Share',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            )
          ],
        )
      ],
    ),
  );
}
