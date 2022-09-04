import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mhproperty/owner/screens/agent/agent_details_screen.dart';
import 'package:mhproperty/owner/screens/agent/agent_screen.dart';
import 'package:mhproperty/owner/screens/notification.dart';
import 'package:mhproperty/owner/screens/property/property_screen.dart';
import 'package:mhproperty/owner/screens/property/property_upload_screen.dart';
import 'package:mhproperty/owner/screens/subcribe/subcriber_screen.dart';
import '../../agent/models/agent.dart';
import '../models/owner.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/ownerHome';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _me;

  void initState() {
    // TODO: implement initState
    _me = FirebaseAuth.instance.currentUser;
    Provider.of<AgentsProvider>(context, listen: false).getAgentList();
    Future.delayed(const Duration(milliseconds: 60), () {
      Provider.of<OwnersProvider>(context, listen: false)
          .getOwnerDetails(_me.uid);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ownerData = Provider.of<OwnersProvider>(context);
    final agentData = Provider.of<AgentsProvider>(context, listen: false);
    // print(agentData.agentData.length);

    print(ownerData.ownerList);
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: MainDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.94,
        child: SingleChildScrollView(
          child: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).backgroundColor,
                padding: EdgeInsets.all(15),
                child: Text(
                  'Welcome ' + ownerData.ownerList[0].username,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
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
                  selection(PropertyScreen.routeName, Icons.holiday_village,
                      'Manage'),
                  selection(AgentScreen.routeName, Icons.emoji_people, 'Agent'),
                  selection(SubcribeScreen.routeName, Icons.people, 'Follower'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  selection(
                      PropertyUploadScreen.routeName, Icons.upload, 'Upload'),
                  selection(
                      _me.uid, Icons.notification_important, 'Notification'),
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
                      padding: EdgeInsets.only(top: 10, left: 10, bottom: 5),
                      child: Text(
                        'Agents',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    imagesShow(MediaQuery.of(context).size, agentData),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget imagesShow(deviceSize, data) {
    return Container(
        child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.26,
      width: double.infinity,
      child: ListView(
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: data.agentData.map<Widget>((tx) {
          return Column(
            children: [
              Container(
                width: deviceSize.width * 0.3,
                height: deviceSize.height * 0.2,
                padding: const EdgeInsets.all(5),
                child: InkWell(
                    child: Image.network(
                      tx.image,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(id: tx.id),
                        ),
                      );
                    }),
              ),
              Text(tx.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500))
            ],
          );
        }).toList(),
      ),
    ));
  }

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
