import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../owner/models/notification.dart';
import 'package:intl/intl.dart';

import '../widgets/agent_drawer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required this.uid});
  final String uid;
  static const routeName = '/notificationScreen';
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // var firebaseUser;

  @override
  void initState() {
    Provider.of<NotificationProvider>(context, listen: false)
        .getUserNotification(widget.uid);
    // getUserNotification(widget.uid);
    super.initState();
  }

  Widget notificationItem(streamSnapshot) {
    if (streamSnapshot['action'] == 'Deal Status') {
      return InkWell(
        onTap: () {},
        child: Card(
          color: Color.fromARGB(225, 255, 172, 142),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(streamSnapshot['image']),
            ),
            title: Text(
              streamSnapshot['action'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                DateFormat('dd/MM/yy hh:mm:ss')
                    .format(DateTime.parse(streamSnapshot['createdTime'])),
                style: TextStyle(fontSize: 13),
              ),
              Text(
                streamSnapshot['message'],
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ]),
            trailing: Icon(Icons.notification_important_rounded),
          ),
        ),
      );
    } else if (streamSnapshot['action'] == 'Property Updates') {
      return InkWell(
        onTap: () {},
        child: Card(
          color: Colors.amber[600],
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(streamSnapshot['image']),
            ),
            title: Text(streamSnapshot['action']),
            subtitle:   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                DateFormat('dd/MM/yy hh:mm:ss')
                    .format(DateTime.parse(streamSnapshot['createdTime'])),
                style: TextStyle(fontSize: 13),
              ),
              Text(
                streamSnapshot['message'],
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ]),
            trailing: Icon(Icons.notification_important_rounded),
          ),
        ),
      );
    } else if (streamSnapshot['action'] == 'Follower') {
      return InkWell(
        onTap: () {},
        child: Card(
          color: Color.fromARGB(255, 16, 247, 162),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(streamSnapshot['image']),
            ),
            title: Text(streamSnapshot['action']),
            subtitle:   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                DateFormat('dd/MM/yy hh:mm:ss')
                    .format(DateTime.parse(streamSnapshot['createdTime'])),
                style: TextStyle(fontSize: 13),
              ),
              Text(
                streamSnapshot['message'],
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ]),
            trailing: Icon(Icons.notification_important_rounded),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {},
        child: Card(
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(streamSnapshot['image']),
            ),
            title: Text(streamSnapshot['action']),
            subtitle: Text(streamSnapshot['message']),
            trailing: Icon(Icons.notification_important_rounded),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<NotificationProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Notification'),
        ),
        drawer: MainDrawer(),
        body: SingleChildScrollView(
          child: Container(
            color: Theme.of(context).backgroundColor,
            height: MediaQuery.of(context).size.height * 0.85,
            child: StreamBuilder(
              stream: data.firebaseUser,
              builder: (ctx, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (streamSnapshot.data!.docs.length == 0) {
                  return const Center(
                    child: Text('No data...'),
                  );
                }
                return ListView.builder(
                  itemBuilder: (ctx, index) =>
                      notificationItem(streamSnapshot.data!.docs[index]),
                  itemCount: streamSnapshot.data!.docs.length,
                );
              },
            ),
          ),
        ));
  }
}
