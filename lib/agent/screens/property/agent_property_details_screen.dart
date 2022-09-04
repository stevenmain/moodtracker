import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mhproperty/agent/models/property.dart';
import '../../../owner/models/notification.dart';
import '../../models/agent.dart';
import '../../widgets/agent_drawer.dart';
import '../../widgets/property/agent_property_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../owner/owner_profile_screen.dart';

class PropertyDetails extends StatefulWidget {
  const PropertyDetails(
      {super.key,
      required this.id,
      required this.uid,
      required this.status,
      required this.image});
  final String id;
  final String uid;
  final String status;
  final String image;
  static const routeName = '/agentPropertyDetails';
  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  var _me;
  bool _interestedCheck = false;
  String ownerResponse = 'Interested';
  String propertyStatus = '';
  String agentPropertyListId = '';
  var ownerImage = '';
  String status = '';

  void initState() {
    _me = FirebaseAuth.instance.currentUser;
    getOwnerData();
    getInterestedList();

    Future.delayed(const Duration(milliseconds: 60), () {
      Provider.of<AgentsProvider>(context, listen: false)
          .getSingleAgentDetails(_me.uid);
    });

    super.initState();
  }

  // CollectionReference users = FirebaseFirestore.instance.collection('owner');

  var ownerUsername = '';

  // Future<void> addUser() async {
  //   FirebaseFirestore.instance
  //       .collection("owner")
  //       .snapshots()
  //       .listen((querySnapshot) {
  //     querySnapshot.docs.forEach((result) {
  //       FirebaseFirestore.instance
  //           .collection("owner")
  //           .doc(result.id)
  //           .collection("property")
  //           .snapshots()
  //           .listen((querySnapshot) {
  //         querySnapshot.docs.forEach((result) {
  //           // print(querySnapshot.docs.length);
  //         });
  //       });
  //     });
  //   });
  // }

  // Future<void> getID() async {
  //   FirebaseFirestore.instance
  //       .collection("owner")
  //       .snapshots()
  //       .listen((querySnapshot) {
  //     querySnapshot.docs.forEach((result) {
  //       FirebaseFirestore.instance
  //           .collection("owner")
  //           .doc(result.id)
  //           .collection("property")
  //           .snapshots()
  //           .listen((querySnapshot) {
  //         querySnapshot.docs.forEach((result) {
  //           // print(querySnapshot.docs.length);
  //         });
  //       });
  //     });
  //   });
  // }

  Future<void> getOwnerData() async {
    FirebaseFirestore.instance
        .collection("owner")
        .doc(widget.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        ownerImage = querySnapshot['image'];
        ownerUsername = querySnapshot['username'];
      });
      // print(ownerUsername);
    });
  }

  Future<void> getInterestedList() async {
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('pid', isEqualTo: widget.id)
        .where('aid', isEqualTo: _me.uid)
        .snapshots()
        .listen((querySnapshot) {
      // print(widget.id);
      if (querySnapshot.docs.length > 0) {
        setState(() {
          _interestedCheck = true;
          ownerResponse = querySnapshot.docs[0]['status'];
          agentPropertyListId = querySnapshot.docs[0].id;
          print(agentPropertyListId);
          // print(_interestedCheck);
          // print(querySnapshot.exists);
        });
      }
    });
  }

  Future<void> deleteInterestedProperty() async {
    FirebaseFirestore.instance
        .collection("agent_property")
        .doc(agentPropertyListId)
        .delete()
        .then((_) {
      setState(() {
        _interestedCheck = false;
      });
      ownerResponse = "Interested";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property removed'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  Future<void> addSubcribeAgent() async {
    FirebaseFirestore.instance.collection("agent_property").add({
      "pid": widget.id,
      "aid": _me.uid,
      "count": 0,
      "status": 'Pending',
      "createdTime": DateTime.now().toString(),
    });
    setState(() {
      _interestedCheck = !_interestedCheck;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Property added'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget submitButton(NotiData, agentData) {
    if (widget.status == 'Completed' || widget.status == 'Failed') {
      return Container(
        width: 400,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(400, 50),
            maximumSize: const Size(400, 50),
          ),
          child: Text(ownerResponse, style: TextStyle(color: Colors.black)),
          onPressed: () {
            // _submit();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Property has been ' + widget.status),
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      );
    } else {
      if (!_interestedCheck) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).appBarTheme.backgroundColor,
            minimumSize: const Size(400, 50),
            maximumSize: const Size(400, 50),
          ),
          child: Text(ownerResponse, style: TextStyle(color: Colors.black)),
          onPressed: () {
            NotiData.addSubcribeAgentNotification(
                _me.uid,
                widget.uid,
                'Deal Status',
                widget.id,
                'deal',
                agentData[0].username + ' interested with your property',
                widget.image);
            addSubcribeAgent();
          },
        );
      } else {
        if (ownerResponse == 'Rejected') {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.red[600],
              minimumSize: const Size(400, 50),
              maximumSize: const Size(400, 50),
            ),
            child: Text(ownerResponse, style: TextStyle(color: Colors.black)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You has been rejected'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          );
        } else if (ownerResponse == 'Pending') {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.amber[600],
              minimumSize: const Size(400, 50),
              maximumSize: const Size(400, 50),
            ),
            child: Text(
              ownerResponse,
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              NotiData.addSubcribeAgentNotification(
                  _me.uid,
                  widget.uid,
                  'Deal Status',
                  widget.id,
                  'deal',
                  agentData[0].username + ' uninterested with your property',
                  widget.image);
              deleteInterestedProperty();
            },
          );
        } else {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).appBarTheme.backgroundColor,
              minimumSize: const Size(400, 50),
              maximumSize: const Size(400, 50),
            ),
            child: Text(ownerResponse, style: TextStyle(color: Colors.black)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You has been accepted'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          );
        }
      }
    }
  }
