import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../agent/models/agent.dart';
import '../../../agent/models/property.dart';
import '../../models/notification.dart';
import '../../widgets/property/property_image.dart';
import '../agent/agent_details_screen.dart';
import '../deal/deal_details_screen.dart';
import './property_edit_screen.dart';
import 'package:provider/provider.dart';
import '../../widgets/agent/agentList.dart';

class PropertyDetails extends StatefulWidget {
  const PropertyDetails(
      {super.key,
      required this.id,
      required this.state,
      required this.category,
      required this.adType});
  final String id;
  final String state;
  final String category;
  final String adType;
  static const routeName = '/propertyDetails';
  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  var _me;
  List<dynamic>? selectedHobby = [];
  List<dynamic>? selectedAdType = [];
  List<dynamic>? selectedCategory = [];
  bool loading = false;

  void initState() {
    loading = true;
    _me = FirebaseAuth.instance.currentUser;
    Provider.of<AgentsProvider>(context, listen: false).getAgentList();
    Provider.of<AgentsProvider>(context, listen: false)
        .getFollowedAgentListByProperty(widget.id);
    getOwnerData();
    Future.delayed(const Duration(milliseconds: 60), () {
      Provider.of<AgentsProvider>(context, listen: false)
          .getAgentDetails([widget.adType], [widget.category], [widget.state]);
      loading = false;
    });
    super.initState();
  }

  CollectionReference users = FirebaseFirestore.instance.collection('owner');

  var ownerUsername = '';
  var ownerImage = '';
  String status = '';

