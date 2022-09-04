import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  String uid;
  String title;
  String adType;
  String area;
  String state;
  String image;
  String price;
  String category;
  String time;
  String status;
  String agentStatus;

  Property(
      {required this.id,
      required this.title,
      required this.adType,
      required this.area,
      required this.state,
      required this.image,
      required this.price,
      required this.category,
      required this.uid,
      this.status = '',
      this.agentStatus = '',
      required this.time});
}

class PropertyProvider with ChangeNotifier {
  List<Property> _propertyList = [];
  List<Property> _propertyData = [];
  List<Property> _duplicatePropertyData = [];
  //  List<Property> _duplicatePropertyData2 = [];
  var aid = '';

  List<Property> get propertyList {
    return [..._propertyList];
  }

  List<Property> get propertyData {
    return [..._propertyData];
  }

  List<Property> get duplicatePropertyData {
    return [..._duplicatePropertyData];
  }

  Future<void> getPropertList() async {
    List<Property> tempPropertyData = [];

    FirebaseFirestore.instance
        .collection("property")
        .snapshots()
        .listen((propertyResult) {
      for (int v = 0; v < propertyResult.docs.length; v++) {
        if (propertyResult.docs.isNotEmpty) {
          tempPropertyData.add(Property(
            id: propertyResult.docs[v].id,
            uid: propertyResult.docs[v]['oid'],
            title: propertyResult.docs[v]['title'],
            area: propertyResult.docs[v]['area'],
            state: propertyResult.docs[v]['state'],
            adType: propertyResult.docs[v]['ad type'],
            image: propertyResult.docs[v]['image']['0'],
            price: propertyResult.docs[v]['price'].toString(),
            category: propertyResult.docs[v]['category'],
            status: propertyResult.docs[v]['status'],
            time: propertyResult.docs[v]['timestamp'],
          ));
        }
      }
      Future.delayed(Duration(milliseconds: 60), () {
        _propertyData = tempPropertyData;
        _duplicatePropertyData = tempPropertyData;

        print(_propertyData);
        notifyListeners();
      });
    });
  }

  Future<void> getPropertyDetailsList(
      selectedAdType, selectedCategory, selectedHobby) async {
    List<Property> newList = [];

    // print('type ' + selectedAdType!.length.toString());
    // print('category ' + selectedCategory!.length.toString());
    // print('area ' + duplicatePropertyData.length.toString());
    for (int a = 0; a < duplicatePropertyData.length; a++) {
      if (selectedAdType!.length > 0 &&
          selectedHobby!.length > 0 &&
          selectedCategory!.length > 0) {
        for (int v = 0; v < selectedAdType!.length; v++) {
          for (int t = 0; t < selectedCategory!.length; t++) {
            for (int i = 0; i < selectedHobby!.length; i++) {
              print('1objectsssssssssssssssssssssssssss');

              if (duplicatePropertyData[a].category == selectedCategory![t] &&
                  duplicatePropertyData[a].adType == selectedAdType![v] &&
                  duplicatePropertyData[a].state == selectedHobby![i]) {
                newList.add(duplicatePropertyData[a]);
              }
            }
          }
        }
      } else if (selectedAdType!.length > 0 &&
          selectedCategory!.length > 0 &&
          selectedHobby!.length <= 0) {
        for (int v = 0; v < selectedAdType!.length; v++) {
          for (int t = 0; t < selectedCategory!.length; t++) {
            print('2objectsssssssssssssssssssssssssss');

            if (duplicatePropertyData[a].category == selectedCategory![t] &&
                duplicatePropertyData[a].adType == selectedAdType![v]) {
              newList.add(duplicatePropertyData[a]);
            }
          }
        }
      } else if (selectedAdType!.length > 0 &&
          selectedCategory!.length <= 0 &&
          selectedHobby!.length > 0) {
        for (int v = 0; v < selectedAdType!.length; v++) {
          for (int i = 0; i < selectedHobby!.length; i++) {
            print('3objectsssssssssssssssssssssssssss');
            if (duplicatePropertyData[a].state == selectedHobby![i] &&
                duplicatePropertyData[a].adType == selectedAdType![v]) {
              newList.add(duplicatePropertyData[a]);
            }
          }
        }
      } else if (selectedAdType!.length <= 0 &&
          selectedCategory!.length > 0 &&
          selectedHobby!.length > 0) {
        for (int t = 0; t < selectedCategory!.length; t++) {
          for (int i = 0; i < selectedHobby!.length; i++) {
            print('4objectsssssssssssssssssssssssssss');
            if (duplicatePropertyData[a].state == selectedHobby![i] &&
                duplicatePropertyData[a].category == selectedCategory![t]) {
              newList.add(duplicatePropertyData[a]);
            }
          }
        }
      } else if (selectedAdType!.length > 0 &&
          selectedCategory!.length <= 0 &&
          selectedHobby!.length <= 0) {
        for (int v = 0; v < selectedAdType!.length; v++) {
          print('5objectsssssssssssssssssssssssssss');

          if (duplicatePropertyData[a].adType == selectedAdType![v]) {
            newList.add(duplicatePropertyData[a]);
          }
        }
      } else if (selectedAdType!.length <= 0 &&
          selectedCategory!.length > 0 &&
          selectedHobby!.length <= 0) {
        for (int t = 0; t < selectedCategory!.length; t++) {
          print('6objectsssssssssssssssssssssssssss');
          if (duplicatePropertyData[a].category == selectedCategory![t]) {
            newList.add(duplicatePropertyData[a]);
          }
        }
      } else if (selectedAdType!.length <= 0 &&
          selectedCategory!.length <= 0 &&
          selectedHobby!.length > 0) {
        for (int i = 0; i < selectedHobby!.length; i++) {
          print('7objectsssssssssssssssssssssssssss');
          if (duplicatePropertyData[a].state == selectedHobby![i]) {
            newList.add(duplicatePropertyData[a]);
          }
        }
      } else {
        newList = duplicatePropertyData;
      }
    }
    List<Property> tempList = [];

    Future.delayed(Duration(milliseconds: 60), () {
      _propertyData = newList;
      notifyListeners();
    });
  }