// streamSnapshot.data!['price']

  @override
  Widget build(BuildContext context) {
    final NotiData = Provider.of<NotificationProvider>(context, listen: false);
    final agentData = Provider.of<AgentsProvider>(context, listen: false);

    // final routeArgs =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    // final id = routeArgs['id'];
    // final uid = routeArgs['uid'];

    Widget informationList(fixText, streamSnapshotData) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Text(fixText),
            width: 150,
          ),
          // SizedBox(width: 65),
          Text(
            streamSnapshotData.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      );
    }

    Widget imagesSlide(imageData) {
      final List<Widget> itemsImage = [];
      // print(imageData.length.toString() + '222');
      for (var i = 0; i < imageData.length; i++) {
        itemsImage.add(
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                SliderShowFullmages.routeName,
                arguments: {'listImagesModel': imageData, 'current': i},
              );
            },
            child: Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(imageData[i.toString()]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }
      return CarouselSlider(
        items: itemsImage,

        //Slider Container properties
        options: CarouselOptions(
          height: 180.0,
          enlargeCenterPage: true,
          autoPlay: false,
          aspectRatio: 16 / 9,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          viewportFraction: 0.8,
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Property Details'),
        ),
        drawer: MainDrawer(),
        body: Container(
          color: Theme.of(context).backgroundColor,
          height: MediaQuery.of(context).size.height * 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.78,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('property')
                      .doc(widget.id)
                      .snapshots(),
                  builder:
                      (ctx, AsyncSnapshot<DocumentSnapshot> streamSnapshot) {
                    if (streamSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      itemBuilder: (ctx, index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              color: Colors.black,
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              child:
                                  imagesSlide(streamSnapshot.data!['image'])),
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(streamSnapshot.data!['title'], style: TextStyle(fontWeight: FontWeight.bold),),
                                Text('RM' +
                                    streamSnapshot.data!['price']
                                        .toStringAsFixed(2)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          // <-- Icon
                                          Icons.location_on,
                                          size: 18.0,
                                        ),
                                        Text(
                                            streamSnapshot.data!['state'] +
                                                ' - ' +
                                                streamSnapshot.data!['area'],
                                            style: TextStyle(
                                                fontSize: 13)), // <-- Te
                                      ],
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                            DateFormat('dd/MM/yy hh:mm:ss')
                                                .format(DateTime.parse(
                                                    streamSnapshot
                                                        .data!['timestamp']))),
                                      ),
                                    ]),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OwnerProfileScreen(
                                                    id: widget.uid),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                NetworkImage(ownerImage),
                                          ),
                                          Text(ownerUsername,
                                              style: TextStyle(fontSize: 17)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Text('Status: '),
                                          Text(
                                            streamSnapshot.data!['status'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .backgroundColor!
                                        .withOpacity(0.5),
                                    // color: Colors.black.withOpacity(0.2),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 8,
                                        color: Colors.black26,
                                        // offset: Offset(0, 1),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      informationList('Category',
                                          streamSnapshot.data!['category']),
                                       informationList('Ad Type',
                                          streamSnapshot.data!['ad type']),
                                      informationList(
                                          'Property Type',
                                          streamSnapshot
                                              .data!['property Type']),
                                      informationList('Title Type',
                                          streamSnapshot.data!['title Type']),
                                      informationList('Bedrooms',
                                          streamSnapshot.data!['bedrooms']),
                                      informationList('Bathroom',
                                          streamSnapshot.data!['bathroom']),
                                      informationList(
                                          'Size',
                                          streamSnapshot.data!['size'] +
                                              ' sq.ft.'),
                                      informationList('Other Info',
                                          streamSnapshot.data!['other info']),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text('Description'),
                                      Container(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text(streamSnapshot
                                            .data!['description']),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      itemCount: 1,
                    );
                  },
                ),
              ),
              submitButton(NotiData, agentData.singleAgentData),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: const Size(400, 50),
              //     maximumSize: const Size(400, 50),
              //   ),
              //   child: Text('Submit'),
              //   onPressed: () {
              //     // _submit();
              //     addSubcribeAgent();
              //   },
              // ),
            ],
          ),
        ));
  }
}
