import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../owner/models/notification.dart';
import '../../../owner/models/owner.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/agent.dart';
import '../../widgets/agent_drawer.dart';
import '../../widgets/property/agent_profileProperty.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key, required this.id});
  final String id;
  static const routeName = '/ownerProfile';

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  var _userData;
  var _me;
  var propertyList = 0;
  var propertySaleList = 0;
  var propertyRentList = 0;
  var followers = 0;
  bool _subcribeCheck = false;
  var followId = '';

  void initState() {
    _me = FirebaseAuth.instance.currentUser;
    getUserDetails();
    getPropertyList();
    getPropertySaleList();
    getPropertyRentList();
    getSubcribe();
    getFollowers();
    Future.delayed(Duration(milliseconds: 50), () {
      Provider.of<OwnersProvider>(context, listen: false)
          .getOwnerDetails(_me.uid);
    });
    super.initState();
  }

  Future<void> getUserDetails() async {
    final data = Provider.of<OwnersProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection("owner")
        .doc(widget.id)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        _userData = querySnapshot;
        data.addOwnerDataEdit(
            widget.id,
            querySnapshot['username'],
            querySnapshot['email'],
            querySnapshot['phone'],
            querySnapshot['state'],
            querySnapshot['image'],
            querySnapshot['description']);
      });
      _userData = querySnapshot;
      // streamSnapshot.data!['image']
    });
  }

  Future<void> getPropertyList() async {
    FirebaseFirestore.instance
        .collection("property")
        .where('oid', isEqualTo: widget.id)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        propertyList = querySnapshot.docs.length;
      });
      // print(querySnapshot.docs.length.toString() + 'sssss');
    });
  }

  Future<void> getPropertySaleList() async {
    FirebaseFirestore.instance
        .collection("property")
        .where('oid', isEqualTo: widget.id)
        .where('ad type', isEqualTo: 'For Sale')
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        propertySaleList = querySnapshot.docs.length;
      });
    });
  }

  Future<void> getPropertyRentList() async {
    FirebaseFirestore.instance
        .collection("property")
        .where('oid', isEqualTo: widget.id)
        .where('ad type', isEqualTo: 'For Rent')
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        propertyRentList = querySnapshot.docs.length;
      });
    });
  }

  Future<void> getSubcribe() async {
    final data = Provider.of<AgentsProvider>(context, listen: false);
    FirebaseFirestore.instance
        // .collection("owner")
        // .doc(_me.uid)
        .collection("ownerList")
        .where('aid', isEqualTo: _me.uid)
        .where('oid', isEqualTo: widget.id)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.length != 0) {
        setState(() {
          print('objectssssssssssssssssssss');
          followId = querySnapshot.docs[0].id;
          _subcribeCheck = true;
          // print(_me.uid);
          print(_subcribeCheck);
          // print(querySnapshot.exists);
        });
      }
    });
  }

  Future<void> getFollowers() async {
    final data = Provider.of<AgentsProvider>(context, listen: false);
    FirebaseFirestore.instance
        // .collection("owner")
        // .doc(_me.uid)
        .collection("ownerList")
        .where('aid', isEqualTo: _me.uid)
        .where('oid', isEqualTo: widget.id)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot != null) {
        setState(() {
          followers = querySnapshot.docs.length;
          // _subcribeCheck = true;
          // print(_me.uid);
          // print(_subcribeCheck);
          // print(querySnapshot.exists);
        });
      }
    });
  }

  Future<void> deleteSubcribeAgent(ownerDetails) async {
    final data = Provider.of<NotificationProvider>(context, listen: false);

    FirebaseFirestore.instance
        .collection("ownerList")
        .doc(followId)
        .delete()
        .then((_) {
      data.addSubcribeAgentNotification(
          _me.uid,
          widget.id,
          'Follower',
          '',
          'people',
          ownerDetails[0].username + ' has unfollow you!',
          ownerDetails[0].image);
      setState(() {
        _subcribeCheck = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow removed'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  Future<void> addSubcribeAgent(ownerDetails) async {
    final data = Provider.of<NotificationProvider>(context, listen: false);
    await FirebaseFirestore.instance.collection("ownerList").add({
      "aid": _me.uid,
      "oid": widget.id,
      "createdTime": DateTime.now().toString(),
    }).then((value) {
      setState(() {
        _subcribeCheck = true;
        followId = value.id;
      });
    });
    data.addSubcribeAgentNotification(
        _me.uid,
        widget.id,
        'Follower',
        '',
        'people',
        ownerDetails[0].username + ' has followed you!',
        ownerDetails[0].image);
    setState(() {
      _subcribeCheck = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Follow added'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownerDetails = Provider.of<OwnersProvider>(context, listen: false);
    final data = Provider.of<OwnersProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      drawer: MainDrawer(),
      body: DefaultTabController(
        length: 3,
        child: SingleChildScrollView(
          child: Container(
            color: Theme.of(context).backgroundColor,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(data.ownerList[0].image),
                        radius: 40.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(width: 20.0),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              children: [
                                Text(
                                  propertyList.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                SizedBox(height: 3.0),
                                Text(
                                  "Ads",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.9),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              children: [
                                Text(
                                  propertySaleList.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                SizedBox(height: 3.0),
                                Text(
                                  "For Sale",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.9),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              children: [
                                Text(
                                  propertyRentList.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                SizedBox(height: 3.0),
                                Text(
                                  "For Rent",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.9),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20.0),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.ownerList[0].username.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.0,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18.0,
                        ),
                        Text(data.ownerList[0].state.toString(),
                            style: TextStyle(fontSize: 13)), // <--
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Text(
                  followers.toString() + ' Followers',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 13.0,
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  data.ownerList[0].description.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13.0,
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _subcribeCheck
                        ? ElevatedButton(
                            onPressed: () {
                              // print(followId);
                              deleteSubcribeAgent(ownerDetails.ownerList);
                            },
                            child: Text(
                              "Following",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(140.0, 40.0),
                              primary: Color.fromARGB(255, 134, 129, 129),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              addSubcribeAgent(ownerDetails.ownerList);
                            },
                            child: Text(
                              "Follow",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(140.0, 40.0),
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   child: Text(
                    //     "Subcriber",
                    //     style: TextStyle(fontSize: 18.0),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     fixedSize: Size(140.0, 40.0),
                    //     primary: Colors.green,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(15.0),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 15.0),
                    OutlinedButton(
                      onPressed: () {
                        launch("tel://6" +
                            data.ownerList[0].phoneNumber.toString());
                      },
                      child: Icon(Icons.call),
                      style: OutlinedButton.styleFrom(
                          primary: Colors.black,
                          backgroundColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          fixedSize: Size(30.0, 40.0)),
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  child: TabBar(
                    labelColor: Colors.white,
                    tabs: [
                      Tab(
                        text: 'Posts',
                      ),
                      Tab(
                        text: 'For Sale',
                      ),
                      Tab(
                        text: 'For Rent',
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: TabBarView(
                    children: <Widget>[
                      PropertyList(widget.id, 'all'),
                      PropertyList(widget.id, 'Sale'),
                      PropertyList(widget.id, 'Rent'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