  Future<void> getPropertyDetails(uid, pid) async {
    List<Property> tempOwnerList = [];
    FirebaseFirestore.instance
        .collection("property")
        .doc(pid)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.exists != false) {
        tempOwnerList.add(
          Property(
            id: querySnapshot.id,
            uid: uid,
            title: querySnapshot['title'],
            area: querySnapshot['area'],
            state: querySnapshot['state'],
            adType: querySnapshot['ad type'],
            image: querySnapshot['image']['0'],
            price: querySnapshot['price'].toString(),
            category: querySnapshot['category'],
            status: querySnapshot['status'],
            time: querySnapshot['timestamp'],
          ),
        );
        _propertyList = tempOwnerList;
      }
    });
    // notifyListeners();
  }

  void onSearchTextChanged(String query) {
    List<Property> dummySearchList = [];
    dummySearchList.addAll(_duplicatePropertyData);
    if (query.isNotEmpty) {
      List<Property> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.title.contains(query)) {
          dummyListData.add(item);
        }
      });
      _propertyData.clear();
      _propertyData.addAll(dummyListData);
      notifyListeners();
      return;
    } else {
      getPropertList();
      _propertyData.clear();
      _propertyData.addAll(_duplicatePropertyData);
      notifyListeners();
    }
  }
// search agent deal text
    void onSearchDealTextChanged(String query) {
    List<Property> dummySearchList = [];
    dummySearchList.addAll(_duplicatePropertyData);
    if (query.isNotEmpty) {
      List<Property> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.title.contains(query)) {
          dummyListData.add(item);
        }
      });
      _propertyData.clear();
      _propertyData.addAll(dummyListData);
      notifyListeners();
      return;
    } else {
      getAgentPropertyList(aid, 'deal');
      _propertyData.clear();
      _propertyData.addAll(_duplicatePropertyData);
      notifyListeners();
    }
  }

// get agent property list
  Future<void> getAgentPropertyList(aidd, type) async {
    List<Property> tempOwnerList = [];
    aid = aidd;
    FirebaseFirestore.instance
        .collection("agent_property")
        // .where('status', isEqualTo: 'Accepted')
        .where('aid', isEqualTo: aidd)
        .orderBy('createdTime', descending: true)
        .snapshots()
        .listen((querySnapshotPropertyList) {
      for (int v = 0; v < querySnapshotPropertyList.docs.length; v++) {
        print(querySnapshotPropertyList.docs.length.toString() + 'qqqqqqqqqqq');
        FirebaseFirestore.instance
            .collection("property")
            .doc(querySnapshotPropertyList.docs[v]['pid'])
            .snapshots()
            .listen((querySnapshotAgentPData) {
          print(querySnapshotPropertyList.docs.length.toString() +
              'wwwwwwwwwwwwww');
          tempOwnerList.add(
            Property(
                id: querySnapshotPropertyList.docs[v]['pid'],
                uid: querySnapshotAgentPData['oid'],
                title: querySnapshotAgentPData['title'],
                area: querySnapshotAgentPData['area'],
                state: querySnapshotAgentPData['state'],
                adType: querySnapshotAgentPData['ad type'],
                image: querySnapshotAgentPData['image']['0'],
                price: querySnapshotAgentPData['price'].toString(),
                category: querySnapshotAgentPData['category'],
                status: querySnapshotAgentPData['status'],
                time: querySnapshotAgentPData['timestamp'],
                agentStatus: querySnapshotPropertyList.docs[v]['status']),
          );
          print(querySnapshotPropertyList.docs[v]['status']);
        });
      }
      // _propertyList = tempOwnerList;
      // print(_propertyList.length);
      Future.delayed(const Duration(milliseconds: 60), () {
        if (type == 'deal') {
          _propertyData = tempOwnerList;
           _duplicatePropertyData = tempOwnerList;
      
          notifyListeners();
        } else {
          _propertyList = tempOwnerList;
          notifyListeners();
        }
        // notifyListeners();
        print(_propertyList.length);
      });
    });

    notifyListeners();
  }
}
