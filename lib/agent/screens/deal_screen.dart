import 'package:flutter/material.dart';
import 'package:mhproperty/agent/models/property.dart';
import 'package:mhproperty/agent/widgets/agent_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mhproperty/owner/models/dummyData.dart';
import 'package:provider/provider.dart';

import '../widgets/property/agent_propertyList.dart';

class DealScreen extends StatefulWidget {
  DealScreen({Key? key}) : super(key: key);
  static const routeName = '/dealScreen';

  @override
  State<DealScreen> createState() => _DealScreenState();
}

class _DealScreenState extends State<DealScreen> {
  var _searchController = TextEditingController();
  var _me;
  var text = '';
  List<String>? selectedHobby = [];
  List<String>? selectedAdType = [];
  List<String>? selectedCategory = [];

  void initState() {
    _me = FirebaseAuth.instance.currentUser;
    Future.delayed(const Duration(milliseconds: 60), () {
      Provider.of<PropertyProvider>(context, listen: false)
          .getAgentPropertyList(_me.uid, 'deal');
    });
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

  void _startAddNewTransaction(BuildContext ctx, DummyData, proData) {
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (_) {
          return StatefulBuilder(
            builder: (BuildContext context, setState1) => GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 4,
                child: Container(
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
                              proData.getPropertyDetailsList(selectedAdType,
                                  selectedCategory, selectedHobby);
                              // getAgentDetails();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
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
    final DummyData = Provider.of<dummyDataProvider>(context, listen: false);
    final proData = Provider.of<PropertyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Deals'),
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
                onChanged: proData.onSearchDealTextChanged,
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.filter_list_outlined),
                onPressed: () {
                  _startAddNewTransaction(context, DummyData, proData);

                  // controller.clear();
                  // onSearchTextChanged('');
                },
              ),
            ),
            // PropertyList(proData.propertyData),
            proData.propertyData.length != 0
                ? PropertyList(proData.propertyData)
                : Container(
                    child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      Text('No data...'),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}
