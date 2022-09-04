import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import '../../../agent/models/property.dart';
import '../../screens/property/property_upload_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/property/propertyDetails_screen.dart';
import 'package:provider/provider.dart';
import '../../models/images.dart';

class AgentPropertyList extends StatefulWidget {
  var id;
  String all;
  AgentPropertyList(this.id, this.all);
  @override
  State<AgentPropertyList> createState() => _AgentPropertyListState();
}

class _AgentPropertyListState extends State<AgentPropertyList> {
  var firebaseUser;
  List<Property> OwnerList = [];
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 200), () {
      Provider.of<PropertyProvider>(context, listen: false)
          .getAgentPropertyList(widget.id, 'owner');
      print('object 1');
      Future.delayed(const Duration(milliseconds: 180), () {
        final propertyData =
            Provider.of<PropertyProvider>(context, listen: false).propertyList;
        print('object 2' + propertyData.toString());
        databaseQuery(propertyData);
      });
    });
    super.initState();
  }

  Future<void> databaseQuery(propertyData) async {
    print('object 3' + propertyData.toString());
    List<Property> tempOwnerList = [];
    OwnerList = [];
    if (widget.all == 'Sale') {
      propertyData.forEach((element) {
        if (element.adType == "For Sale") {
          setState(() {
            OwnerList.add(element);
          });
        }
      });
      // Future.delayed(const Duration(milliseconds: 60), () {
      //   setState(() {
      //     OwnerList = tempOwnerList;
      //   });
      // });
    } else if (widget.all == 'Rent') {
      propertyData.forEach((element) {
        if (element.adType == "For Rent") {
          setState(() {
            OwnerList.add(element);
          });
        }
      });
      // setState(() {
      //   OwnerList = tempOwnerList;
      // });
    } else {
      setState(() {
        OwnerList = propertyData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.83,
      child: OwnerList.length == 0
          ? Center(
              child: Text('No data...'),
            )
          : ListView.builder(
              itemBuilder: (ctx, index) => InkWell(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
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
                      OwnerList[index].title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Icon(Icons.linear_scale,
                                color: Color.fromARGB(255, 229, 248, 14)),
                            Text(OwnerList[index].category,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 32, 25, 25),
                                    fontSize: 10))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Text(
                            'RM ' +
                                double.parse(OwnerList[index].price)
                                    .toStringAsFixed(2),
                          ),
                        ),
                     
                      ],
                    ),
                    trailing: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        OwnerList[index].image,
                      ),
                    ),
                  ),
                ),
              ),
              itemCount: OwnerList.length,
            ),
    );
  }
}
