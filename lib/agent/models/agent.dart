import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Agents {
  final String id;
  String username;
  String companyName;
  String email;
  String phoneNumber;
  var state;
  String image;
  String description;
  List<dynamic> focusArea;
  List<dynamic> adType;
  List<dynamic> category;
  String time;
  String fid;
  String uid;
  String dealStatus;

  Agents(
      {required this.id,
      this.uid = '',
      this.fid = '',
      required this.username,
      required this.companyName,
      required this.email,
      required this.phoneNumber,
      required this.state,
      required this.image,
      required this.description,
      required this.focusArea,
      required this.adType,
      required this.category,
      this.dealStatus = '',
      this.time = ''});
}

class AgentsProvider with ChangeNotifier {
  List<Agents> _agentList = [
    Agents(
      id: 'sdssdsd',
      username: '',
      companyName: '',
      email: '',
      phoneNumber: '',
      state: '',
      image:
          'https://www.ateneo.edu/sites/default/files/styles/large/public/2021-11/istockphoto-517998264-612x612.jpeg?itok=aMC1MRHJ',
      description: '',
      focusArea: [],
      adType: [],
      category: [],
    ),
  ];

  List<Agents> _agentData = [];
  List<Agents> _duplicateAgentData = [];
  List<Agents> _followedAgentData = [];
  List<Agents> _singleAgentData = [];

  List<Agents> get agentList {
    return [..._agentList];
  }

  List<Agents> get agentData {
    return [..._agentData];
  }

  List<Agents> get duplicateAgentData {
    return [..._duplicateAgentData];
  }

  List<Agents> get followedAgentData {
    return [..._followedAgentData];
  }

  List<Agents> get singleAgentData {
    return [..._singleAgentData];
  }

  Future<void> addAgentDataEdit(id, username, companyName, email, phoneNumber,
      state, image, description, focusArea, adType, category) async {
    print('112233');
    try {
      List<Agents> imagesData = [];

      imagesData.add(
        Agents(
          id: id,
          username: username,
          companyName: companyName,
          email: email,
          phoneNumber: phoneNumber,
          state: state,
          image: image,
          description: description,
          focusArea: focusArea,
          adType: adType,
          category: category,
        ),
      );
      _agentList = imagesData;
      print(_agentList.toString() + 'shshh');
      notifyListeners();
    } catch (error) {
      print(error);
      // throw error;
    }
  }

  Future<void> addAgentDataAgentList(
      id,
      username,
      companyName,
      email,
      phoneNumber,
      state,
      image,
      description,
      focusArea,
      adType,
      category) async {
    print('112233');
    try {
      List<Agents> imagesData = [];

      imagesData.add(
        Agents(
          id: id,
          username: username,
          companyName: companyName,
          email: email,
          phoneNumber: phoneNumber,
          state: state,
          image: image,
          description: description,
          focusArea: focusArea,
          adType: adType,
          category: category,
        ),
      );
      _agentList = imagesData;
      print(_agentList.toString() + 'shshh');
      notifyListeners();
    } catch (error) {
      print(error);
      // throw error;
    }
  }

