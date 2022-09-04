import 'package:flutter/material.dart';
import '../../../agent/models/agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../models/property.dart';
import '../../screens/property/agent_property_details_screen.dart';
// import '../../screens/property/agent_property_screen.dart';
// import '../../screens/agent/agent_details_screen.dart';

class PropertyList extends StatefulWidget {
  List<Property> propertyData = [];
  PropertyList(this.propertyData);

  @override
  State<PropertyList> createState() => _PropertyListState();
}

class _PropertyListState extends State<PropertyList> {
  var firebaseUser = FirebaseFirestore.instance.collection("agent").snapshots();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.propertyData);
    return Container(
      color: Theme.of(context).backgroundColor,
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        itemBuilder: (ctx, index) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetails(
                    id: widget.propertyData[index].id,
                    uid: widget.propertyData[index].uid,
                    status: widget.propertyData[index].status,
                    image: widget.propertyData[index].image),
              ),
            );
          },
          child: Container(
            child: Card(
              elevation: 8.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(238, 245, 253, 1)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.only(right: 10.0, top: 15),
                              decoration: new BoxDecoration(
                                  border: new Border(
                                      right: new BorderSide(
                                          width: 1.0, color: Colors.black))),
                              child: Icon(Icons.holiday_village,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.propertyData[index].title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.linear_scale,
                                                      size: 14.0,
                                                      color: Color.fromARGB(
                                                          255, 30, 163, 234)),
                                                  Text(
                                                      widget.propertyData[index]
                                                          .category,
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 32, 25, 25),
                                                          fontSize: 10))
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.select_all,
                                                      size: 14.0,
                                                      color: Color.fromARGB(
                                                          255, 30, 163, 234)),
                                                  Text(
                                                      widget.propertyData[index]
                                                          .adType,
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 32, 25, 25),
                                                          fontSize: 10))
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(Icons.location_on,
                                                  size: 14.0,
                                                  color: Color.fromARGB(
                                                      255, 30, 163, 234)),
                                              Text(
                                                  widget.propertyData[index]
                                                      .state,
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 32, 25, 25),
                                                      fontSize: 10))
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2.0, bottom: 2),
                                        child: Text(
                                          DateFormat('dd/MM/yy hh:mm').format(
                                              DateTime.parse(widget
                                                  .propertyData[index].time)),
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 8),
                                        child: Text(
                                            'RM ' +
                                                double.parse(widget
                                                        .propertyData[index]
                                                        .price)
                                                    .toStringAsFixed(2),
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.amber,
                          // width: 30,
                          // height: 500,
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.13,
                          child: Image.network(widget.propertyData[index].image,
                              fit: BoxFit.fill),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    widget.propertyData[index].agentStatus != ''
                        ? Container(
                            padding: EdgeInsets.all(3),
                            width: MediaQuery.of(context).size.width * 0.8,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.propertyData[index].agentStatus,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          ),
        ),
        itemCount: widget.propertyData.length,
      ),
    );
  }
}
