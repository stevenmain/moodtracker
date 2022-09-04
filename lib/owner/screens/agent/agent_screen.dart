import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../agent/models/agent.dart';
import '../../models/dummyData.dart';
import '../../widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../widgets/agent/agentDetailList.dart';

class AgentScreen extends StatefulWidget {
  AgentScreen({Key? key}) : super(key: key);
  static const routeName = '/agentScreen';

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  var _searchController = TextEditingController();
  var _me;
  var text = '';

  List<dynamic>? selectedHobby = [];
  List<dynamic>? selectedAdType = [];
  List<dynamic>? selectedCategory = [];

  void initState() {
    _me = FirebaseAuth.instance.currentUser;
    Provider.of<AgentsProvider>(context, listen: false).getAgentList();

    super.initState();
  }

  Widget wrapData(DummyData, selectType, setState1) {
    return Wrap(
      children: DummyData.map<Widget>(
        (dataInfo) {
          bool isSelected = false;
          if (selectType!.contains(dataInfo)) {
            isSelected = true;
          }
          return multiSelection(dataInfo, isSelected, selectType, setState1);
        },
      ).toList(),
    );
  }

  void _startAddNewTransaction(BuildContext ctx, DummyData, data) {
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (_) {
          return StatefulBuilder(
            builder: (BuildContext context, setState1) => GestureDetector(
              onTap: () {},
              child: Container(
                color: Theme.of(context).backgroundColor,
                padding: EdgeInsets.all(5),
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text('Ad Type'),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    wrapData(DummyData.adType, selectedAdType, setState1),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Text('Category'),
                    SizedBox(
                      height: 5,
                    ),
                    wrapData(DummyData.propertyCategory, selectedCategory,
                        setState1),
                    Divider(
                      color: Colors.black,
                    ),
                    Text('Focus Area'),
                    SizedBox(
                      height: 5,
                    ),
                    wrapData(DummyData.state, selectedHobby, setState1),
                    Divider(
                      color: Colors.black,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          
                          child: const Text(
                            'Submit',
                          ),
                          onPressed: () {
                            data.getAgentDetails(selectedAdType,
                                selectedCategory, selectedHobby);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
              behavior: HitTestBehavior.opaque,
            ),
          );
        });
  }

  Widget multiSelection(data, isSelected, selectedData, setState1) {
    return GestureDetector(
      onTap: () {
        if (!selectedData!.contains(data)) {
          if (selectedData!.length < 17) {
            selectedData!.add(data);
            setState1(() {});
            print(selectedData);
          }
        } else {
          selectedData!.removeWhere((value) => value == data);
          setState1(() {});
          print(selectedData);
        }
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey, width: 2)),
            child: Text(
              data,
              style: TextStyle(
                  color: isSelected ? Colors.red : Colors.grey, fontSize: 14),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AgentsProvider>(context);
    final DummyData = Provider.of<dummyDataProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent'),
      ),
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              leading: new Icon(Icons.search),
              title: new TextField(
                controller: _searchController,
                decoration: new InputDecoration(
                    hintText: 'Search', border: InputBorder.none),
                onChanged: data.onSearchTextChanged,
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.filter_list_outlined),
                onPressed: () {
                  _startAddNewTransaction(context, DummyData, data);

                  // controller.clear();
                  // onSearchTextChanged('');
                },
              ),
            ),
            // search(),
            AgentList(data.agentData),
          ],
        ),
      ),
    );
  }
}
