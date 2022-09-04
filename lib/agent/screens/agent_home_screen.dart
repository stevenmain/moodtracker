import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mhproperty/agent/models/property.dart';
import 'package:mhproperty/agent/screens/deal_screen.dart';
import 'package:mhproperty/agent/screens/follower/follower_screen.dart';
import 'package:mhproperty/agent/screens/notification.dart';
import 'package:mhproperty/agent/screens/property/agent_property_screen.dart';
import '../../agent/models/agent.dart';
import '../../owner/models/owner.dart';
import 'package:provider/provider.dart';
import '../widgets/agent_drawer.dart';
import '../widgets/property/agent_propertyList.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/ownerHome';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _me;
  bool loading = false;

  void initState() {
    _me = FirebaseAuth.instance.currentUser;
     Provider.of<PropertyProvider>(context, listen: false).getPropertList();
    Future.delayed(const Duration(milliseconds: 60), () {
      Provider.of<AgentsProvider>(context, listen: false)
          .getSingleAgentDetails(_me.uid);
      Future.delayed(const Duration(milliseconds: 120), () {
        setState(() {
          loading = true;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ownerData = Provider.of<OwnersProvider>(context);
    final agentData = Provider.of<AgentsProvider>(context);
    final proData = Provider.of<PropertyProvider>(context);
    // print(agentData.agentData.length);
    print('object3');

    print(ownerData.ownerList);
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: MainDrawer(),
      body: loading == false
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height * 0.94,
              child: SingleChildScrollView(
                child: Container(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   width: double.infinity,
                        //   color: Theme.of(context).backgroundColor,
                        //   padding: EdgeInsets.all(15),
                        //   child: Text(
                        //     // 'sss',
                        //     'Welcome ' + agentData.singleAgentData[0].username,
                        //     style: TextStyle(
                        //         fontSize: 20, fontWeight: FontWeight.w500),
                        //   ),
                        // ),
                        Container(
                          child: Image.asset(
                            'assets/images/banner.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            selection(PropertyScreen.routeName,
                                Icons.holiday_village, 'Property'),
                            selection(DealScreen.routeName,
                                Icons.monetization_on, 'Deal'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            selection(FollowerScreen.routeName, Icons.people,
                                'Follower'),
                            selection(_me.uid, Icons.notification_important,
                                'Notification'),
                          ],
                        ),
                        // Divider(
                        //   color: Colors.black,
                        // ),
                        Container(
                          color: Theme.of(context).backgroundColor,
                          child: Column(
                            children: [
                              Container(
                                // color: Colors.white,
                                width: double.infinity,
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, bottom: 5),
                                child: Text(
                                  'Property',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                               PropertyList(proData.propertyData),
                              // imagesShow(MediaQuery.of(context).size, agentData),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ),
    );
  }

  // Widget imagesShow(deviceSize, data) {
  //   return Container(
  //       child: SizedBox(
  //     height: MediaQuery.of(context).size.height * 0.26,
  //     width: double.infinity,
  //     child: ListView(
  //       primary: false,
  //       shrinkWrap: true,
  //       scrollDirection: Axis.horizontal,
  //       children: data.agentData.map<Widget>((tx) {
  //         return Column(
  //           children: [
  //             Container(
  //               width: deviceSize.width * 0.3,
  //               height: deviceSize.height * 0.2,
  //               padding: const EdgeInsets.all(5),
  //               child: InkWell(
  //                   child: Image.network(
  //                     tx.image,
  //                     fit: BoxFit.cover,
  //                   ),
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => ProfileScreen(id: tx.id),
  //                       ),
  //                     );
  //                   }),
  //             ),
  //             Text(tx.username,
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //                 style: TextStyle(fontWeight: FontWeight.w500))
  //           ],
  //         );
  //       }).toList(),
  //     ),
  //   ));
  // }

  Widget selection(routeName, icon, text) {
    return InkWell(
      onTap: () {
        if (text == 'Notification') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationScreen(uid: routeName),
            ),
          );
        } else if (text == 'Upload') {
          Navigator.of(context).pushNamed(routeName);
        } else {
          Navigator.of(context).popAndPushNamed(routeName);
        }
      },
      child: Container(
        width: 120,
        padding: EdgeInsets.all(10),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(icon),
                Container(
                  child: Text(
                    text,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