  Widget imagesShow(deviceSize, data) {
    return Container(
        child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.23,
      width: double.infinity,
      child: ListView(
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: data.agentData.map<Widget>((tx) {
          return Column(
            children: [
              Container(
                width: deviceSize.width * 0.3,
                height: deviceSize.height * 0.2,
                padding: const EdgeInsets.all(5),
                child: InkWell(
                    child: Image.network(
                      tx.image,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(id: tx.id),
                        ),
                      );
                    }),
              ),
              Text(tx.username)
            ],
          );
        }).toList(),
      ),
    ));
  }

  Future<void> getOwnerData() async {
    FirebaseFirestore.instance
        .collection("owner")
        .doc(_me.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        ownerImage = querySnapshot['image'];
        ownerUsername = querySnapshot['username'];
      });
      // print(ownerUsername);
    });
  }

  Future<void> changePropertyStatus(
      id, status, RecommendData, peopertyDetails) async {
    final NotiData = Provider.of<NotificationProvider>(context, listen: false);
    if (status == 'Completed') {
      FirebaseFirestore.instance
          .collection("property")
          .doc(id)
          .update({'status': status});

      RecommendData.followedAgentData.forEach((element) {
        NotiData.addSubcribeAgentNotification(
            _me.uid,
            element.id,
            'Deal Status',
            widget.id,
            'deal',
            'This deal is completed!',
            peopertyDetails[0].image);
      });
    } else {
      FirebaseFirestore.instance
          .collection("property")
          .doc(id)
          .update({'status': status});
      RecommendData.followedAgentData.forEach((element) {
        NotiData.addSubcribeAgentNotification(
            _me.uid,
            element.id,
            'Deal Status',
            widget.id,
            'deal',
            'This deal is failed!',
            peopertyDetails[0].image);
      });
    }
  }

  void _startAddNewTransaction(
      BuildContext ctx, id, status, RecommendData, peopertyDetails) {
    if (status == "Completed") {
      status = "Completed";
    } else if (status == "Failed") {
      status = "Failed";
    } else {
      status = "";
    }
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (_) {
          return StatefulBuilder(
            builder: (BuildContext context, setState1) => GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 4,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Text('Status'),
                      SizedBox(
                        height: 2,
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      ListTile(
                        title: Text("Completed"),
                        leading: Radio(
                            value: "Completed",
                            groupValue: status,
                            onChanged: (value) {
                              setState1(() {
                                status = value.toString();
                              });
                            }),
                      ),
                      ListTile(
                        title: Text("Failed"),
                        leading: Radio(
                            value: "Failed",
                            groupValue: status,
                            onChanged: (value) {
                              setState1(() {
                                status = value.toString();
                              });
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            child: const Text(
                              'Submit',
                            ),
                            onPressed: () {
                              setState1(() {
                                changePropertyStatus(
                                    id, status, RecommendData, peopertyDetails);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
              behavior: HitTestBehavior.opaque,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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

    final deviceSize = MediaQuery.of(context).size;
    final data = Provider.of<AgentsProvider>(context);

    final peopertyDetails =
        Provider.of<PropertyProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('Property Details'),
          actions: [
            IconButton(
                onPressed: () {
                  // Navigator.of(context).pushNamed(
                  //   PropertyEditScreen.routeName, arguments: {'id': id.toString()},
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyEditScreen(id: widget.id),
                    ),
                  );
                },
                icon: Icon(Icons.edit_note_outlined))
          ],
        ),
        body: loading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.83,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('property')
                            .doc(widget.id)
                            .snapshots(),
                        builder: (ctx,
                            AsyncSnapshot<DocumentSnapshot> streamSnapshot) {
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
                                    child: imagesSlide(
                                        streamSnapshot.data!['image'])),
                                Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        streamSnapshot.data!['title'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
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
                                                  streamSnapshot
                                                          .data!['state'] +
                                                      ' - ' +
                                                      streamSnapshot
                                                          .data!['area'],
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Text(DateFormat(
                                                      'dd/MM/yy hh:mm:ss')
                                                  .format(DateTime.parse(
                                                      streamSnapshot.data![
                                                          'timestamp']))),
                                            )
                                          ]),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              // Container(
                                              //   width: ,
                                              //     child: Image.network(
                                              //         ownerImage)),
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundImage:
                                                    NetworkImage(ownerImage),
                                              ),
                                              Text(' ' + ownerUsername,
                                                  style:
                                                      TextStyle(fontSize: 17)),
                                            ],
                                          ),
                                          Container(
                                            child: Row(
                                              children: [
                                                Text('Status: '),
                                                SizedBox(
                                                  width: 100, // <-- Your width
                                                  height: 30, // <-- Your height
                                                  child: FloatingActionButton
                                                      .extended(
                                                    label: Text(
                                                      streamSnapshot
                                                          .data!['status'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ), // <-- Text

                                                    onPressed: () {
                                                      _startAddNewTransaction(
                                                          context,
                                                          streamSnapshot
                                                              .data!.id,
                                                          streamSnapshot
                                                              .data!['status'],
                                                          data,
                                                          peopertyDetails
                                                              .propertyList);
                                                    },
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.black.withOpacity(0.2),
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
                                            informationList(
                                                'Category',
                                                streamSnapshot
                                                    .data!['category']),
                                            informationList(
                                                'Ad Type',
                                                streamSnapshot
                                                    .data!['ad type']),
                                            informationList(
                                                'Property Type',
                                                streamSnapshot
                                                    .data!['property Type']),
                                            informationList(
                                                'Title Type',
                                                streamSnapshot
                                                    .data!['title Type']),
                                            informationList(
                                                'Bedrooms',
                                                streamSnapshot
                                                    .data!['bedrooms']),
                                            informationList(
                                                'Bathroom',
                                                streamSnapshot
                                                    .data!['bathroom']),
                                            informationList(
                                                'Size',
                                                streamSnapshot.data!['size'] +
                                                    ' sq.ft.'),
                                            informationList(
                                                'Other Info',
                                                streamSnapshot
                                                    .data!['other info']),
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
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        color: Theme.of(context).accentColor,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DealDetailsScreen(
                                                        id: widget.id
                                                            .toString()),
                                              ),
                                            );
                                          },
                                          child: ListTile(
                                            leading: Container(
                                                child: Text('Deal Details')),
                                            trailing: Container(
                                                child: Icon(Icons
                                                    .arrow_circle_right_rounded)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        child: Text(
                                          'Agent Recommendation',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Divider(),
                                      imagesShow(deviceSize, data),
                                      Divider(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            itemCount: 1,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ));
  }
}
