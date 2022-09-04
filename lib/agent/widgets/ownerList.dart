import 'package:flutter/material.dart';
import 'package:mhproperty/owner/models/owner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/owner/owner_profile_screen.dart';

class AgentList extends StatefulWidget {
    List<Owners> agentData = [];
  AgentList(this.agentData);

  @override
  State<AgentList> createState() => _AgentListState();
}

class _AgentListState extends State<AgentList> {
  var firebaseUser = FirebaseFirestore.instance.collection("agent").snapshots();
  @override
  void initState() {
    // databaseQuery();
    // getAgentDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final data = Provider.of<AgentsProvider>(context, listen: false);
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
                          OwnerProfileScreen(id: widget.agentData[index].id),
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
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0, top: 15),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 1.0, color: Colors.black))),
                    child: Icon(Icons.emoji_people, color: Colors.black),
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
                              widget.agentData[index].state,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 32, 25, 25),
                                  fontSize: 10))
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
                  trailing: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.agentData[index].image),
                  ),
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
