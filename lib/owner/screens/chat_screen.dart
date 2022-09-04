import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final routName = '/chatscreen';

  var _me;
  var _meData;
  //  Map<String, dynamic> _meData = {};

  void initState() {
    _me = FirebaseAuth.instance.currentUser;
    //  _meData  = FirebaseFirestore.instance.collection('users').doc(_me.uid).get();
    // print(_meData.toString());
    
    super.initState();
  }
// _meData['username'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_me.email.toString()),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats/LsZmICG60gmOzDHY2VDN/message')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemBuilder: (ctx, index) => Container(
              child: Text(streamSnapshot.data!.docs[index]['mss']),
              // child: Text(_meData[0]['username']),
              // child: Text(streamSnapshot.data!.docs[index]['message2']['ms1']),
            ),
            itemCount: streamSnapshot.data!.docs.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          FirebaseFirestore.instance
              .collection('chats/LsZmICG60gmOzDHY2VDN/message')
              .add({
            'mss': 'add function testing5',
            'timestamp': Timestamp.now(),
          });
          // .snapshots()
          // .listen((data) {
          // print(data.docs[0]['mss']);
          // data.docs.forEach((element) {
          //   print(element['mss']);
          // });
          // }
          // );
        },
      ),
    );
  }
}
