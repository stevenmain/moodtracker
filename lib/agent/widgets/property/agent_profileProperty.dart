import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/property/agent_property_details_screen.dart';
import 'package:provider/provider.dart';
import '../../models/images.dart';

class PropertyList extends StatefulWidget {
  var _id;
  String all;
  PropertyList(this._id, this.all);
  @override
  State<PropertyList> createState() => _PropertyListState();
}

class _PropertyListState extends State<PropertyList> {
  var firebaseUser;
  @override
  void initState() {
    databaseQuery();
    super.initState();
  }

  Future<void> databaseQuery() async {
    if (widget.all == 'Sale') {
      firebaseUser = FirebaseFirestore.instance
          .collection('property')
          .where('oid', isEqualTo: widget._id)
          .where('ad type', isEqualTo: 'For Sale')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else if (widget.all == 'Rent') {
      firebaseUser = FirebaseFirestore.instance
          .collection('property')
          .where('oid', isEqualTo: widget._id)
          .where('ad type', isEqualTo: 'For Rent')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      firebaseUser = FirebaseFirestore.instance
          .collection('property')
          .where('oid', isEqualTo: widget._id)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.83,
      child: StreamBuilder(
        stream: firebaseUser,
        builder: (ctx, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // print(streamSnapshot.data!.docs.length.toString());
          if (streamSnapshot.data!.docs.length == 0) {
            return Center(
              child: Text('No data...'),
            );
          }

          return ListView.builder(
            itemBuilder: (ctx, index) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetails(
                      id: streamSnapshot.data!.docs[index].id,
                      uid: streamSnapshot.data!.docs[index]['oid'],
                      status: streamSnapshot.data!.docs[index]['status'],
                      image: streamSnapshot.data!.docs[index]['image']
                          ['0'],
                    ),
                  ),
                );
                // Navigator.of(context).pushNamed(
                //   PropertyDetails.routeName,
                //   arguments: {'id': streamSnapshot.data!.docs[index].id},
                // );
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                // padding: const EdgeInsets.only(right: 12.0, top: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.05),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0, top: 15),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 1.0, color: Colors.black))),
                    child: Icon(Icons.holiday_village, color: Colors.black),
                  ),
                  title: Text(
                    streamSnapshot.data!.docs[index]['title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.linear_scale,
                              color: Color.fromARGB(255, 229, 248, 14)),
                          Text(streamSnapshot.data!.docs[index]['category'],
                              style: TextStyle(
                                  color: Color.fromARGB(255, 32, 25, 25),
                                  fontSize: 10))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                        child: Text(
                          'RM ' +
                              streamSnapshot.data!.docs[index]['price']
                                  .toStringAsFixed(2),
                        ),
                      ),
                    ],
                  ),
                  trailing: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        streamSnapshot.data!.docs[index]['image']['0']),
                  ),
                ),
              ),
            ),
            itemCount: streamSnapshot.data!.docs.length,
          );
        },
      ),
    );
  }
}
