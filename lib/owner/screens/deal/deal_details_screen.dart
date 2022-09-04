import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../agent/models/agent.dart';
import '../../models/dummyData.dart';
import '../../widgets/deal/dealList.dart';
import '../../widgets/drawer.dart';
// import '../agent/agent_upload_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../agent/agentDetails_screen.dart';
import 'package:provider/provider.dart';
import '../../models/images.dart';
import '../../widgets/agent/agentList.dart';
// import 'package:union/union.dart';

class DealDetailsScreen extends StatefulWidget {
  const DealDetailsScreen({super.key, required this.id});
  final String id;
  static const routeName = '/dealDetailScreen';

  @override
  State<DealDetailsScreen> createState() => _DealDetailsScreenState();
}

class _DealDetailsScreenState extends State<DealDetailsScreen>
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
    getRejected();
    getSubcriber();
    // getAgentDetails();
    super.initState();
  }

  Future<void> getRejected() async {
    List<Agents> tempAgentData = [];
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('pid', isEqualTo: widget.id)
        .where('count', isEqualTo: 1)
        .snapshots()
        .listen((querySnapshot) {
      for (int v = 0; v < querySnapshot.docs.length; v++) {
        FirebaseFirestore.instance
            .collection("agent")
            .doc(querySnapshot.docs[v]['aid'])
            .snapshots()
            .listen((querySnapshotAgent) {
          tempAgentData.add(Agents(
              id: querySnapshot.docs[v].id,
              fid: querySnapshot.docs[v]['pid'],
              uid: querySnapshotAgent.id,
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
              dealStatus: querySnapshot.docs[0]['status'],
              time: querySnapshot.docs[v]['createdTime']));
        });
      }
      Future.delayed(Duration(seconds: 1), () {
        print(widget.id.toString() + 'ssss');
        setState(() {
          agentData = tempAgentData;
        });
      });
    });
  }

  Future<void> getSubcriber() async {
    List<Agents> tempSubcriberAgentData = [];
    FirebaseFirestore.instance
        .collection("agent_property")
        .where('pid', isEqualTo: widget.id)
        .where('count', isEqualTo: 0)
        .snapshots()
        .listen((querySnapshot) {
      for (int v = 0; v < querySnapshot.docs.length; v++) {
        FirebaseFirestore.instance
            .collection("agent")
            .doc(querySnapshot.docs[v]['aid'])
            .snapshots()
            .listen((querySnapshotAgent) {
          tempSubcriberAgentData.add(Agents(
              id: querySnapshot.docs[v].id,
              fid: querySnapshot.docs[v]['pid'],
              uid: querySnapshotAgent.id,
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
              dealStatus: querySnapshot.docs[0]['status'],
              time: querySnapshot.docs[0]['createdTime']));
        });
      }
      Future.delayed(Duration(seconds: 1), () {
        print(tempSubcriberAgentData.toString() + 'bbb');
        setState(() {
          agentSubcriberData = tempSubcriberAgentData;
        });
      });
    });
  }

  Future<void> _refreshPage(BuildContext context) async {
    // await getSubcribe();
  }

  @override
  Widget build(BuildContext context) {
    // getSubcribe();
    return Scaffold(
      appBar: AppBar(
        title: Text('Deals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: 'Subcriber',
              icon: Icon(Icons.people_alt),
            ),
            Tab(
              text: 'Rejected',
              icon: Icon(Icons.block),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () => _refreshPage(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DealList(agentSubcriberData, getSubcriber(), widget.id),
                ],
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () => _refreshPage(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DealList(agentData, getRejected(), widget.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
