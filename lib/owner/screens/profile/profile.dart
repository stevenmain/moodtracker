import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/owner.dart';
import '../property/propertyDetails_screen.dart';
import 'package:provider/provider.dart';
import '../../widgets/property/propertyList.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  var me;
  ProfileScreen({super.key, required this.me});
  static const routeName = '/ownerProfile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _userData;
  var propertyList = 0;
  var propertySaleList = 0;
  var propertyRentList = 0;
    var followers = 0;

  void initState() {
    getUserDetails();
    getPropertyList();
    getPropertySaleList();
    getPropertyRentList();
    super.initState();
  }

  Future<void> getUserDetails() async {
    final data = Provider.of<OwnersProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection("owner")
        .doc(widget.me.uid)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        _userData = querySnapshot;
        data.addOwnerDataEdit(
            widget.me.uid,
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
        .where('oid', isEqualTo: widget.me.uid)
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
        .where('oid', isEqualTo: widget.me.uid)
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
        .where('oid', isEqualTo: widget.me.uid)
        .where('ad type', isEqualTo: 'For Rent')
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        propertyRentList = querySnapshot.docs.length;
      });
    });
  }

    Future<void> getFollowers() async {
    final data = Provider.of<OwnersProvider>(context, listen: false);
    FirebaseFirestore.instance
        // .collection("owner")
        // .doc(_me.uid)
        .collection("ownerList")
        .where('oid', isEqualTo: widget.me.uid)
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

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<OwnersProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileEditScreen(id: data.ownerList[0].id),
                  ),
                );
              },
              icon: Icon(Icons.edit_note_outlined))
        ],
      ),
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
                        data.ownerList[0].state.toString() == 'null'
                            ? Text('', style: TextStyle(fontSize: 13))
                            : Text(data.ownerList[0].state.toString(),
                                style: TextStyle(fontSize: 13))
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
                          fixedSize: Size(280.0, 40.0)),
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
                      PropertyList(widget.me, 'all'),
                      PropertyList(widget.me, 'Sale'),
                      PropertyList(widget.me, 'Rent'),
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
