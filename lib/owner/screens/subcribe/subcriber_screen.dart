import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../agent/models/agent.dart';
import '../../models/dummyData.dart';
import '../../widgets/drawer.dart';
// import '../agent/agent_upload_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../agent/agentDetails_screen.dart';
import 'package:provider/provider.dart';
import '../../models/images.dart';
import '../../widgets/agent/agentList.dart';
import '../agent/agent_details_screen.dart';
// import 'package:union/union.dart';

class SubcribeScreen extends StatefulWidget {
  SubcribeScreen({Key? key}) : super(key: key);
  static const routeName = '/subcribeScreen';

  @override
  State<SubcribeScreen> createState() => _SubcribeScreenState();
}

class _SubcribeScreenState extends State<SubcribeScreen>
    with TickerProviderStateMixin {
  var _searchController = TextEditingController();
  var _me;
  var text = '';
  bool onSubmit = false;
  List<Agents> agentData = [];
  List<Agents> agentSubcriberData = [];
  List<Agents> agentDataAdType = [];
  List<Agents> agentDataFocusArea = [];
  List<Agents> agentDataCategory = [];
  List<Agents> duplicateAgentData = [];
  List<dynamic>? selectedHobby = [];
  List<dynamic>? selectedAdType = [];
  List<dynamic>? selectedCategory = [];
  late TabController _tabController;

  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _me = FirebaseAuth.instance.currentUser;
    getSubcribe();
    getSubcriber();
    // getAgentDetails();
    super.initState();
  }

  Future<void> getSubcribe() async {
    List<Agents> tempAgentData = [];
    FirebaseFirestore.instance
        .collection("agentList")
        .where('oid', isEqualTo: _me.uid)
        .snapshots()
        .listen((querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        print(querySnapshot.docs.length);
        FirebaseFirestore.instance
            .collection("agent")
            .doc(querySnapshot.docs[i]['aid'])
            .get()
            .then((result) {
          print(result['username']);
          // tempAgentData = [];
          tempAgentData.add(Agents(
              id: querySnapshot.docs[i]['aid'],
              username: result['username'],
              companyName: result['companyName'],
              email: result['email'],
              phoneNumber: result['phone'],
              state: result['state'],
              image: result['image'],
              description: result['description'],
              focusArea: result['focusArea'],
              adType: result['adType'],
              category: result['propertyCategories'],
              time: querySnapshot.docs[i]['createdTime']));
        });
      }
      Future.delayed(Duration(seconds: 1), () {
        print(tempAgentData.toString() + 'ssss');
        setState(() {
          agentData = tempAgentData;
        });
      });
    });
  }

  Future<void> getSubcriber() async {
    List<Agents> tempSubcriberAgentData = [];
    FirebaseFirestore.instance
        .collection("ownerList")
        .where('oid', isEqualTo: _me.uid)
        .snapshots()
        .listen((querySnapshot) {
      for (int v = 0; v < querySnapshot.docs.length; v++) {
        FirebaseFirestore.instance
            .collection("agent")
            .doc(querySnapshot.docs[v]['aid'])
            .snapshots()
            .listen((querySnapshotAgent) {
          tempSubcriberAgentData.add(Agents(
              id: querySnapshot.docs[v]['aid'],
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
              time: querySnapshot.docs[v]['createdTime']));
        });
      }
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        agentSubcriberData = tempSubcriberAgentData;
      });
      print(agentSubcriberData.toString() + 'ssss');
    });
  }

  Future<void> _refreshPage(BuildContext context) async {
    await getSubcribe();
  }

  @override
  Widget build(BuildContext context) {
    // getSubcribe();
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow'),
        bottom: TabBar(
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: 'Following',

              // icon: Icon(Icons.people),
            ),
            Tab(
              text: 'Followers',
              // icon: Icon(Icons.people),
            ),
          ],
        ),
      ),
      drawer: MainDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
            child: RefreshIndicator(
                onRefresh: () => _refreshPage(context),
                child: agentData.length != 0
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AgentList(agentData),
                          ],
                        ),
                      )
                    : Center(child: Text('No data...'))),
          ),
          Container(
            color: Theme.of(context).backgroundColor,
            child: RefreshIndicator(
              onRefresh: () => _refreshPage(context),
              child: agentSubcriberData.length != 0
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AgentList(agentSubcriberData),
                        ],
                      ),
                    )
                  : Center(
                      child: Text('No data...'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