  Future<void> getAgentList() async {
    print('ssssssssssssssss');
    List<Agents> tempAgentData = [];
    FirebaseFirestore.instance
        .collection("agent")
        .snapshots()
        .listen((querySnapshot) {
      print(querySnapshot.docs.length);
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        tempAgentData.add(
          Agents(
            id: querySnapshot.docs[i].id,
            username: querySnapshot.docs[i]['username'],
            companyName: querySnapshot.docs[i]['companyName'],
            email: querySnapshot.docs[i]['email'],
            phoneNumber: querySnapshot.docs[i]['phone'],
            state: querySnapshot.docs[i]['state'],
            image: querySnapshot.docs[i]['image'],
            description: querySnapshot.docs[i]['description'],
            focusArea: querySnapshot.docs[i]['focusArea'],
            adType: querySnapshot.docs[i]['adType'],
            category: querySnapshot.docs[i]['propertyCategories'],
          ),
        );
      }
      _duplicateAgentData = tempAgentData;
      _agentData = tempAgentData;
      print(tempAgentData.toString() + 'sssssssssssssssssssss');
      notifyListeners();
    });
  }

  Future<void> getAgentDetails(
      selectedAdType, selectedCategory, selectedHobby) async {
    List<Agents> newList = [];
    print('type ' + selectedAdType!.length.toString());
    print('category ' + selectedCategory!.length.toString());
    print('area ' + selectedHobby!.length.toString());
    for (int a = 0; a < _duplicateAgentData.length; a++) {
      if (selectedAdType!.length > 0 &&
          selectedHobby!.length > 0 &&
          selectedCategory!.length > 0) {
        for (int v = 0; v < selectedAdType!.length; v++) {
          for (int t = 0; t < selectedCategory!.length; t++) {
            for (int i = 0; i < selectedHobby!.length; i++) {
              print('1objectsssssssssssssssssssssssssss');
              for (int j = 0; j < _duplicateAgentData[a].category.length; j++) {
                for (int k = 0; k < _duplicateAgentData[a].adType.length; k++) {
                  for (int m = 0;
                      m < _duplicateAgentData[a].focusArea.length;
                      m++) {
                    if (_duplicateAgentData[a].category[j] ==
                            selectedCategory![t] &&
                        _duplicateAgentData[a].adType[k] ==
                            selectedAdType![v] &&
                        _duplicateAgentData[a].focusArea[m] ==
                            selectedHobby![i]) {
                      newList.add(_duplicateAgentData[a]);
                    }
                  }
                }
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

            for (int j = 0; j < _duplicateAgentData[a].category.length; j++) {
              for (int k = 0; k < _duplicateAgentData[a].adType.length; k++) {
                if (_duplicateAgentData[a].category[j] ==
                        selectedCategory![t] &&
                    _duplicateAgentData[a].adType[k] == selectedAdType![v]) {
                  newList.add(_duplicateAgentData[a]);
                  // print(j);
                }
              }
            }
          }
        }
      } else if (selectedAdType!.length > 0 &&
          selectedCategory!.length <= 0 &&
          selectedHobby!.length > 0) {
        for (int v = 0; v < selectedAdType!.length; v++) {
          for (int i = 0; i < selectedHobby!.length; i++) {
            print('3objectsssssssssssssssssssssssssss');
            for (int j = 0; j < _duplicateAgentData[a].focusArea.length; j++) {
              for (int k = 0; k < _duplicateAgentData[a].adType.length; k++) {
                if (_duplicateAgentData[a].focusArea[j] == selectedHobby![i] &&
                    _duplicateAgentData[a].adType[k] == selectedAdType![v]) {
                  newList.add(_duplicateAgentData[a]);
                  // print(j);
                }
              }
            }
          }
        }
      } else if (selectedAdType!.length <= 0 &&
          selectedCategory!.length > 0 &&
          selectedHobby!.length > 0) {
        for (int t = 0; t < selectedCategory!.length; t++) {
          for (int i = 0; i < selectedHobby!.length; i++) {
            for (int j = 0; j < _duplicateAgentData[a].focusArea.length; j++) {
              for (int k = 0; k < _duplicateAgentData[a].category.length; k++) {
                if (_duplicateAgentData[a].focusArea[j] == selectedHobby![i] &&
                    _duplicateAgentData[a].category[k] ==
                        selectedCategory![t]) {
                  newList.add(_duplicateAgentData[a]);
                  // print(j);
                }
              }
            }
            print('4objectsssssssssssssssssssssssssss');
          }
        }
      } else if (selectedAdType!.length > 0 &&
          selectedCategory!.length <= 0 &&
          selectedHobby!.length <= 0) {
        for (int v = 0; v < selectedAdType!.length; v++) {
          print('5objectsssssssssssssssssssssssssss');
          for (int j = 0; j < _duplicateAgentData[a].adType.length; j++) {
            if (_duplicateAgentData[a].adType[j] == selectedAdType![v]) {
              newList.add(_duplicateAgentData[a]);
              // print(j);
            }
          }
        }
      } else if (selectedAdType!.length <= 0 &&
          selectedCategory!.length > 0 &&
          selectedHobby!.length <= 0) {
        for (int t = 0; t < selectedCategory!.length; t++) {
          print('6objectsssssssssssssssssssssssssss');
          for (int j = 0; j < _duplicateAgentData[a].category.length; j++) {
            if (_duplicateAgentData[a].category[j] == selectedCategory![t]) {
              newList.add(_duplicateAgentData[a]);
            }
          }
        }
      } else if (selectedAdType!.length <= 0 &&
          selectedCategory!.length <= 0 &&
          selectedHobby!.length > 0) {
        for (int i = 0; i < selectedHobby!.length; i++) {
          // print('7objectsssssssssssssssssssssssssss'+ duplicateAgentData[a].state);
          for (int j = 0; j < _duplicateAgentData[a].focusArea.length; j++) {
            if (_duplicateAgentData[a].focusArea[j] == selectedHobby![i]) {
              newList.add(_duplicateAgentData[a]);
              // print(j);
            }
          }
        }
      } else {
        newList = _duplicateAgentData;
      }
    }
    Future.delayed(Duration(milliseconds: 60), () {
      List<Agents> tempNewList = [];
      for (int i = 0; i < newList.length; i++) {
        if (i == 0) {
          tempNewList.add(newList[i]);
        } else {
          final tempList2 =
              tempNewList.any((element) => element.id == newList[i].id);

          if (!tempList2) {
            tempNewList.add(newList[i]);
          }
        }
        print(tempNewList.length);
      }
      _agentData = tempNewList;
      notifyListeners();
      // data.agentData = tempNewList;
    });
  }

  Future<void> getFollowedAgentListByProperty(String pid) async {
    print(pid + 'aaaaaaaaaaaaaaa');
    List<Agents> tempAgentData = [];
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('pid', isEqualTo: pid)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .listen((querySnapshotPropertyList) {
      for (int v = 0; v < querySnapshotPropertyList.docs.length; v++) {
        FirebaseFirestore.instance
            .collection("agent")
            .doc(querySnapshotPropertyList.docs[v]['aid'])
            .snapshots()
            .listen((querySnapshotAgent) {
          tempAgentData.add(
            Agents(
              id: querySnapshotAgent.id,
              username: querySnapshotAgent['username'],
              companyName: querySnapshotAgent['companyName'],
              email: querySnapshotAgent['email'],
              phoneNumber: querySnapshotAgent['phone'],
              state: querySnapshotAgent['state'],
              image: querySnapshotAgent['image'],
              description: querySnapshotAgent['description'],
              focusArea: querySnapshotAgent['focusArea'],
              adType: querySnapshotAgent['adType'],
              category: querySnapshotAgent['propertyCategories'],
            ),
          );
        });
      }
      Future.delayed(Duration(milliseconds: 60), () {
        _followedAgentData = tempAgentData;
        // _agentData = tempAgentData;
        notifyListeners();
      });
    });
  }

  void onSearchTextChanged(String query) {
    List<Agents> dummySearchList = [];
    dummySearchList.addAll(_duplicateAgentData);
    if (query.isNotEmpty) {
      List<Agents> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.username.contains(query)) {
          dummyListData.add(item);
        }
      });
      _agentData.clear();
      _agentData.addAll(dummyListData);
      notifyListeners();
      return;
    } else {
      getAgentList();
      // print(duplicateAgentData.toString()+'11111');
      _agentData.clear();
      _agentData.addAll(_duplicateAgentData);
    }
  }

  void setAgentData(tempNewList) {
    _agentData = tempNewList;
    // notifyListeners();
  }

  Future<void> getSingleAgentDetails(uid) async {
    List<Agents> tempAgentList = [];
    FirebaseFirestore.instance
        .collection("agent")
        .doc(uid)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.exists != false) {
        tempAgentList.add(
          Agents(
            id: querySnapshot.id,
            username: querySnapshot['username'],
            companyName: querySnapshot['companyName'],
            email: querySnapshot['email'],
            phoneNumber: querySnapshot['phone'],
            state: querySnapshot['state'],
            image: querySnapshot['image'],
            description: querySnapshot['description'],
            focusArea: querySnapshot['focusArea'],
            adType: querySnapshot['adType'],
            category: querySnapshot['propertyCategories'],
          ),
        );
        print(tempAgentList.length.toString() + 'saaaaaaaaaaaaaaaaaaaaaaaaaaa');
        _singleAgentData = tempAgentList;
        notifyListeners();
      }
    });
  }

// get top agent
  Future<void> getTopAgent() async {
    List<Agents> tempAgentData = [];
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .listen((querySnapshotPropertyList) {
      for (int v = 0; v < querySnapshotPropertyList.docs.length; v++) {
        FirebaseFirestore.instance
            .collection("agent")
            .doc(querySnapshotPropertyList.docs[v]['aid'])
            .snapshots()
            .listen((querySnapshotAgent) {
          tempAgentData.add(
            Agents(
              id: querySnapshotAgent.id,
              username: querySnapshotAgent['username'],
              companyName: querySnapshotAgent['companyName'],
              email: querySnapshotAgent['email'],
              phoneNumber: querySnapshotAgent['phone'],
              state: querySnapshotAgent['state'],
              image: querySnapshotAgent['image'],
              description: querySnapshotAgent['description'],
              focusArea: querySnapshotAgent['focusArea'],
              adType: querySnapshotAgent['adType'],
              category: querySnapshotAgent['propertyCategories'],
            ),
          );
        });
      }
      Future.delayed(Duration(milliseconds: 60), () {
        _followedAgentData = tempAgentData;
        // _agentData = tempAgentData;
        notifyListeners();
      });
    });
  }
}
