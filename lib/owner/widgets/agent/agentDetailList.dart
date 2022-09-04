import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../agent/models/agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/agent/agent_details_screen.dart';

class AgentList extends StatefulWidget {
  List<Agents> agentData = [];
  AgentList(this.agentData);

  @override
  State<AgentList> createState() => _AgentListState();
}

class _AgentListState extends State<AgentList> {
  var firebaseUser = FirebaseFirestore.instance.collection("agent").snapshots();
  var followers = 0;
  @override
  void initState() {
    getFollowers();
    // databaseQuery();
    // getAgentDetails();
    super.initState();
  }

  Future<void> getFollowers() async {
    final data = Provider.of<AgentsProvider>(context, listen: false);
    FirebaseFirestore.instance
        // .collection("owner")
        // .doc(_me.uid)
        .collection("agentList")
        .where('aid', isEqualTo: widget.agentData[0].id)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot != null) {
        setState(() {
          followers = querySnapshot.docs.length;
          // _subcribeCheck = true;
          // print(_me.uid);
          // print(_subcribeCheck);
          // print(querySnapshot.exists);
        });
      }
    });
  }

  Widget informationList(fixText, streamSnapshotData) {
    var listData = '';
    streamSnapshotData.forEach((value) {
      listData += ' -' + value;
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: Text(fixText),
          width: 100,
        ),
        // SizedBox(width: 65),
        Container(
          width: 250,
          child: Text(
            listData,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.agentData.length == 0
        ? Container(
            height: MediaQuery.of(context).size.height * 0.8,
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: Text('No data...'),
            ))
        : Container(
            color: Theme.of(context).backgroundColor,
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
                },
                child: Container(
                  child: Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(238, 245, 253, 1)),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(widget.agentData[index].image),
                              ),
                            ],
                          ),
                          Text(
                            widget.agentData[index].username,
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          Text(
                            followers.toString() + ' Followers',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          informationList(
                              'Ad Type :', widget.agentData[index].adType),
                          informationList(
                              'Category :', widget.agentData[index].category),
                          informationList('Focus Area :',
                              widget.agentData[index].focusArea),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              itemCount: widget.agentData.length,
            ),
          );
  }
}
