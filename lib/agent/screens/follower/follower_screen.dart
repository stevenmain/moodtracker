import 'package:flutter/material.dart';
import 'package:mhproperty/owner/models/owner.dart';
import '../../../agent/models/agent.dart';
import '../../widgets/agent_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/ownerList.dart';

class FollowerScreen extends StatefulWidget {
  FollowerScreen({Key? key}) : super(key: key);
  static const routeName = '/followerScreen';

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen>
    with TickerProviderStateMixin {
  var _searchController = TextEditingController();
  var _me;
  var text = '';
  bool onSubmit = false;
  List<Owners> agentData = [];
  List<Owners> agentSubcriberData = [];
  List<Owners> agentDataAdType = [];
  List<Owners> agentDataFocusArea = [];
  List<Owners> agentDataCategory = [];
  List<Owners> duplicateAgentData = [];
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
    List<Owners> tempAgentData = [];
    FirebaseFirestore.instance
        .collection("ownerList")
        .where('aid', isEqualTo: _me.uid)
        .snapshots()
        .listen((querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        print(querySnapshot.docs.length);
        FirebaseFirestore.instance
            .collection("owner")
            .doc(querySnapshot.docs[i]['oid'])
            .get()
            .then((result) {
          print(result['username']);
          // tempAgentData = [];
          tempAgentData.add(Owners(
            id: querySnapshot.docs[i]['oid'],
            username: result['username'],
            email: result['email'],
            phoneNumber: result['phone'],
            state: result['state'],
            image: result['image'],
            description: result['description']
          ));
        });
      }
      Future.delayed(Duration(seconds: 1), () {
        print(tempAgentData.toString() + 'tttt');
        setState(() {
          agentData = tempAgentData;
        });
      });
    });
  }

  Future<void> getSubcriber() async {
    List<Owners> tempSubcriberAgentData = [];
    FirebaseFirestore.instance
        .collection("agentList")
        .where('aid', isEqualTo: _me.uid)
        .snapshots()
        .listen((querySnapshot) {
          
      for (int v = 0; v < querySnapshot.docs.length; v++) {
        print(querySnapshot.docs[v]['oid'].toString()+'hhhhhhhhhhhhh');
        FirebaseFirestore.instance
            .collection("owner")
            .doc(querySnapshot.docs[v]['oid'])
            .get()
            .then((querySnapshotAgent) {
          tempSubcriberAgentData.add(Owners(
              id: querySnapshot.docs[v]['oid'],
              username: querySnapshotAgent['username'],
              email: querySnapshotAgent['email'],
              phoneNumber: querySnapshotAgent['phone'],
              state: querySnapshotAgent['state'],
              image: querySnapshotAgent['image'],
              description: querySnapshotAgent['description'],
             ));
        });
      }
       Future.delayed(Duration(seconds: 1), () {
      setState(() {
        agentSubcriberData = tempSubcriberAgentData;
        print(agentSubcriberData.toString() + 'ssss');
      });
      
    });
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
