import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import '../screens/property/property_screen.dart';
import '../screens/agent_home_screen.dart';
import '../screens/deal_screen.dart';
import '../screens/follower/follower_screen.dart';
import '../screens/notification.dart';
import '../screens/profile/agent_profile.dart';
import '../models/agent.dart';
import 'package:provider/provider.dart';

import '../screens/property/agent_property_screen.dart';

class MainDrawer extends StatefulWidget {
  MainDrawer({Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  var _me;
  var _userData;
  final padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  void initState() {
    // TODO: implement initState
    _me = FirebaseAuth.instance.currentUser;
    getUserDetails();
    super.initState();
  }

  Future<void> getUserDetails() async {
    final data = Provider.of<AgentsProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection("agent")
        .doc(_me.uid)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        _userData = querySnapshot;
        data.addAgentDataEdit(
          _me.uid,
          querySnapshot['username'],
           querySnapshot['companyName'],
          querySnapshot['email'],
          querySnapshot['phone'],
          querySnapshot['state'],
          querySnapshot['image'],
          querySnapshot['description'],
          querySnapshot['focusArea'],
          querySnapshot['adType'],
          querySnapshot['propertyCategories'],
        );
      });
      // print(data.agentList.);
      _userData = querySnapshot;
      // streamSnapshot.data!['image']
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AgentsProvider>(context, listen: false);

    return Drawer(
      child: Material(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: ListView(
          children: <Widget>[
            buildHeader(
                urlImage: data.agentList[0].image,
                name: data.agentList[0].username,
                email: data.agentList[0].email,
                onClicked: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(me: _me),
                      ));
                }),
            Container(
              padding: padding,
              child: Column(
                children: [
                  Divider(color: Colors.white70),
                  const SizedBox(height: 12),
                  // buildSearchField(),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'Home',
                    icon: Icons.people,
                    onClicked: () => selectedItem(context, 0),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Follower',
                    icon: Icons.favorite_border,
                    onClicked: () => selectedItem(context, 1),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Property',
                    icon: Icons.workspaces_outline,
                    onClicked: () => selectedItem(context, 2),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Deal',
                    icon: Icons.update,
                    onClicked: () => selectedItem(context, 3),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white70),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'logout',
                    icon: Icons.account_tree_outlined,
                    onClicked: () => selectedItem(context, 4),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Notifications',
                    icon: Icons.notifications_outlined,
                    onClicked: () => selectedItem(context, 5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              // Spacer(),
              // CircleAvatar(
              //   radius: 24,
              //   backgroundColor: Color.fromRGBO(30, 60, 168, 1),
              //   child: Icon(Icons.add_comment_outlined, color: Colors.white),
              // )
            ],
          ),
        ),
      );

  // Widget buildSearchField() {
  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        Navigator.of(context).popAndPushNamed(HomeScreen.routeName);
        break;
      case 1:
        Navigator.of(context).popAndPushNamed(FollowerScreen.routeName);
        break;
      case 2:
        Navigator.of(context).popAndPushNamed(PropertyScreen.routeName);

        break;
      case 3:
        Navigator.of(context).popAndPushNamed(DealScreen.routeName);
        break;
      case 4:
        FirebaseAuth.instance.signOut();
        Navigator.of(context).popAndPushNamed('/');
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationScreen(uid: _me.uid),
          ),
        );
        break;
    }
  }
}
