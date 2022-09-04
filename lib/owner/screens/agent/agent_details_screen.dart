import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../agent/models/agent.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/notification.dart';
import '../../models/owner.dart';
import '../../widgets/drawer.dart';
import '../../widgets/property/agentPropertyList.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.id});
  final String id;
  static const routeName = '/agentProfile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _userData;
  var _me;
  var propertyList = 0;
  var propertySaleList = 0;
  var propertyRentList = 0;
  String _focusArea = '';
  String _adType = '';
  String _category = '';
  bool _subcribeCheck = false;
  var followId = '';
  var followers = 0;

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
    final data = Provider.of<AgentsProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection("agent")
        .doc(widget.id)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        _userData = querySnapshot;
        data.addAgentDataEdit(
          widget.id,
          querySnapshot['username'],
          querySnapshot['companyName'],
          querySnapshot['email'],
          querySnapshot['phone'],
          querySnapshot['state'],
          querySnapshot['image'],
          querySnapshot['description'],
          querySnapshot['focusArea'],
          querySnapshot['adType'],
          querySnapshot['propertyCategories'],
        );
        _focusArea = '';
        _adType = '';
        _category = '';
        querySnapshot['focusArea'].forEach((value) {
          _focusArea += ' -' + value;
        });
        querySnapshot['adType'].forEach((value) {
          _adType += ' -' + value;
        });
        querySnapshot['propertyCategories'].forEach((value) {
          _category += ' -' + value;
        });
      });
      _userData = querySnapshot;
      // streamSnapshot.data!['image']
    });
  }

  Future<void> getSubcribe() async {
    final data = Provider.of<AgentsProvider>(context, listen: false);
    FirebaseFirestore.instance
        // .collection("owner")
        // .doc(_me.uid)
        .collection("agentList")
        .where('aid', isEqualTo: widget.id)
        .where('oid', isEqualTo: _me.uid)
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
        .collection("agentList")
        .where('aid', isEqualTo: widget.id)
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

  Future<void> getPropertyList() async {
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('aid', isEqualTo: widget.id)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        propertyList = querySnapshot.docs.length;
      });
      // print(querySnapshot.docs.length.toString() + 'sssss');
    });
  }

  Future<void> deleteSubcribeAgent(ownerDetails) async {
    final data = Provider.of<NotificationProvider>(context, listen: false);

    FirebaseFirestore.instance
        .collection("agentList")
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
    await FirebaseFirestore.instance.collection("agentList").add({
      "aid": widget.id,
      "oid": _me.uid,
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

  Future<void> getPropertySaleList() async {
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('aid', isEqualTo: widget.id)
        .where('status', isEqualTo: "Accepted")
        .snapshots()
        .listen((querySnapshot) {
      for (int v = 0; v < querySnapshot.docs.length; v++) {
        print(querySnapshot.docs[v]['pid']);
        FirebaseFirestore.instance
            .collection("property")
            .doc(querySnapshot.docs[v]['pid'])
            .snapshots()
            .listen((queryProperty) {
          if (queryProperty['ad type'] == 'For Sale') {
            setState(() {
              propertySaleList += 1;
            });
          }
        });
      }
    });
  }

  Future<void> getPropertyRentList() async {
    int count = 0;
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('aid', isEqualTo: widget.id)
        .where('status', isEqualTo: "Accepted")
        .snapshots()
        .listen((querySnapshot) {
      for (int v = 0; v < querySnapshot.docs.length; v++) {
        FirebaseFirestore.instance
            .collection("property")
            .doc(querySnapshot.docs[v]['pid'])
            .snapshots()
            .listen((queryProperty) {
          if (queryProperty['ad type'] == 'For Rent') {
            setState(() {
              propertyRentList += 1;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownerDetails = Provider.of<OwnersProvider>(context, listen: false);
    final data = Provider.of<AgentsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      drawer: MainDrawer(),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: ListView(
          children: [
            DefaultTabController(
              length: 3,
              child: SingleChildScrollView(
                child: Container(
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
                              backgroundImage:
                                  NetworkImage(data.agentList[0].image),
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
                                            color:
                                                Colors.black.withOpacity(0.9),
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
                                            color:
                                                Colors.black.withOpacity(0.9),
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
                                            color:
                                                Colors.black.withOpacity(0.9),
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
                            data.agentList[0].username.toString(),
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
                              Text(data.agentList[0].state.toString(),
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
                        // data.agentList[0].focusArea.toString(),
                        data.agentList[0].description.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13.0,
                        ),
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        'Ad Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_adType),
                      SizedBox(height: 6.0),
                      Text(
                        'Property Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_category),
                      SizedBox(height: 6.0),
                      Text(
                        'Focus Area',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_focusArea),
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
                          SizedBox(width: 15.0),
                          OutlinedButton(
                            onPressed: () {
                              launch("tel://6" +
                                  data.agentList[0].phoneNumber.toString());
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
                            AgentPropertyList(data.agentList[0].id, 'all'),
                            AgentPropertyList(data.agentList[0].id, 'Sale'),
                            AgentPropertyList(data.agentList[0].id, 'Rent'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
