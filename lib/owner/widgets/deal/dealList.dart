import 'package:flutter/material.dart';
import '../../../agent/models/agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../agent/models/property.dart';
import '../../screens/agent/agent_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/notification.dart';
import 'package:provider/provider.dart';

class DealList extends StatefulWidget {
  List<Agents> agentData = [];
  Future<void> getRejected;
  String id = '';
  DealList(this.agentData, this.getRejected, this.id);

  @override
  State<DealList> createState() => _DealListState();
}

class _DealListState extends State<DealList> {
  // var firebaseUser = FirebaseFirestore.instance.collection("agent").snapshots();
  String status = '';
  var _me;

  @override
  void initState() {
    _me = FirebaseAuth.instance.currentUser;
    // databaseQuery();
    // getAgentDetails();
    Future.delayed(Duration(milliseconds: 50), () {
      Provider.of<PropertyProvider>(context, listen: false)
          .getPropertyDetails(_me.uid, widget.id);
          print(_me.uid);
          print(widget.id);
    });
    super.initState();
  }

  Future<void> changeAgentDealStatus(dummyData, status, peopertyDetails) async {
    final NotiData = Provider.of<NotificationProvider>(context, listen: false);
    if (status == 'Accepted') {
      await FirebaseFirestore.instance
          .collection("agent_property")
          .doc(dummyData.id)
          .update({'status': status, 'count': 0});
      NotiData.addSubcribeAgentNotification(
          _me.uid,
          dummyData.uid,
          'Deal Status',
          widget.id,
          'deal',
          'Congrats, you have been accepted!',
          peopertyDetails[0].image);
    } else {
      FirebaseFirestore.instance
          .collection("agent_property")
          .doc(dummyData.id)
          .update({'status': status, 'count': 1});
      NotiData.addSubcribeAgentNotification(
          _me.uid,
          dummyData.uid,
          'Deal Status',
          widget.id,
          'deal',
          'Sorry, you have been rejected!',
          peopertyDetails[0].image);
    }
  }

  void _startAddNewTransaction(BuildContext ctx, DummyData, peopertyDetails) {
    if (DummyData.dealStatus == "Accepted") {
      status = "Accepted";
    } else if (DummyData.dealStatus == "Rejected") {
      status = "Rejected";
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
                        title: Text("Accept"),
                        leading: Radio(
                            value: "Accepted",
                            groupValue: status,
                            onChanged: (value) {
                              setState1(() {
                                status = value.toString();
                                print(status);
                              });
                            }),
                      ),
                      ListTile(
                        title: Text("Reject"),
                        leading: Radio(
                            value: "Rejected",
                            groupValue: status,
                            onChanged: (value) {
                              setState1(() {
                                status = value.toString();

                                print(DummyData.fid);
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
                                changeAgentDealStatus(
                                    DummyData, status, peopertyDetails);
                                widget.getRejected;
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
    final peopertyDetails =
        Provider.of<PropertyProvider>(context, listen: false);
    // databaseQuery();
    // getAgentDetails();
    // print(widget.text);
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        itemBuilder: (ctx, index) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(id: widget.agentData[index].id),
              ),
            );

            // Navigator.of(context).pushNamed(
            //   ProfileScreen.routeName,
            //   arguments: {'me': widget.agentData[index].id},
            // );
          },
          child: Container(
            child: Card(
              elevation: 8.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(238, 245, 253, 1)),
                child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage(widget.agentData[index].image),
                    ),
                    title: Text(
                      widget.agentData[index].username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Icon(Icons.linear_scale,
                                color: Color.fromARGB(255, 30, 163, 234)),
                                Text(
                            widget.agentData[index].phoneNumber.toString(),
                          ),
                            // Text(
                            //     streamSnapshot.data!.docs[index]
                            //         ['companyName'],
                            //     style: TextStyle(
                            //         color: Color.fromARGB(255, 32, 25, 25),
                            //         fontSize: 10))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Text(
                            widget.agentData[index].email.toString(),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            _startAddNewTransaction(
                                context,
                                widget.agentData[index],
                                peopertyDetails.propertyList);
                          },
                          child: Card(
                            elevation: 3,
                            color:
                                widget.agentData[index].dealStatus == "Rejected"
                                    ? Color.fromARGB(225, 255, 0, 0)
                                    : Color.fromARGB(255, 1, 240, 61),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(widget.agentData[index].dealStatus
                                  .toString()),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
        itemCount: widget.agentData.length,
      ),
    );
  }
}
